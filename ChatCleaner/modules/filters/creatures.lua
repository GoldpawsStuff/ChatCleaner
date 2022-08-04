local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Creatures")

-- Lua API
local string_format = string.format

-- WoW API
local ChatTypeInfo = ChatTypeInfo
local RaidNotice_AddMessage = RaidNotice_AddMessage

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
		RaidNotice_AddMessage(RaidBossEmoteFrame, string_format(message, author), ChatTypeInfo["MONSTER_EMOTE"])
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

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
	if (self.db["DisableFilter:"..self:GetName()]) then
		return self:SetUserDisabled()
	end
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
