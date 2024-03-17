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

local Module = ns:NewModule("Channels")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_gsub = string.gsub
local string_match = string.match
local table_insert = table.insert

-- WoW Globals
local G = {
	CHAT_BATTLEGROUND_GET = CHAT_BATTLEGROUND_GET,
	CHAT_BATTLEGROUND_LEADER_GET = CHAT_BATTLEGROUND_LEADER_GET,
	CHAT_GUILD_GET = CHAT_GUILD_GET,
	CHAT_INSTANCE_CHAT_GET = CHAT_INSTANCE_CHAT_GET,
	CHAT_INSTANCE_CHAT_LEADER_GET = CHAT_INSTANCE_CHAT_LEADER_GET,
	CHAT_PARTY_GET = CHAT_PARTY_GET,
	CHAT_PARTY_LEADER_GET = CHAT_PARTY_LEADER_GET,
	CHAT_RAID_GET = CHAT_RAID_GET,
	CHAT_RAID_LEADER_GET = CHAT_RAID_LEADER_GET,
	CHAT_RAID_WARNING_GET = CHAT_RAID_WARNING_GET,
	CHAT_OFFICER_GET = CHAT_OFFICER_GET,
	CHAT_YOU_CHANGED_NOTICE =  CHAT_YOU_CHANGED_NOTICE, -- "Changed Channel: |Hchannel:%d|h[%s]|h"
	CHAT_YOU_CHANGED_NOTICE_BN =  CHAT_YOU_CHANGED_NOTICE_BN, -- "Changed Channel: |Hchannel:CHANNEL:%d|h[%s]|h"
}

-- Convert a WoW global string to a search pattern
local makePattern = function(msg)
	msg = string_gsub(msg, "%%([%d%$]-)d", "(%%d+)")
	msg = string_gsub(msg, "%%([%d%$]-)s", "(.+)")
	msg = string_gsub(msg, "%[", "%%[")
	msg = string_gsub(msg, "%]", "%%]")
	return msg
end


-- Search Pattern Cache.
-- This will generate the pattern on the first lookup.
local P = setmetatable({}, { __index = function(t,k)
	rawset(t,k,makePattern(k))
	return rawget(t,k)
end })

Module.OnInitialize = function(self)

	self.replacements = {}

	if (ns.IsClassic) then
		table_insert(self.replacements, {"%["..string_match(G.CHAT_BATTLEGROUND_LEADER_GET, "%[(.-)%]") .. "%]", L["BGL"]})
		table_insert(self.replacements, {"%["..string_match(G.CHAT_BATTLEGROUND_GET, "%[(.-)%]") .. "%]", L["BG"]})
	end

	table_insert(self.replacements, {"%["..string_match(G.CHAT_PARTY_LEADER_GET, "%[(.-)%]") .. "%]", L["PL"]})
	table_insert(self.replacements, {"%["..string_match(G.CHAT_PARTY_GET, "%[(.-)%]") .. "%]", L["P"]})
	table_insert(self.replacements, {"%["..string_match(G.CHAT_RAID_LEADER_GET, "%[(.-)%]") .. "%]", L["RL"]})
	table_insert(self.replacements, {"%["..string_match(G.CHAT_RAID_GET, "%[(.-)%]") .. "%]", L["R"]})
	table_insert(self.replacements, {"%["..string_match(G.CHAT_INSTANCE_CHAT_LEADER_GET, "%[(.-)%]") .. "%]", L["IL"]})
	table_insert(self.replacements, {"%["..string_match(G.CHAT_INSTANCE_CHAT_GET, "%[(.-)%]") .. "%]", L["I"]})
	table_insert(self.replacements, {"%["..string_match(G.CHAT_GUILD_GET, "%[(.-)%]") .. "%]", L["G"]})
	table_insert(self.replacements, {"%["..string_match(G.CHAT_OFFICER_GET, "%[(.-)%]") .. "%]", L["O"]})
	table_insert(self.replacements, {"%["..string_match(G.CHAT_RAID_WARNING_GET, "%[(.-)%]") .. "%]", "|cffff0000!|r"})

	-- Turns "[1. General - The Barrens]" into "General"
	--table_insert(self.replacements, {"|Hchannel:(.-):(%d+)|h%[(%d)%. (.-)(%s%-%s.-)%]|h", "|Hchannel:%1:%2|h%4.|h"})

	-- Turns "[1. General - The Barrens]" into "1."
	--table_insert(self.replacements, {"|Hchannel:(.-):(%d+)|h%[(.-)%]|h", "|Hchannel:%1:%2|h%2.|h"})
	table_insert(self.replacements, {"|Hchannel:(.-):(%d+)|h%[(%d)%. (.-)(%s%-%s.-)%]|h", "|Hchannel:%1:%2|h%3.|h"})

	--table_insert(self.replacements, {"|Hchannel:(%w+):(%d+)|h%[(%d)%. (%w+)%]|h", "|Hchannel:%1:%2|h%3.|h"})
	--table_insert(self.replacements, {"|Hchannel:(%w+)|h%[(%w+)%]|h", "|Hchannel:%1|h%2|h"})

	-- Make sure these filters only apply
	-- when the channel name is at the start of the message.
	-- This is to prevent false positives when changing zone channels.
	for i,set in next,self.replacements do
		self.replacements[i][1] = "^"..self.replacements[i][1]
	end
end

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)

	local joined = string_match(msg,P[G.CHAT_YOU_CHANGED_NOTICE])
	if (joined) then
		return true
	end

end

local onAddMessageProxy = function(...)
	return Module:OnAddMessage(...)
end

Module.OnEnable = function(self)
	self:RegisterBlacklistFilter(onAddMessageProxy)
	self:RegisterMessageReplacement(self.replacements, true)
end

Module.OnDisable = function(self)
	self:UnregisterBlacklistFilter(onAddMessageProxy)
	self:UnregisterMessageReplacement(self.replacements)
end
