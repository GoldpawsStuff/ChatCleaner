local Addon, Private = ...

-- Lua API
local pairs = pairs
local string_match = string.match

-- Private API
local Colors = Private.Colors
local L = Private.L

-- Player Info
local PlayerFaction, PlayerFactionLabel = UnitFactionGroup("player")

-- Player names
Private:RegisterReplacement("Players", "|Hplayer:(.-)-(.-):(.-)|h%[|c(%w%w%w%w%w%w%w%w)(.-)-(.-)|r%]|h", "|Hplayer:%1-%2:%3|h|c%4%5|r|h")
Private:RegisterReplacement("Players", "|Hplayer:(.-)-(.-):(.-)|h|c(%w%w%w%w%w%w%w%w)(.-)-(.-)|r|h", "|Hplayer:%1-%2:%3|h|c%4%5|r|h")
Private:RegisterReplacement("Players", "|Hplayer:(.-)|h%[(.-)%]|h", "|Hplayer:%1|h%2|h")
Private:RegisterReplacement("Players", "|HBNplayer:(.-)|h%[(.-)%]|h", "|HBNplayer:%1|h%2|h")

if (Private.IsClassic) then
	Private:RegisterReplacement("Channels", "%["..string_match(CHAT_BATTLEGROUND_LEADER_GET, "%[(.-)%]") .. "%]", L["BGL"])
	Private:RegisterReplacement("Channels", "%["..string_match(CHAT_BATTLEGROUND_GET, "%[(.-)%]") .. "%]", L["BG"])
end

Private:RegisterReplacement("Channels", "%["..string_match(CHAT_PARTY_LEADER_GET, "%[(.-)%]") .. "%]", L["PL"])
Private:RegisterReplacement("Channels", "%["..string_match(CHAT_PARTY_GET, "%[(.-)%]") .. "%]", L["P"])
Private:RegisterReplacement("Channels", "%["..string_match(CHAT_RAID_LEADER_GET, "%[(.-)%]") .. "%]", L["RL"])
Private:RegisterReplacement("Channels", "%["..string_match(CHAT_RAID_GET, "%[(.-)%]") .. "%]", L["R"])
Private:RegisterReplacement("Channels", "%["..string_match(CHAT_INSTANCE_CHAT_LEADER_GET, "%[(.-)%]") .. "%]", L["IL"])
Private:RegisterReplacement("Channels", "%["..string_match(CHAT_INSTANCE_CHAT_GET, "%[(.-)%]") .. "%]", L["I"])
Private:RegisterReplacement("Channels", "%["..string_match(CHAT_GUILD_GET, "%[(.-)%]") .. "%]", L["G"])
Private:RegisterReplacement("Channels", "%["..string_match(CHAT_OFFICER_GET, "%[(.-)%]") .. "%]", L["O"])
Private:RegisterReplacement("Channels", "%["..string_match(CHAT_RAID_WARNING_GET, "%[(.-)%]") .. "%]", "|cffff0000!|r")
Private:RegisterReplacement("Channels", "|Hchannel:(%w+):(%d)|h%[(%d)%. (%w+)%]|h", "|Hchannel:%1:%2|h%3.|h") -- numbered channels
Private:RegisterReplacement("Channels", "|Hchannel:(%w+)|h%[(%w+)%]|h", "|Hchannel:%1|h%2|h") -- nonnumbered channels

-- Item quality colors
for i,color in pairs(Colors.blizzquality) do
	Private:RegisterReplacement("Colors", color.colorCode, Colors.quality[i].colorCode)
end

-- Class colors
for i,color in pairs(Colors.blizzquality) do
	for i,color in pairs(Colors.blizzclass) do
		local skip = Private.IsClassic and ((PlayerFaction == "Alliance" and i == "SHAMAN") or (PlayerFaction == "Horde" and i == "PALADIN"))
		if (not skip) then
			Private:RegisterReplacement("Colors", color.colorCode, Colors.class[i].colorCode)
		end
	end
end