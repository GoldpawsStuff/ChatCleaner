--[[

	The MIT License (MIT)

	Copyright (c) 2023 Lars Norberg

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]]
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
	self:RegisterMessageReplacement(self.replacements, true)
end

Module.OnDisable = function(self)
	self:UnregisterMessageReplacement(self.replacements)
end


