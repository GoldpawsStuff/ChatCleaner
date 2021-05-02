local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Auctions")

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local AUCTION_SOLD = ERR_AUCTION_SOLD_S -- "A buyer has been found for your auction of %s."

-- Convert a WoW global string to a search pattern
local makePattern = function(msg)
	msg = string_gsub(msg, "%%d", "(%%d+)")
	msg = string_gsub(msg, "%%s", "(.+)")
	msg = string_gsub(msg, "%%(%d+)%$d", "%%%%%1$(%%d+)")
	msg = string_gsub(msg, "%%(%d+)%$s", "%%%%%1$(%%s+)")
	return msg
end

-- Search Pattern Cache.
-- This will generate the pattern on the first lookup.
local P = setmetatable({}, { __index = function(t,k) 
	rawset(t,k,makePattern(k))
	return rawget(t,k)
end })

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)

	local item = string_match(message, P[AUCTION_SOLD])
	if (item) then
		return false, string_format(self.output.auction_sold, item), author, ...
	end

end

Module.OnInit = function(self)
	self.output = self:GetParent():GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
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
