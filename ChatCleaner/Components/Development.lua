local Addon, ns = ...

-- Only run this module on GitHub repo downloads or my own local version.
if (ns.Version ~= "Development") then
	return
end


local Module = ns:NewModule("DevelopmentFilters")

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

Module.OnInitialize = function(self)
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ns:AddBlacklistMethod(self.OnAddMessageProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ns:RemoveBlacklistMethod(self.OnAddMessageProxy)
end
