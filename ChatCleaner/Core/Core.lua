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

ns = LibStub("AceAddon-3.0"):NewAddon(ns, Addon, "LibMoreEvents-1.0", "AceConsole-3.0", "AceHook-3.0")

-- Keep modules disabled by default
ns:SetDefaultModuleState(false)

-- GLOBALS: hooksecurefunc
-- GLOBALS: CHAT_FRAMES, FCF_GetCurrentChatFrame, GetChatTypeIndex

-- Lua API
local _G = _G
local ipairs = ipairs
local next = next
local pairs = pairs
local rawset = rawset
local setmetatable = setmetatable
local string_find = string.find
local string_match = string.match
local string_gsub = string.gsub
local string_lower = string.lower
local string_upper = string.upper
local table_insert = table.insert
local type = type
local unpack = unpack

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
	"ACHIEVEMENT",
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

-- Addon default settings.
local defaults = {
	styling = true, -- will be ignored when conflicting addons are detected
	useBlizzardCoins = nil, -- not used
	filters = {
		achievements = ns.IsWrath or ns.IsRetail or nil,
		auctions = true,
		channels = true,
		experience = true,
		followers = ns.IsRetail or nil,
		loot = true,
		names = true,
		quests = true,
		reputation = true,
		spells = true,
		status = true,
		tradeskills = true
	}
}

ChatCleaner_DB = CopyTable(defaults)

ns.AddMessageFiltered = function(self, chatFrame, msg, r, g, b, chatID, ...)
	if (not msg) or (msg == "") then
		return
	end
	if (not string_find(msg, "|Hquestie")) then
		if (next(self.specialreplacements)) then
			msg = self.specialreplacements(msg, r, g, b, chatID, ...)
		end
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
	end
	return self.MethodCache[chatFrame](chatFrame, msg, r, g, b, chatID, ...)
end

ns.CacheMessageMethod = function(self, chatFrame)
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

ns.AddBlacklistMethod = function(self, func)
	for _,infunc in next,self.blacklist do
		if (infunc == func) then
			return
		end
	end
	table_insert(self.blacklist, func)
end

ns.RemoveBlacklistMethod = function(self, func)
	for k,infunc in next,self.blacklist do
		if (infunc == func) then
			self.blacklist[k] = nil
			break
		end
	end
end

ns.AddReplacementSet = function(self, set, ignoreBlacklist)
	local group = ignoreBlacklist and self.specialreplacements or self.replacements
	for _,inset in next,group do
		if (inset == set) then
			return
		end
	end
	table_insert(group, set)
end

ns.RemoveReplacementSet = function(self, set)
	for k,inset in next,self.replacements do
		if (inset == set) then
			self.replacements[k] = nil
			break
		end
	end
	for k,inset in next,self.specialreplacements do
		if (inset == set) then
			self.replacements[k] = nil
			break
		end
	end
end

ns.CacheAllMessageMethods = function(self)
	for _,chatFrameName in ipairs(CHAT_FRAMES) do
		self:CacheMessageMethod(_G[chatFrameName])
	end
	if (not self.tempWindowsHooked) then
		self.tempWindowsHooked = true
		hooksecurefunc("FCF_OpenTemporaryWindow", function() self:CacheMessageMethod((FCF_GetCurrentChatFrame())) end)
	end
end

ns.GetOutputTemplates = function(self)
	return self.output
end

ns.UpgradeSettings = function(self)

	-- Have the db been upgraded?
	if (not ChatCleaner_DB.configversion or ChatCleaner_DB.configversion ~= -1) then

		-- Work on a clone.
		local old = CopyTable(ChatCleaner_DB)

		-- Replace missing entries with the defaults
		for setting,value in next,defaults do
			if (ChatCleaner_DB[setting] == nil) then
				ChatCleaner_DB[setting] = value
			end
		end

		-- Parse the cloned db for outdated entries.
		for setting,value in next,old do

			-- Only parse old filter settings.
			local moduleName = string_match(setting,"DisableFilter:(.*)")
			if (moduleName) then

				-- Old settings are true when the filter is disabled,
				-- new settings are true when filter is enabled.
				-- Also, old naming scheme was horrible.
				ChatCleaner_DB[setting] = nil
				ChatCleaner_DB.filters[string_lower(moduleName)] = not value
			end
		end

		-- Replace missing filter settings with their defaults.
		for setting,value in next,defaults.filters do
			if (ChatCleaner_DB.filters[setting] == nil) then
				ChatCleaner_DB.filters[setting] = value
			end
		end

		-- Store the new settings version
		-- so we never have to do this again.
		ChatCleaner_DB.configversion = 2
	end

	-- Return a more sane db.
	return ChatCleaner_DB
