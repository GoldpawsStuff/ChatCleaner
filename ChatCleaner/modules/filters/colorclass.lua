local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("ClassColors")

Module.OnInit = function(self)
end

Module.OnEnable = function(self)
end

--local Colors = Private.Colors
--local PlayerFaction = UnitFactionGroup("player")
--
---- Class colors
--for i,color in pairs(Colors.blizzquality) do
--	for i,color in pairs(Colors.blizzclass) do
--		local skip = Private.IsClassic and ((PlayerFaction == "Alliance" and i == "SHAMAN") or (PlayerFaction == "Horde" and i == "PALADIN"))
--		if (not skip) then
--			Private:RegisterReplacement("LOW", "ColorClass", color.colorCode, Colors.class[i].colorCode)
--		end
--	end
--end