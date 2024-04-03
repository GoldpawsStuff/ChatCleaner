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

local Module = ns:NewModule("Quests")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

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
	SET_COMPLETE = ERR_COMPLETED_TRANSMOG_SET_S, -- "You've completed the set %s."
	QUEST_ACCEPTED = ERR_QUEST_ACCEPTED_S, -- "Quest accepted: %s"
	QUEST_ALREADY_DONE = ERR_QUEST_ALREADY_DONE, -- "You have completed that quest.";
	QUEST_ALREADY_DONE_DAILY = ERR_QUEST_ALREADY_DONE_DAILY, -- "You have completed that daily quest today."
	QUEST_FAILED_TOO_MANY_DAILY = ERR_QUEST_FAILED_TOO_MANY_DAILY_QUESTS_I, -- "You have already completed %d daily quests today"
	NO_DAILY_QUESTS_REMAINING = NO_DAILY_QUESTS_REMAINING, -- "You cannot complete any more daily quests today."
	QUEST_COMPLETE = ERR_QUEST_COMPLETE_S, -- "%s completed."
	QUEST = BATTLE_PET_SOURCE_2, -- "Quest"
	ACCEPTED = CALENDAR_STATUS_ACCEPTED, -- "Accepted"
	COMPLETE = COMPLETE -- "Complete"
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

	local name

	-- Questie links. Only remove brackets.
	-- *Totally failed.
	--if (event == "CHAT_MSG_CHANNEL") then
	--
	--	name = string_match(message, "|Hquestie")
	--	if (name) then
	--		-- This replacement breaks Questie's links.
	-- 		-- I need to look into how their links are designed.
	--		name = string_gsub(name, "[%[/%]]", "")
	--		return false, name, author, ...
	--	end
	--
	--	return
	--end

	-- Adding completed transmog sets here,
	-- to make sure they don't fire as completed quests.
	name = string_match(message, P[G.SET_COMPLETE])
	if (name) then
		name = string_gsub(name, "[%[/%]]", "")
		return false, string_format(ns.out.set_complete, G.COMPLETE, name), author, ...
	end

	name = string_match(message, P[G.QUEST_ACCEPTED])
	if (name) then
		name = string_gsub(name, "[%[/%]]", "")
		return false, string_format(ns.out.quest_accepted, G.ACCEPTED, name), author, ...
	end


	-- Avoid false positives on quest completion.
	if (not string_match(message, P[G.QUEST_ALREADY_DONE]) and
		not string_match(message, P[G.QUEST_ALREADY_DONE_DAILY]) and
		not string_match(message, P[G.QUEST_FAILED_TOO_MANY_DAILY]) and
		not string_match(message, P[G.NO_DAILY_QUESTS_REMAINING])) then

		name = string_match(message, P[G.QUEST_COMPLETE])
		if (name) then
			name = string_gsub(name, "[%[/%]]", "")
			return false, string_format(ns.out.quest_complete, G.COMPLETE, name), author, ...
		end
	end

end

local onChatEventProxy = function(...)
	return Module:OnChatEvent(...)
end

Module.OnEnable = function(self)
	self:RegisterMessageEventFilter("CHAT_MSG_SYSTEM", onChatEventProxy)
	self:RegisterMessageEventFilter("CHAT_MSG_CHANNEL", onChatEventProxy)
end

Module.OnDisable = function(self)
	self:UnregisterMessageEventFilter("CHAT_MSG_SYSTEM", onChatEventProxy)
	self:UnregisterMessageEventFilter("CHAT_MSG_CHANNEL", onChatEventProxy)
end
