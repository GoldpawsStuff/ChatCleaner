local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("QualityColors")

Module.OnInit = function(self)
end

Module.OnEnable = function(self)
end

local Colors = Private.Colors

-- Item quality colors
--for i,color in pairs(Colors.blizzquality) do
--	Private:RegisterReplacement("LOW", "ColorQuality", color.colorCode, Colors.quality[i].colorCode)
--end
