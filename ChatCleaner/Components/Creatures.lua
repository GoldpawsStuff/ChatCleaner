local Addon, ns = ...

if (ns.Version ~= "Development") then return end

local Module = ns:NewModule("Creatures")

-- GLOBALS: ChatTypeInfo, RaidNotice_AddMessage

-- Lua API
local string_format = string.format

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	-- Should add a check for chat bubbles,
	-- and have a reactive option that hides when bubbles are visible.
	if (event == "CHAT_MSG_MONSTER_SAY") then
		return true

	elseif (event == "CHAT_MSG_MONSTER_YELL") then
		return true

	elseif (event == "CHAT_MSG_MONSTER_EMOTE") then
		-- These returns a formatstring, which we need to paste the author/monster into.
		-- *These do NOT always return a formatstring. What the fuck?
		--RaidNotice_AddMessage(RaidBossEmoteFrame, string_format(message, author), ChatTypeInfo["MONSTER_EMOTE"])
		return true

	elseif (event == "CHAT_MSG_MONSTER_WHISPER") then
		return true

	elseif (event == "CHAT_MSG_RAID_BOSS_EMOTE") then
		-- Don't do this, the RaidBossEmoteFrame does this
		-- by default for boss emotes and boss whispers!
		--RaidNotice_AddMessage(RaidBossEmoteFrame, message, ChatTypeInfo["RAID_BOSS_EMOTE"])
		return true

	elseif (event == "CHAT_MSG_RAID_BOSS_WHISPER") then
		-- Don't do this, the RaidBossEmoteFrame does this
		-- by default for boss emotes and boss whispers!
		--RaidNotice_AddMessage(RaidBossEmoteFrame, message, ChatTypeInfo["RAID_BOSS_EMOTE"])
		return true
	end
end

Module.OnInitialize = function(self)
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_WHISPER", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONSTER_SAY", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONSTER_YELL", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONSTER_WHISPER", self.OnChatEventProxy)
end
