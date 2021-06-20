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
		["O"] = true, 		-- Officer

		-- Will use a WoW global if it's available, but have a fallback if not.
		["Achievements"] = TRACKER_HEADER_ACHIEVEMENTS or "Achievements"

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
local ACCEPTED = CALENDAR_STATUS_ACCEPTED -- "Accepted"
local AUCTION_SOLD_MAIL = AUCTION_SOLD_MAIL_SUBJECT -- "Auction successful: %s"
local AUCTION_CANCELLED_MAIL = AUCTION_REMOVED_MAIL_SUBJECT -- "Auction cancelled: %s"
local AUCTION_CREATED = string_gsub(ERR_AUCTION_STARTED, "%.", "") -- "Auction created."
local AUCTION_REMOVED = string_gsub(ERR_AUCTION_REMOVED, "%.", "") -- "Auction cancelled."
local AWAY = FRIENDS_LIST_AWAY -- "Away"
local BUSY = FRIENDS_LIST_BUSY -- "Busy"
local COMPLETE = COMPLETE -- "Complete"
local RESTED = TUTORIAL_TITLE26 -- "Rested"

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
		msg = self.replacements(msg, r, g, b, chatID, ...)
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

Core.AddReplacementSet = function(self, set)
	for _,inset in next,self.replacements do
		if (inset == set) then 
			return 
		end
	end
	table_insert(self.replacements, set)
end

Core.RemoveReplacementSet = function(self, set)
	for k,inset in next,self.replacements do
		if (inset == set) then
			self.replacements[k] = nil
			break
		end
	end
end

Core.CacheAllMessageMethods = function(self)
	for _,chatFrameName in ipairs(CHAT_FRAMES) do 
		self:CacheMessageMethod(_G[chatFrameName]) 
	end
	if (not self.tempWindowsHooked) then
		self.tempWindowsHooked = true
		hooksecurefunc("FCF_OpenTemporaryWindow", function() self:CacheMessageMethod((FCF_GetCurrentChatFrame())) end)
	end
end

Core.GetOutputTemplates = function(self)
	return self.output
end

Core.GetSavedSettings = function(self)
	return db
end

Core.GetLocale = function(self) 
	return L 
end

Core.OnEvent = function(self, event, ...)
end

Core.OnInit = function(self)
	self.db = db

	-- Output patterns. 
	-- Let's add a simple color tag system for new strings as well. 
	self.output = setmetatable({}, { __newindex = function(t,k,msg) 
		msg = string_gsub(msg, "%*title%*", Private.Colors.title.colorCode)
		msg = string_gsub(msg, "%*white%*", Private.Colors.highlight.colorCode)
		msg = string_gsub(msg, "%*offwhite%*", Private.Colors.offwhite.colorCode)
		msg = string_gsub(msg, "%*palered%*", Private.Colors.palered.colorCode)
		msg = string_gsub(msg, "%*red%*", Private.Colors.quest.red.colorCode)
		msg = string_gsub(msg, "%*orange%*", Private.Colors.quest.orange.colorCode)
		msg = string_gsub(msg, "%*yellow%*", Private.Colors.quest.yellow.colorCode)
		msg = string_gsub(msg, "%*green%*", Private.Colors.quest.green.colorCode)
		msg = string_gsub(msg, "%*gray%*", Private.Colors.quest.gray.colorCode)
		msg = string_gsub(msg, "%*%*", "|r")
		rawset(t,k,msg)
	end })

	self.output.achievement = "*offwhite*!**%s: %s"
	self.output.auction_sold = "*offwhite*!***green*"..string_gsub(AUCTION_SOLD_MAIL, "%%s", "*white*%%s**").."**"
	self.output.auction_single = "*gray*+** *white*"..AUCTION_CREATED.."**"
	self.output.auction_multiple = "*gray*+** *white*"..AUCTION_CREATED.."** *offwhite*(%d)**"
	self.output.auction_canceled_single = "*palered*- "..AUCTION_REMOVED.."**"
	self.output.auction_canceled_multiple = "*palered*- "..AUCTION_REMOVED.."** *offwhite*(%d)**"
	self.output.item_single = "*gray*+** %s"
	self.output.item_multiple = "*gray*+** %s *offwhite*(%d)**"
	self.output.item_deficit = "*red*- %s**"
	self.output.item_transfer = "*gray*+** *white*%s:** %s"
	self.output.currency = "*gray*+** *white*%d** %s"
	self.output.money = self.output.item_single
	self.output.money_deficit = "*gray*-** %s"
	self.output.objective_status = "*gray*+** *white*%s:** *yellow*%s**"
	self.output.standing = "*gray*+** *white*".."%d** *white*%s:** %s"
	self.output.standing_generic = "*gray*+ %s:** %s"
	self.output.standing_deficit = "*red*-** *white*".."%d** *white*%s:** %s"
	self.output.standing_deficit_generic = "*red*-** *palered** %s:** %s"
	self.output.xp_named = "*gray*+** *white*%d** *white*%s:** *yellow*%s**"
	self.output.xp_unnamed = "*gray*+** *white*%d** *white*%s**"
	self.output.xp_levelup = "*offwhite*!**%s*white*!**"
	self.output.afk_added = "*orange*+ "..AWAY.."**"
	self.output.afk_added_message = "*orange*+ "..AWAY..": ***white*%s**"
	self.output.afk_cleared = "*green*- "..AWAY.."**"
	self.output.dnd_added = "|cffff6600+ "..BUSY.."**"
	self.output.dnd_added_message = "|cffff6600+ "..BUSY..": ***white*%s**"
	self.output.dnd_cleared = "*green*- "..BUSY.."**"
	self.output.rested_added = "*gray*+ "..RESTED.."**"
	self.output.rested_cleared = "*orange*- "..RESTED.."**"
	self.output.quest_accepted = "*gray*+** *white*%s:** *yellow*%s**"
	self.output.quest_complete = "*gray*+** *white*%s:** *yellow*%s**"

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
		__call = function(sets, msg, ...)
			for i,set in next,sets do
				if (type(set) == "table") then
					for k,data in ipairs(set) do
						if (type(data) == "table") then
							msg = string_gsub(msg, unpack(data))
						elseif (type(data == "func")) then
							msg = func(msg, ...) or msg
						end
					end
				elseif (type(set == "func")) then
					msg = set(msg, ...) or msg
				end
			end
			return msg
		end
	})
end

Core.OnEnable = function(self)
	self:CacheAllMessageMethods()
end

