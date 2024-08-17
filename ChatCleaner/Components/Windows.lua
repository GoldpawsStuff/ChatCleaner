--[[

	The MIT License (MIT)

	Copyright (c) 2024 Lars Norberg

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

-- NOT YET IMPLEMENTED!
do return end

-- WoW 11.0.x
local GetAddOnEnableState = GetAddOnEnableState or function(character, name) return C_AddOns.GetAddOnEnableState(name, character) end
local GetAddOnInfo = GetAddOnInfo or C_AddOns.GetAddOnInfo
local GetNumAddOns = GetNumAddOns or C_AddOns.GetNumAddOns

-- Just bail out completely if this module isn't supported.
if ((function(...)
	for i = 1,GetNumAddOns() do
		local name, _, _, loadable = GetAddOnInfo(i)
		for j = 1, select("#", ...) do
			local addon = select(j, ...)
			if (name == addon) then
				return (loadable and not(GetAddOnEnableState(UnitName("player"), i) == 0))
			end
		end
	end
end)("AzeriteUI","TukUI","ElvUI","KkthnxUI","Prat-3.0","ls_Glass")) then
	return
end

-- GLOBALS: CHAT_FONT_HEIGHTS

local Module = ns:NewModule("Windows", "LibMoreEvents-1.0")

Module.UpdateButtons = function(self, event, ...)
end

Module.StyleFrame = function(self)
end

Module.OnEvent = function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		local isInitialLogin, isReloadingUi = ...
		if (isInitialLogin or isReloadingUi) then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
		end
	end
end

Module.OnInitialize = function(self)

	-- Add more font sizes.
	for i = #CHAT_FONT_HEIGHTS, 1, -1 do
		CHAT_FONT_HEIGHTS[i] = nil
	end
	for i,v in ipairs({ 12, 14, 16, 18, 20, 22, 24, 28, 32 }) do
		CHAT_FONT_HEIGHTS[i] = v
	end

end

Module.OnEnable = function(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
end
