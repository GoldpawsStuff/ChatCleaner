local Addon, ns = ...

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
