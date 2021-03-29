--[[

	The MIT License (MIT)

	Copyright (c) 2021 Lars Norberg

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
-- Retrive addon folder name, and our local, private namespace.
local Addon, Private = ...

-- Localization system.
-----------------------------------------------------------
-- Do not modify the function, 
-- just the locales in the table below!
local L = (function(tbl,defaultLocale) 
	local gameLocale = GetLocale() -- The locale currently used by the game client.
	local L = tbl[gameLocale] or tbl[defaultLocale] -- Get the localization for the current locale, or use your default.
	-- Replace the boolean 'true' with the key,
	-- to simplify locale creation and reduce space needed.
	for i in pairs(L) do 
		if (L[i] == true) then 
			L[i] = i
		end
	end 
	-- If the game client is in another locale than your default, 
	-- fill in any missing localization in the client's locale 
	-- with entries from your default locale.
	if (gameLocale ~= defaultLocale) then 
		for i,msg in pairs(tbl[defaultLocale]) do 
			if (not L[i]) then 
				-- Replace the boolean 'true' with the key,
				-- to simplify locale creation and reduce space needed.
				L[i] = (msg == true) and i or msg
			end
		end
	end
	return L
end)({ 
	-- ENTER YOUR LOCALIZATION HERE!
	-----------------------------------------------------------
	-- * Note that you MUST include a full table for your primary/default locale!
	-- * Entries where the value (to the right) is the boolean 'true',
	--   will use the key (to the left) as the value instead!
	["enUS"] = {

	},
	["deDE"] = {},
	["esES"] = {},
	["esMX"] = {},
	["frFR"] = {},
	["itIT"] = {},
	["koKR"] = {},
	["ptPT"] = {},
	["ruRU"] = {},
	["zhCN"] = {},
	["zhTW"] = {}
	
-- The primary/default locale of your addon.
-- * You should change this code to your default locale.
-- * Note that you MUST include a full table for your primary/default locale!
}, "enUS") 


-- Lua API
-----------------------------------------------------------
-- Upvalue any lua functions used here.


-- WoW API
-----------------------------------------------------------
-- Upvalue any WoW functions used here.


-- Your default settings.
-----------------------------------------------------------
-- Note that anything changed will be saved to disk
-- when you reload the user interface, or exit the game,
-- and those saved changes will override your defaults here.
-- * You should access saved settings by using db[key]
-- * Don't put frame handles or other widget references in here, 
--   just strings, numbers and booleans.
local db = (function(db) _G[Addon.."_DB"] = db; return db end)({

})


-- Utility Functions
-----------------------------------------------------------
-- Add utility functions like 
-- time formatting and similar here.


-- Callbacks
-----------------------------------------------------------
-- Add functions called multiple times 
-- by your reactive addon code here.


-- Addon Core
-----------------------------------------------------------
-- Your event handler.
-- Any events you add should be handled here.
Private.OnEvent = function(self, event, ...)
end

-- Initialization.
-- This fires when the addon and its settings are loaded.
Private.OnInit = function(self)
	-- Do any parsing of saved settings here.
	-- This is also a good place to create your frames and objects.
end

-- Enabling.
-- This fires when most of the user interface has been loaded
-- and most data is available to the user.
Private.OnEnable = function(self)
	-- Register your events here.
end


-- Setup the environment
-----------------------------------------------------------
(function(self)
	-- Private Default API
	-- This mostly contains methods we always want available
	-----------------------------------------------------------
	-- Proxy event registering to the addon namespace.
	Private.RegisterEvent = function(_, ...) self:RegisterEvent(...) end
	Private.RegisterUnitEvent = function(_, ...) self:RegisterUnitEvent(...) end
	Private.UnregisterEvent = function(_, ...) self:UnregisterEvent(...) end
	Private.UnregisterAllEvents = function(_, ...) self:UnregisterAllEvents(...) end
	Private.IsEventRegistered = function(_, ...) self:IsEventRegistered(...) end
	-- This method lets you check if an addon WILL be loaded regardless of whether or not it currently is. 
	-- This is useful if you want to check if an addon interacting with yours is enabled. 
	-- My philosophy is that it's best to avoid addon dependencies in the toc file, 
	-- unless your addon is a plugin to another addon, that is.
	Private.IsAddOnEnabled = function(self, addon)
		for i = 1,GetNumAddOns() do
			if (string.lower((GetAddOnInfo(i))) == string.lower(addon)) then
				if (GetAddOnEnableState(UnitName("player"), i) ~= 0) then
					return true
				end
			end
		end
	end

	-- Event Dispatcher and Initialization Handler
	-----------------------------------------------------------
	-- Assign our event script handler, 
	-- which runs our initialization methods,
	-- and dispatches event to the addon namespace.
	self:RegisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", function(self, event, ...) 
		if (event == "ADDON_LOADED") then
			-- Nothing happens before this has fired for your addon.
			-- When it fires, we remove the event listener 
			-- and call our initialization method.
			if ((...) == Addon) then
				-- Delete our initial registration of this event.
				-- Note that you are free to re-register it in any of the 
				-- addon namespace methods. 
				self:UnregisterEvent("ADDON_LOADED")
				-- Call the initialization method.
				Private:OnInit()
				-- If this was a load-on-demand addon, 
				-- then we might be logged in already.
				-- If that is the case, directly run 
				-- the enabling method.
				if (IsLoggedIn()) then
					Private:OnEnable()
				else
					-- If this is a regular always-load addon, 
					-- we're not yet logged in, and must listen for this.
					self:RegisterEvent("PLAYER_LOGIN")
				end
				-- Return. We do not wish to forward the loading event 
				-- for our own addon to the namespace event handler.
				-- That is what the initialization method exists for.
				return
			end
		elseif (event == "PLAYER_LOGIN") then
			-- This event only ever fires once on a reload, 
			-- and anything you wish done at this event, 
			-- should be put in the namespace enable method.
			self:UnregisterEvent("PLAYER_LOGIN")
			-- Call the enabling method.
			Private:OnEnable()
			-- Return. We do not wish to forward this 
			-- to the namespace event handler.
			return 
		end
		-- Forward other events than our two initialization events
		-- to the addon namespace's event handler. 
		-- Note that you can always register more ADDON_LOADED
		-- if you wish to listen for other addons loading.  
		Private:OnEvent(event, ...) 
	end)
end)((function() return CreateFrame("Frame", nil, WorldFrame) end)())