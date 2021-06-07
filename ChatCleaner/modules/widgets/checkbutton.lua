local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local GUI = Core:GetModule("GUI")
if (not GUI) then
	return
end

local Update = function(self, ...)
end

local Enable = function(self)
end

local Disable = function(self)
end

local Create = function(self)
end

GUI:RegisterWidget("CheckButton", Create, Enable, Disable, Update)