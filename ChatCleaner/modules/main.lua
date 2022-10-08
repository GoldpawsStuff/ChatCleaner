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

-- These channels will be ignored by the general parsing.
-- This does not affect the chat event filters,
-- and is only meant to avoid normal chat messages
-- giving off false positives as system messages.
local ignoredIDs = {}
for _,index in ipairs({

	--"SYSTEM",
	"SAY",
	"PARTY",
	"RAID",
	"GUILD",
	"OFFICER",
	"YELL",
	"WHISPER",
	"SMART_WHISPER",
	"WHISPER_INFORM",
	"REPLY",
	"EMOTE",
	"TEXT_EMOTE",
	"MONSTER_SAY",
	"MONSTER_PARTY",
	"MONSTER_YELL",
	"MONSTER_WHISPER",
	"MONSTER_EMOTE",
	"CHANNEL",
	"CHANNEL_JOIN",
	"CHANNEL_LEAVE",
	"CHANNEL_LIST",
	"CHANNEL_NOTICE",
	"CHANNEL_NOTICE_USER",
	"TARGETICONS",
	"AFK",
	"DND",
	"IGNORED",
	--"SKILL",
	--"LOOT",
	--"CURRENCY",
	--"MONEY",
	--"OPENING",
	--"TRADESKILLS",
	"PET_INFO",
	"COMBAT_MISC_INFO",
	--"COMBAT_XP_GAIN",
	--"COMBAT_HONOR_GAIN",
	--"COMBAT_FACTION_CHANGE",
	"BG_SYSTEM_NEUTRAL",
	"BG_SYSTEM_ALLIANCE",
	"BG_SYSTEM_HORDE",
	"RAID_LEADER",
	"RAID_WARNING",
	"RAID_BOSS_WHISPER",
	"RAID_BOSS_EMOTE",
	"QUEST_BOSS_EMOTE",
	"FILTERED",
	"INSTANCE_CHAT",
	"INSTANCE_CHAT_LEADER",
	"RESTRICTED",
	"CHANNEL1",
	"CHANNEL2",
	"CHANNEL3",
	"CHANNEL4",
	"CHANNEL5",
	"CHANNEL6",
	"CHANNEL7",
	"CHANNEL8",
	"CHANNEL9",
	"CHANNEL10",
	"CHANNEL11",
	"CHANNEL12",
	"CHANNEL13",
	"CHANNEL14",
	"CHANNEL15",
	"CHANNEL16",
	"CHANNEL17",
	"CHANNEL18",
	"CHANNEL19",
	"CHANNEL20",
	--"ACHIEVEMENT",
	"PARTY_LEADER",
	"BN_WHISPER",
	"BN_WHISPER_INFORM",
	"BN_ALERT",
	"BN_BROADCAST",
	"BN_BROADCAST_INFORM",
	"BN_INLINE_TOAST_ALERT",
	"BN_INLINE_TOAST_BROADCAST",
	"BN_INLINE_TOAST_BROADCAST_INFORM",
	"BN_WHISPER_PLAYER_OFFLINE",
	"COMMUNITIES_CHANNEL",
	"VOICE_TEXT"

}) do
	local id = GetChatTypeIndex(index)
	if (id) then
		ignoredIDs[id] = true
	end
end

