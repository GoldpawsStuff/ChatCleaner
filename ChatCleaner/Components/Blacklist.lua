local Addon, ns = ...

local Module = ns:NewModule("Blacklist")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- WoW Globals
local NOT_IN_INSTANCE_GROUP = ERR_NOT_IN_INSTANCE_GROUP -- "You aren't in an instance group."
local NOT_IN_RAID = ERR_NOT_IN_RAID -- "You are not in a raid group"
local QUEST_ALREADY_ON = ERR_QUEST_ALREADY_ON -- "You are already on that quest"

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	if (message == NOT_IN_RAID) or (message == NOT_IN_INSTANCE_GROUP) or (message == QUEST_ALREADY_ON) then
		return true
	end
end

Module.OnInitialize = function(self)
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ns:AddBlacklistMethod(self.OnAddMessageProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ns:RemoveBlacklistMethod(self.OnAddMessageProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
