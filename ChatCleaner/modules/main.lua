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
local setmetatable = setmetatable
local string_gsub = string.gsub
local table_insert = table.insert
local unpack = unpack

-- WoW API
local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame
local hooksecurefunc = hooksecurefunc

-- WoW Objects
local CHAT_FRAMES = CHAT_FRAMES

-- WoW Globals
local FRIENDS_LIST_AWAY = FRIENDS_LIST_AWAY
local FRIENDS_LIST_BUSY = FRIENDS_LIST_BUSY
local TUTORIAL_TITLE26 = TUTORIAL_TITLE26

Core.AddMessageFiltered = function(self, chatFrame, msg, r, g, b, chatID, ...)
	if (not msg) or (msg == "") then
		return
	end
	if (next(self.blacklist)) then
		if (self.blacklist(chatFrame, msg, r, g, b, chatID, ...)) then
			return
		end
	end
	if (next(self.replacements)) then
		msg = self.replacements(msg)
	end
	return self.MethodCache[chatFrame](chatFrame, msg, r, g, b, chatID, ...)
end

Core.CacheMessageMethod = function(self, chatFrame)
	if (not self.MethodCache) then
		self.MethodCache = {}
	end
	if (not self.MethodCache[chatFrame]) then
		-- Copy the current AddMessage method from the frame.
		-- *this also functions as our "has been handled" indicator.
		self.MethodCache[chatFrame] = chatFrame.AddMessage
	end
	-- Replace with our filtered AddMessage method.
	chatFrame.AddMessage = function(...) self:AddMessageFiltered(...) end
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

Core.AddReplacementSet = function(self, tbl)
	for _,intbl in next,self.replacements do
		if (intbl == tbl) then 
			return 
		end
	end
	table_insert(self.replacements, tbl)
end

Core.RemoveReplacementSet = function(self, tbl)
	for k,intbl in next,self.replacements do
		if (intbl == tbl) then
			self.replacements[k] = nil
			break
		end
	end
end

Core.CacheAllMessageMethods = function(self)
	for _,chatFrameName in ipairs(CHAT_FRAMES) do 
		self:CacheMessageMethod(_G[chatFrameName]) 
	end
	hooksecurefunc("FCF_OpenTemporaryWindow", function() self:CacheMessageMethod((FCF_GetCurrentChatFrame())) end)
end

Core.GetOutputTemplates = function(self)
	return self.output
end

Core.GetLocale = function(self) 
	return L 
end

Core.OnEvent = function(self, event, ...)
end

Core.OnInit = function(self)
	self.db = db

	self.output = {}
	self.output.achievement = "|cffeaeaea!|r%s: %s"
	self.output.item_single = "|cff888888+|r %s"
	self.output.item_multiple = "|cff888888+|r %s |cffeaeaea(%d)|r"
	self.output.item_deficit = "|cffcc4444- %s|r"
	self.output.item_transfer = "|cff888888+|r |cffeaeaea%s:|r %s"
	self.output.money = self.output.item_single
	self.output.money_deficit = "|cff888888-|r %s"
	self.output.objective_status = "|cff888888+|r |cffeaeaea%s:|r |cffffb200%s|r"
	self.output.standing = "|cff888888+|r |cfff0f0f0".."%d|r |cffeaeaea%s:|r %s"
	self.output.standing_generic = "|cff888888+ %s:|r %s"
	self.output.standing_deficit = "|cffcc4444-|r |cfff0f0f0".."%d|r |cffeaeaea%s:|r %s"
	self.output.standing_deficit_generic = "|cffcc4444- %s:|r %s"
	self.output.xp_named = "|cff888888+|r |cfff0f0f0%d|r |cffeaeaea%s:|r |cffffb200%s|r"
	self.output.xp_unnamed = "|cff888888+|r |cfff0f0f0%d|r |cffeaeaea%s|r"
	self.output.xp_levelup = "|cffeaeaea!|r%s|cffeaeaea!|r"
	self.output.afk_added = "|cffffb200+ "..FRIENDS_LIST_AWAY.."|r"
	self.output.afk_added_message = "|cffffb200+ "..FRIENDS_LIST_AWAY..": |r|cfff0f0f0%s|r"
	self.output.afk_cleared = "|cff00cc00- "..FRIENDS_LIST_AWAY.."|r"
	self.output.dnd_added = "|cffff6600+ "..FRIENDS_LIST_BUSY.."|r"
	self.output.dnd_added_message = "|cffff6600+ "..FRIENDS_LIST_BUSY..": |r|cfff0f0f0%s|r"
	self.output.dnd_cleared = "|cff00cc00- "..FRIENDS_LIST_BUSY.."|r"
	self.output.rested_added = "|cff888888+ "..TUTORIAL_TITLE26.."|r"
	self.output.rested_cleared = "|cffffb200- "..TUTORIAL_TITLE26.."|r"
	
	self.blacklist = setmetatable({}, {
		__call = function(funcs, ...)
			for _,func in next,funcs do
				if (func(...)) then
					return true
				end
			end
		end
	})

	self.replacements = setmetatable({}, {
		__call = function(sets, msg)
			for i,set in next,sets do
				for k,data in ipairs(set) do
					msg = string_gsub(msg, unpack(data))
				end
			end
			return msg
		end
	})
end

Core.OnEnable = function(self)
	self:CacheAllMessageMethods()
end

