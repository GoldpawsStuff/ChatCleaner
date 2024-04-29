--[[

	The MIT License (MIT)

	Copyright (c) 2024 Lars Norberg

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

local Module = ns:NewModule("Status")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local CLEARED_AFK = CLEARED_AFK -- "You are no longer AFK."
local CLEARED_DND = CLEARED_DND -- "You are no longer marked DND."
local DEFAULT_AFK_MESSAGE = DEFAULT_AFK_MESSAGE -- "Away from Keyboard"
local DEFAULT_DND_MESSAGE = DEFAULT_DND_MESSAGE -- "Do not Disturb"
local MARKED_AFK = MARKED_AFK -- "You are now AFK."
local MARKED_AFK_MESSAGE = MARKED_AFK_MESSAGE -- "You are now AFK: %s"
local MARKED_DND = MARKED_DND -- "You are now DND: %s."
local EXHAUSTION_NORMAL = ERR_EXHAUSTION_NORMAL -- "You feel normal."
local EXHAUSTION_WELLRESTED = ERR_EXHAUSTION_WELLRESTED -- "You feel well rested."

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

	-- AFK
	if (message == MARKED_AFK) then
		return false, ns.out.afk_added, author, ...
	end
	if (message == CLEARED_AFK) then
		return false, ns.out.afk_cleared, author, ...
	end
	local afk_message = string_match(message, P[MARKED_AFK_MESSAGE])
	if (afk_message) then
		if (afk_message == DEFAULT_AFK_MESSAGE) then
			return false, ns.out.afk_added, author, ...
		end
		return false, string_format(ns.out.afk_added_message, afk_message), author, ...
	end

	-- DND
	if (message == CLEARED_DND) then
		return false, ns.out.dnd_cleared, author, ...
	end
	local dnd_message = string_match(message, P[MARKED_DND] )
	if (dnd_message) then
		if (dnd_message == DEFAULT_DND_MESSAGE) then
			return false, ns.out.dnd_added, author, ...
		end
		return false, string_format(ns.out.dnd_added_message, dnd_message), author, ...
	end

	-- Rested TODO: Move to XP!
	if (message == EXHAUSTION_WELLRESTED) then
		return false, ns.out.rested_added, author, ...
	end
	if (message == EXHAUSTION_NORMAL) then
		return false, ns.out.rested_cleared, author, ...
	end

end

local onChatEventProxy = function(...)
	return Module:OnChatEvent(...)
end

Module.OnEnable = function(self)
	self:RegisterMessageEventFilter("CHAT_MSG_SYSTEM", onChatEventProxy)
end

Module.OnDisable = function(self)
	self:UnregisterMessageEventFilter("CHAT_MSG_SYSTEM", onChatEventProxy)
end
