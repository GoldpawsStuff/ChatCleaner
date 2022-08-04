local Addon, Private = ...
-- Only run this module on GitHub repo downloads or my own local version.
if (Private.Version ~= "Development") then
	return
end
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("DevelopmentFilters")

-- Lua API
local string_find = string.find

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)
	-- Kill off MaxDps ace console status messages.
	-- Definitely not recommended for the general user.
	if (string_find(msg, "|cff33ff99MaxDps|r%:")) then
		return true
	end
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
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
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self:GetParent():RemoveBlacklistMethod(self.OnAddMessageProxy)
end