Core.AddMessageFiltered = function(self, chatFrame, msg, r, g, b, chatID, ...)
	if (not msg) or (msg == "") then
		return
	end
	-- Don't filter or parse any of the above channels
	if not(chatID and ignoredIDs[chatID]) then
		if (next(self.blacklist)) then
			if (self.blacklist(chatFrame, msg, r, g, b, chatID, ...)) then
				return
			end
		end
		if (next(self.replacements)) then
			msg = self.replacements(msg, r, g, b, chatID, ...)
		end
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
	-- *uses a simple color tag system for new strings.
	local colors = Private.Colors
	local output = setmetatable({}, { __newindex = function(t,k,msg)
		for tag,replacement in pairs({
			-- The order matters.
			["%*title%*"] 		= colors.title.colorCode,
			["%*white%*"] 		= colors.highlight.colorCode,
			["%*offwhite%*"] 	= colors.offwhite.colorCode,
			["%*palered%*"] 	= colors.palered.colorCode,
			["%*red%*"] 		= colors.quest.red.colorCode,
			["%*darkorange%*"] 	= colors.quality.Legendary.colorCode,
			["%*orange%*"] 		= colors.quest.orange.colorCode,
			["%*yellow%*"] 		= colors.quest.yellow.colorCode,
			["%*green%*"] 		= colors.quest.green.colorCode,
			["%*gray%*"] 		= colors.quest.gray.colorCode,
			-- Always keep this at the end.
			["%*%*"] = "|r"
		}) do
			msg = string_gsub(msg, tag, replacement)
		end
		rawset(t,k,msg)
	end })

	-- Templates we use for multiple things
	-- *don't use these directly in the modules,
	--  only use them in the definitions below.
	output.__gain = "*gray*+** %s"
	output.__gain_yellow = "*gray*+** *white*%s:** *yellow*%s**"

	-- Output formats used in the modules.
	-- *everything should be gathered here, in this file.
	output.achievement = "*offwhite*!**%s: %s"
	output.achievement2 = "*offwhite*!***green*%s:** *white*%s**"
	output.afk_added = "*orange*+ "..AWAY.."**"
	output.afk_added_message = "*orange*+ "..AWAY..": ***white*%s**"
	output.afk_cleared = "*green*- "..AWAY.."**"
	output.auction_sold = "*offwhite*!***green*"..string_gsub(AUCTION_SOLD_MAIL, "%%s", "*white*%%s**").."**"
	output.auction_single = "*gray*+** *white*"..AUCTION_CREATED.."**"
	output.auction_multiple = "*gray*+** *white*"..AUCTION_CREATED.."** *offwhite*(%d)**"
	output.auction_canceled_single = "*palered*- "..AUCTION_REMOVED.."**"
	output.auction_canceled_multiple = "*palered*- "..AUCTION_REMOVED.."** *offwhite*(%d)**"
	output.currency = "*gray*+** *white*%d** %s"
	output.dnd_added = "*darkorange*+ "..BUSY.."**"
	output.dnd_added_message = "*darkorange*+ "..BUSY..": ***white*%s**"
	output.dnd_cleared = "*green*- "..BUSY.."**"
	output.item_single = output.__gain
	output.item_multiple = "*gray*+** %s *offwhite*(%d)**"
	output.item_single_other = "*offwhite*!**%s*gray*:** %s"
	output.item_multiple_other = "*offwhite*!**%s*gray*:** %s *offwhite*(%d)**"
	output.item_deficit = "*red*- %s**"
	output.item_transfer = "*gray*+** *white*%s:** %s"
	output.money = output.__gain
	output.money_deficit = "*gray*-** %s"
	output.objective_status = output.__gain_yellow
	output.quest_accepted = output.__gain_yellow
	output.quest_complete = output.__gain_yellow
	output.rested_added = "*gray*+ "..RESTED.."**"
	output.rested_cleared = "*orange*- "..RESTED.."**"
	output.set_complete = output.__gain_yellow
	output.standing = "*gray*+** *white*".."%d** *white*%s:** %s"
	output.standing_generic = "*gray*+ %s:** %s"
	output.standing_deficit = "*red*-** *white*".."%d** *white*%s:** %s"
	output.standing_deficit_generic = "*red*-** *palered** %s:** %s"
	output.xp_levelup = "*offwhite*!**%s*white*!**"
	output.xp_named = "*gray*+** *white*%d** *white*%s:** *yellow*%s**"
	output.xp_unnamed = "*gray*+** *white*%d** *white*%s**"

	-- Give the modules access
	self.output = output

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

