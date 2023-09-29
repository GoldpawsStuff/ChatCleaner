--[[

	The MIT License (MIT)

	Copyright (c) 2023 Lars Norberg

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]]
local Addon, ns = ...

local Module = ns:NewModule("Spells")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- GLOBALS: DEFAULT_CHAT_FRAME
-- GLOBALS: C_Timer, ChatTypeInfo, GetTime,

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local G = {
	LEARN_ABILITY = ERR_LEARN_ABILITY_S, -- "You have learned a new ability: %s."
	LEARN_PASSIVE = ERR_LEARN_PASSIVE_S, -- "You have learned a new passive effect: %s."
	LEARN_SPELL = ERR_LEARN_SPELL_S, -- "You have learned a new spell: %s."
	SPELL_UNLEARNED = ERR_SPELL_UNLEARNED_S, -- "You have unlearned %s."
	SPELLS = SPELLS
}

-- Convert a WoW global string to a search pattern
local makePattern = function(msg)
	msg = string_gsub(msg, "%%([%d%$]-)d", "(%%d+)")
	msg = string_gsub(msg, "%%([%d%$]-)s", "(.+)")
	return msg
end

-- Search Pattern Cache.
-- This will generate the pattern on the first lookup.
local P = setmetatable({}, { __index = function(t,k)
	rawset(t,k,makePattern(k))
	return rawget(t,k)
end })

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)

	local ability = string_match(msg,P[G.LEARN_ABILITY])
	if (ability) then
		return true
	end

	local passive = string_match(msg,P[G.LEARN_PASSIVE])
	if (passive) then
		return true
	end

	local spell = string_match(msg,P[G.LEARN_SPELL])
	if (spell) then
		return true
	end

	local unlearned = string_match(msg,P[G.SPELL_UNLEARNED])
	if (unlearned) then
		return true
	end
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)

	local now = GetTime()

	local ability = string_match(message,P[G.LEARN_ABILITY])
	if (ability) then
		self.abilities = self.abilities + 1
		self.latest = now
	end

	local passive = string_match(message,P[G.LEARN_PASSIVE])
	if (passive) then
		self.passives = self.passives + 1
		self.latest = now
	end

	local spell = string_match(message,P[G.LEARN_SPELL])
	if (spell) then
		self.spells = self.spells + 1
		self.latest = now
	end

	local unlearned = string_match(message,P[G.SPELL_UNLEARNED])
	if (unlearned) then
		self.unlearned = self.unlearned + 1
		self.latest = now
	end

	if (not self.timer) then

		self.timer = C_Timer.NewTicker(.1, function()
			local now = GetTime()
			if (now > (self.latest + 1)) then

				local info = ChatTypeInfo["SYSTEM"]

				local msg
				local learned = self.abilities + self.passives + self.spells
				if (learned > 1) then
					DEFAULT_CHAT_FRAME:AddMessage(string_format(ns.out.item_multiple, G.SPELLS, learned), info.r, info.g, info.b, info.id)
				elseif (learned > 0) then
					DEFAULT_CHAT_FRAME:AddMessage(string_format(ns.out.item_single, G.SPELLS), info.r, info.g, info.b, info.id)
				end

				if (self.unlearned > 1) then
					DEFAULT_CHAT_FRAME:AddMessage(string_format(ns.out.item_deficit_multiple, G.SPELLS, self.unlearned), info.r, info.g, info.b, info.id)
				elseif (self.unlearned > 0) then
					DEFAULT_CHAT_FRAME:AddMessage(string_format(ns.out.item_deficit, G.SPELLS), info.r, info.g, info.b, info.id)
				end

				self.abilities = 0
				self.passives = 0
				self.spells = 0
				self.unlearned = 0

				self.timer:CancelTimer()
				self.timer = nil
				self.latest = nil
			end
		end)

	end

end

local onChatEventProxy = function(...)
	return Module:OnChatEvent(...)
end

local onAddMessageProxy = function(...)
	return Module:OnAddMessage(...)
end

Module.OnEnable = function(self)
	self.abilities = 0
	self.passives = 0
	self.spells = 0
	self.unlearned = 0

	self:RegisterBlacklistFilter(onAddMessageProxy)
end

Module.OnDisable = function(self)
	self.abilities = 0
	self.passives = 0
	self.spells = 0
	self.unlearned = 0

	self:UnregisterBlacklistFilter(onAddMessageProxy)
end
