local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("ClassColors")

-- Lua API
local pairs = pairs
local table_insert = table.insert

-- WoW API
local UnitFactionGroup = UnitFactionGroup

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.replacements = {}
	local ignored
	if (Private.IsClassic) then
		local faction = UnitFactionGroup("player")
		ignored = (faction == "Alliance") and "SHAMAN" or (faction == "Horde") and "PALADIN"
	end
	local Colors = Private.Colors
	for class,color in pairs(Colors.blizzclass) do
		if (class ~= ignored) then
			table_insert(self.replacements, { color.colorCode, Colors.class[class].colorCode })
		end
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


