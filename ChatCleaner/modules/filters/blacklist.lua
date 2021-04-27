local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Blacklist")

Module.OnInit = function(self)
end

Module.OnEnable = function(self)
end
