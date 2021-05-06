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
local AUCTION_STARTED = ERR_AUCTION_STARTED -- "Auction created."
local AUCTIONS = AUCTIONS -- "Auctions"

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

Module.AuctionFrameWasHidden = function(self)
	local frame = AuctionHouseFrame or AuctionFrame
	if (frame and frame:IsShown()) then
		return
	end
	if (self.queued) then
		local msg = (self.queued > 1) and string_format(self.output.auction_multiple, self.queued) or self.output.auction_single
		self.queued = nil
		local info = ChatTypeInfo["SYSTEM"]
		DEFAULT_CHAT_FRAME:AddMessage(msg, info.r, info.g, info.b, info.id)
	end
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)

	-- Auction created. Let's queue them?
	if (message == AUCTION_STARTED) then
		self.queued = (self.queued or 0) + 1
		local frame = AuctionHouseFrame or AuctionFrame
		if (frame and frame:IsShown()) then
			if (not self.proxied) then
				frame:HookScript("OnHide", self.AuctionFrameWasHiddenProxy)
				self.proxied = true
			end
			return true
		else
			local message = (self.queued > 1) and string_format(self.output.auction_multiple, self.queued) or self.output.auction_single
			self.queued = nil
			return false, message, author, ...
		end
	end

	-- Auction sold
	local item = string_match(message, P[AUCTION_SOLD])
	if (item) then
		return false, string_format(self.output.auction_sold, item), author, ...
	end

end

Module.OnInit = function(self)
	self.output = self:GetParent():GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.AuctionFrameWasHiddenProxy = function(...) return (self.filterEnabled) and self:AuctionFrameWasHidden(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	self.queued = nil
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self.queued = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
