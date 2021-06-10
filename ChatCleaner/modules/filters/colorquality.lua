local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("QualityColors")

-- Lua API
local pairs = pairs
local table_insert = table.insert

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.replacements = {}
	local Colors = Private.Colors
	for i,color in pairs(Colors.blizzquality) do
		table_insert(self.replacements, { color.colorCode, Colors.quality[i].colorCode })
	end
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
