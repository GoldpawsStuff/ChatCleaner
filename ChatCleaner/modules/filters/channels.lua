local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Channels")

Module.OnInit = function(self)
end

Module.OnEnable = function(self)
end

--local string_match = string.match
--local L = Private.L
--
--if (Private.IsClassic) then
--	Private:RegisterReplacement("Channels", "%["..string_match(CHAT_BATTLEGROUND_LEADER_GET, "%[(.-)%]") .. "%]", L["BGL"])
--	Private:RegisterReplacement("Channels", "%["..string_match(CHAT_BATTLEGROUND_GET, "%[(.-)%]") .. "%]", L["BG"])
--end
--
--Private:RegisterReplacement("Channels", "%["..string_match(CHAT_PARTY_LEADER_GET, "%[(.-)%]") .. "%]", L["PL"])
--Private:RegisterReplacement("Channels", "%["..string_match(CHAT_PARTY_GET, "%[(.-)%]") .. "%]", L["P"])
--Private:RegisterReplacement("Channels", "%["..string_match(CHAT_RAID_LEADER_GET, "%[(.-)%]") .. "%]", L["RL"])
--Private:RegisterReplacement("Channels", "%["..string_match(CHAT_RAID_GET, "%[(.-)%]") .. "%]", L["R"])
--Private:RegisterReplacement("Channels", "%["..string_match(CHAT_INSTANCE_CHAT_LEADER_GET, "%[(.-)%]") .. "%]", L["IL"])
--Private:RegisterReplacement("Channels", "%["..string_match(CHAT_INSTANCE_CHAT_GET, "%[(.-)%]") .. "%]", L["I"])
--Private:RegisterReplacement("Channels", "%["..string_match(CHAT_GUILD_GET, "%[(.-)%]") .. "%]", L["G"])
--Private:RegisterReplacement("Channels", "%["..string_match(CHAT_OFFICER_GET, "%[(.-)%]") .. "%]", L["O"])
--Private:RegisterReplacement("Channels", "%["..string_match(CHAT_RAID_WARNING_GET, "%[(.-)%]") .. "%]", "|cffff0000!|r")
--Private:RegisterReplacement("Channels", "|Hchannel:(%w+):(%d)|h%[(%d)%. (%w+)%]|h", "|Hchannel:%1:%2|h%3.|h") -- numbered channels
--Private:RegisterReplacement("Channels", "|Hchannel:(%w+)|h%[(%w+)%]|h", "|Hchannel:%1|h%2|h") -- nonnumbered channels
