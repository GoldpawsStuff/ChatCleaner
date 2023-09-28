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
local string_match = string.match
local table_insert = table.insert


Module.OnInitialize = function(self)

	-- WoW Globals
	local CHAT_BATTLEGROUND_GET = CHAT_BATTLEGROUND_GET
	local CHAT_BATTLEGROUND_LEADER_GET = CHAT_BATTLEGROUND_LEADER_GET
	local CHAT_GUILD_GET = CHAT_GUILD_GET
	local CHAT_INSTANCE_CHAT_GET = CHAT_INSTANCE_CHAT_GET
	local CHAT_INSTANCE_CHAT_LEADER_GET = CHAT_INSTANCE_CHAT_LEADER_GET
	local CHAT_PARTY_GET = CHAT_PARTY_GET
	local CHAT_PARTY_LEADER_GET = CHAT_PARTY_LEADER_GET
	local CHAT_RAID_GET = CHAT_RAID_GET
	local CHAT_RAID_LEADER_GET = CHAT_RAID_LEADER_GET
	local CHAT_RAID_WARNING_GET = CHAT_RAID_WARNING_GET
	local CHAT_OFFICER_GET = CHAT_OFFICER_GET

	self.replacements = {}

	if (ns.IsClassic) then
		table_insert(self.replacements, {"%["..string_match(CHAT_BATTLEGROUND_LEADER_GET, "%[(.-)%]") .. "%]", L["BGL"]})
		table_insert(self.replacements, {"%["..string_match(CHAT_BATTLEGROUND_GET, "%[(.-)%]") .. "%]", L["BG"]})
	end

	table_insert(self.replacements, {"%["..string_match(CHAT_PARTY_LEADER_GET, "%[(.-)%]") .. "%]", L["PL"]})
	table_insert(self.replacements, {"%["..string_match(CHAT_PARTY_GET, "%[(.-)%]") .. "%]", L["P"]})
	table_insert(self.replacements, {"%["..string_match(CHAT_RAID_LEADER_GET, "%[(.-)%]") .. "%]", L["RL"]})
	table_insert(self.replacements, {"%["..string_match(CHAT_RAID_GET, "%[(.-)%]") .. "%]", L["R"]})
	table_insert(self.replacements, {"%["..string_match(CHAT_INSTANCE_CHAT_LEADER_GET, "%[(.-)%]") .. "%]", L["IL"]})
	table_insert(self.replacements, {"%["..string_match(CHAT_INSTANCE_CHAT_GET, "%[(.-)%]") .. "%]", L["I"]})
	table_insert(self.replacements, {"%["..string_match(CHAT_GUILD_GET, "%[(.-)%]") .. "%]", L["G"]})
	table_insert(self.replacements, {"%["..string_match(CHAT_OFFICER_GET, "%[(.-)%]") .. "%]", L["O"]})
	table_insert(self.replacements, {"%["..string_match(CHAT_RAID_WARNING_GET, "%[(.-)%]") .. "%]", "|cffff0000!|r"})

	-- Turns "[1. General - The Barrens]" into "General"
	--table_insert(self.replacements, {"|Hchannel:(.-):(%d+)|h%[(%d)%. (.-)(%s%-%s.-)%]|h", "|Hchannel:%1:%2|h%4.|h"})

	-- Turns "[1. General - The Barrens]" into "1."
	--table_insert(self.replacements, {"|Hchannel:(.-):(%d+)|h%[(.-)%]|h", "|Hchannel:%1:%2|h%2.|h"})
	table_insert(self.replacements, {"|Hchannel:(.-):(%d+)|h%[(%d)%. (.-)(%s%-%s.-)%]|h", "|Hchannel:%1:%2|h%3.|h"})

	--table_insert(self.replacements, {"|Hchannel:(%w+):(%d+)|h%[(%d)%. (%w+)%]|h", "|Hchannel:%1:%2|h%3.|h"})
	--table_insert(self.replacements, {"|Hchannel:(%w+)|h%[(%w+)%]|h", "|Hchannel:%1|h%2|h"})

end

Module.OnEnable = function(self)
	self.filterEnabled = true

	ns:AddReplacementSet(self.replacements, true)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil

	ns:RemoveReplacementSet(self.replacements)
end
