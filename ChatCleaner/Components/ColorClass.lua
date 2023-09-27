local Addon, ns = ...

local Module = ns:NewModule("ClassColors")

-- GLOBALS: UnitFactionGroup

-- Lua API
local pairs = pairs
local table_insert = table.insert

Module.OnInitialize = function(self)
	self.replacements = {}
	local ignored
	if (ns.IsClassic) then
		local faction = UnitFactionGroup("player")
		ignored = (faction == "Alliance") and "SHAMAN" or (faction == "Horde") and "PALADIN"
	end
	local Colors = ns.Colors
	for class,color in pairs(Colors.blizzclass) do
		if (class ~= ignored) then
			table_insert(self.replacements, { color.colorCode, Colors.class[class].colorCode })
		end
	end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ns:AddReplacementSet(self.replacements, true)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ns:RemoveReplacementSet(self.replacements)
end


