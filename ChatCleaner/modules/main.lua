local Addon, Private = ...
local Core = Private:NewModule("Core")

-- Default settings.
-----------------------------------------------------------
local db = (function(db) _G[Addon.."_DB"] = db; return db end)({
	
})

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
	["enUS"] = {
		-- These are chat channel abbreviations.
		-- For the most part these match the /slash command to type in these channels, 
		-- so unless that command is something else in different regions, don't localize it!
		["BGL"] = true, 	-- Battleground Leader (WoW Classic)
		["BG"] = true, 		-- Battleground (WoW Classic)
		["PL"] = true, 		-- Party Leader
		["P"] = true, 		-- Party
		["RL"] = true, 		-- Raid Leader
		["R"] = true, 		-- Raid
		["IL"] = true, 		-- Instance Leader (WoW Retail)
		["I"] = true, 		-- Instance (WoW Retail)
		["G"] = true, 		-- Guild
		["O"] = true 		-- Officer
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
local ipairs = ipairs
local next = next
local table_insert = table.insert

-- WoW API
local hooksecurefunc = hooksecurefunc

-- WoW Objects
local CHAT_FRAMES = CHAT_FRAMES

Core.AddMessageFiltered = function(self, frame, msg, r, g, b, chatID, ...)
	if (not msg) or (msg == "") then
		return
	end
	if (next(self.blacklist)) then
		if (self.blacklist(self, frame, msg, r, g, b, chatID, ...)) then
			return
		end
	end
	return self.MethodCache[frame](frame, msg, r, g, b, chatID, ...)
end

Core.CacheMessageMethod = function(self, frame)
	if (not self.MethodCache) then
		self.MethodCache = {}
	end
	if (not self.MethodCache[frame]) then
		-- Copy the current AddMessage method from the frame.
		-- *this also functions as our "has been handled" indicator.
		self.MethodCache[frame] = frame.AddMessage
	end
	-- Replace with our filtered AddMessage method.
	frame.AddMessage = function(...) self:AddMessageFiltered(...) end
end

Core.AddBlacklistMethod = function(self, func)
	for _,infunc in next,self.blacklist do
		if (infunc == func) then 
			return 
		end
	end
	table_insert(self.blacklist, func)
end

Core.RemoveBlacklistMethod = function(self, func)
	for k,infunc in next,self.blacklist do
		if (infunc == func) then
			self.blacklist[k] = nil
			break
		end
	end
end

Core.RegisterReplacement = function(self, groupID, pattern, ...)
	if (not self.Replacements) then
		self.Replacements = {}
	end
	table_insert(self.Replacements, { groupID, pattern, ... })
end

Core.EnableReplacement = function(self, groupID)
	if (not self.ReplacementStatus) then
		self.ReplacementStatus = {}
	end
	self.ReplacementStatus[groupID] = true
end

Core.DisableReplacement = function(self, groupID)
	local enabled = self.ReplacementStatus and self.ReplacementStatus[groupID]
	if (not enabled) then
		return
	end
	self.ReplacementStatus[groupID] = nil
end

Core.CacheAllMessageMethods = function(self)
	for _,chatFrameName in ipairs(CHAT_FRAMES) do 
		self:CacheMessageMethod(_G[chatFrameName]) 
	end
	hooksecurefunc("FCF_OpenTemporaryWindow", function() self:CacheMessageMethod((FCF_GetCurrentChatFrame())) end)
end

Core.OnEvent = function(self, event, ...)
end

Core.OnInit = function(self)
	self.db = db
	self.blacklist = setmetatable({}, {
		__call = function(funcs, ...)
			for _,func in next,funcs do
				if (func(...)) then
					return true
				end
			end
		end
	})
end

Core.OnEnable = function(self)
	self:CacheAllMessageMethods()
end