end

ns.OnEvent = function(self, event, ...)
end

ns.OnInitialize = function(self)
	self.db = self:UpgradeSettings()

	-- Output patterns.
	-- *uses a simple color tag system for new strings.
	local output = setmetatable({}, { __newindex = function(t,k,msg)
		-- Have to do this with an indexed table,
		-- as the order of the entires matters.
		for _,entry in ipairs({
			{ "%*title%*", 		ns.Colors.title.colorCode },
			{ "%*white%*", 		ns.Colors.highlight.colorCode },
			{ "%*offwhite%*", 	ns.Colors.offwhite.colorCode },
			{ "%*palered%*", 	ns.Colors.palered.colorCode },
			{ "%*red%*", 		ns.Colors.quest.red.colorCode },
			{ "%*darkorange%*", ns.Colors.quality.Legendary.colorCode },
			{ "%*orange%*", 	ns.Colors.quest.orange.colorCode },
			{ "%*yellow%*", 	ns.Colors.quest.yellow.colorCode },
			{ "%*green%*", 		ns.Colors.quest.green.colorCode },
			{ "%*gray%*", 		ns.Colors.quest.gray.colorCode },
			{ "%*%*", "|r" } -- Always keep this at the end.
		}) do
			msg = string_gsub(msg, unpack(entry))
		end
		rawset(t,k,msg)
	end })

	-- WoW Global Strings
	local AUCTION_SOLD_MAIL = _G.AUCTION_SOLD_MAIL_SUBJECT -- "Auction successful: %s"
	local AUCTION_CREATED = string_gsub(_G.ERR_AUCTION_STARTED, "%.", "") -- "Auction created."
	local AUCTION_REMOVED = string_gsub(_G.ERR_AUCTION_REMOVED, "%.", "") -- "Auction cancelled."
	local AWAY = _G.FRIENDS_LIST_AWAY -- "Away"
	local BUSY = _G.FRIENDS_LIST_BUSY -- "Busy"
	local COMPLETE = _G.COMPLETE -- "Complete"
	local RESTED = _G.TUTORIAL_TITLE26 -- "Rested"

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
		__call = function(self, ...)
			for _,func in next,self do
				if (func(...)) then
					return true
				end
			end
		end
	})

	self.replacements = setmetatable({}, {
		__call = function(self, msg, ...)
			for i,set in next,self do
				if (type(set) == "table") then
					for k,data in ipairs(set) do
						if (type(data) == "table") then
							msg = string_gsub(msg, unpack(data))
						elseif (type(data == "func")) then
							msg = data(msg, ...) or msg
						end
					end
				elseif (type(set == "func")) then
					msg = set(msg, ...) or msg
				end
			end
			return msg
		end
	})

	self.specialreplacements = setmetatable({}, {
		__call = function(self, msg, ...)
			for i,set in next,self do
				if (type(set) == "table") then
					for k,data in ipairs(set) do
						if (type(data) == "table") then
							msg = string_gsub(msg, unpack(data))
						elseif (type(data == "func")) then
							msg = data(msg, ...) or msg
						end
					end
				elseif (type(set == "func")) then
					msg = set(msg, ...) or msg
				end
			end
			return msg
		end
	})

	self:GetModule("Options"):Enable()
end

ns.OnEnable = function(self)
	self:CacheAllMessageMethods()

	-- Enable modules.
	for setting,value in next,self.db.filters do
		local moduleName = string_gsub(setting, "^%l", string_upper)
		local module = ns:GetModule(moduleName, true)
		if (module) then
			if (value and not module:IsEnabled()) then
				module:Enable()
			elseif (not value and module:IsEnabled()) then
				module:Disable()
			end
		end
	end
end

