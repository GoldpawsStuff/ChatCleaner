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

if (ns.IsClassic) then return end

local Module = ns:NewModule("Achievements")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- GLOBALS: ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilte

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local G = {
	ACHIEVEMENT_BROADCAST = ACHIEVEMENT_BROADCAST -- "%s has earned the achievement %s!"
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

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	if (string_find(message, "|Hquestie")) then return end

	local player_name, achievement = string_match(message, P[G.ACHIEVEMENT_BROADCAST])
	if (player_name) and (achievement) then

		-- kill brackets
		player_name = string_gsub(player_name, "[%[/%]]", "")
		achievement = string_gsub(achievement, "[%[/%]]", "")

		return false, string_format(self.output.achievement, player_name, achievement), author, ...
	end
end

Module.OnInitialize = function(self)
	self.output = ns:GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true

	ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil

	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_ACHIEVEMENT", self.OnChatEventProxy)
end
