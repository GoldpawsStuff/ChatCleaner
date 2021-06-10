local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Blacklist")

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
	self:GetParent():AddBlacklistMethod(self.OnAddMessageProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self:GetParent():RemoveBlacklistMethod(self.OnAddMessageProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
