local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Experience")

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
end

Module.OnInit = function(self)
end

Module.OnEnable = function(self)
	self.filterEnabled = true
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
end
