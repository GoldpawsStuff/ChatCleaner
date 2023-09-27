local Addon, ns = ...

local Module = ns:NewModule("QualityColors")

-- Lua API
local pairs = pairs
local table_insert = table.insert

Module.OnInitialize = function(self)
	self.replacements = {}
	local Colors = ns.Colors
	for i,color in pairs(Colors.blizzquality) do
		table_insert(self.replacements, { color.colorCode, Colors.quality[i].colorCode })
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
