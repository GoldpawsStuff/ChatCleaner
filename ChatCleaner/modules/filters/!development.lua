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

local onAddMessage = function(chatFrame, msg, r, g, b, chatID, ...)
	-- Kill off MaxDps ace console status messages.
	-- Definitely not recommended for the general user.
	if (string_find(msg, "|cff33ff99MaxDps|r%:")) then
		return true
	end
end

local onChatEvent = function(chatFrame, event, message, author, ...)
end

Module.OnInit = function(self)
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	self:GetParent():AddBlacklistMethod(onAddMessage)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self:GetParent():RemoveBlacklistMethod(onAddMessage)
end
