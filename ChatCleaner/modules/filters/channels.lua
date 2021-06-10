local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Channels")

-- Lua API
local string_match = string.match
local table_insert = table.insert

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

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.replacements = {}

	local L = self:GetParent():GetLocale()
	if (Private.IsClassic) then
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
	table_insert(self.replacements, {"|Hchannel:(%w+):(%d)|h%[(%d)%. (%w+)%]|h", "|Hchannel:%1:%2|h%3.|h"})
	table_insert(self.replacements, {"|Hchannel:(%w+)|h%[(%w+)%]|h", "|Hchannel:%1|h%2|h"})

	if (self.db["DisableFilter:"..self:GetName()]) then
		return self:SetUserDisabled()
	end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	self:GetParent():AddReplacementSet(self.replacements)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self:GetParent():RemoveReplacementSet(self.replacements)
end
