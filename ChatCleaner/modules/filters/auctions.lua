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
local AUCTION_REMOVED = ERR_AUCTION_REMOVED -- "Auction cancelled."
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
	if (self.queuedRemoved) then
		local msg = (self.queuedRemoved > 1) and string_format(self.output.auction_canceled_multiple, self.queuedRemoved) or self.output.auction_canceled_single
		self.queuedRemoved = nil
		local info = ChatTypeInfo["SYSTEM"]
		DEFAULT_CHAT_FRAME:AddMessage(msg, info.r, info.g, info.b, info.id)
	end
	if (self.queuedStarted) then
		local msg = (self.queuedStarted > 1) and string_format(self.output.auction_multiple, self.queuedStarted) or self.output.auction_single
		self.queuedStarted = nil
		local info = ChatTypeInfo["SYSTEM"]
		DEFAULT_CHAT_FRAME:AddMessage(msg, info.r, info.g, info.b, info.id)
	end
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)

	-- Auction created. Let's queue them?
	if (message == AUCTION_STARTED) then
		self.queuedStarted = (self.queuedStarted or 0) + 1
		local frame = AuctionHouseFrame or AuctionFrame
		if (frame and frame:IsShown()) then
			if (not self.proxied) then
				frame:HookScript("OnHide", self.AuctionFrameWasHiddenProxy)
				self.proxied = true
			end
			return true
		else
			local message = (self.queuedStarted > 1) and string_format(self.output.auction_multiple, self.queuedStarted) or self.output.auction_single
			self.queuedStarted = nil
			return false, message, author, ...
		end
	elseif (message == AUCTION_REMOVED) then
		self.queuedRemoved = (self.queuedRemoved or 0) + 1
		local frame = AuctionHouseFrame or AuctionFrame
		if (frame and frame:IsShown()) then
			if (not self.proxied) then
				frame:HookScript("OnHide", self.AuctionFrameWasHiddenProxy)
				self.proxied = true
			end
			return true
		else
			local message = (self.queuedRemoved > 1) and string_format(self.output.auction_canceled_multiple, self.queuedRemoved) or self.output.auction_canceled_single
			self.queuedRemoved = nil
			return false, message, author, ...
		end
	end

	-- Auction sold
	local item = string_match(message, P[AUCTION_SOLD])
	if (item) then
		return false, string_format(self.output.auction_sold, item), author, ...
	end

end

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)

	-- Auction created. Let's queue them?
	if (msg == AUCTION_STARTED) then
		self.queuedStarted = (self.queuedStarted or 0) + 1
		local frame = AuctionHouseFrame or AuctionFrame
		if (frame and frame:IsShown()) then
			if (not self.proxied) then
				frame:HookScript("OnHide", self.AuctionFrameWasHiddenProxy)
				self.proxied = true
			end
			return true
		else
			local message = (self.queuedStarted > 1) and string_format(self.output.auction_multiple, self.queuedStarted) or self.output.auction_single
			self.queuedStarted = nil
			return message
		end
	elseif (msg == AUCTION_REMOVED) then
		self.queuedRemoved = (self.queuedRemoved or 0) + 1
		local frame = AuctionHouseFrame or AuctionFrame
		if (frame and frame:IsShown()) then
			if (not self.proxied) then
				frame:HookScript("OnHide", self.AuctionFrameWasHiddenProxy)
				self.proxied = true
			end
			return true
		else
			local message = (self.queuedRemoved > 1) and string_format(self.output.auction_canceled_multiple, self.queuedRemoved) or self.output.auction_canceled_single
			self.queuedRemoved = nil
			return message
		end
	end

end

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.output = self:GetParent():GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
	self.AuctionFrameWasHiddenProxy = function(...) return (self.filterEnabled) and self:AuctionFrameWasHidden(...) end
	if (self.db["DisableFilter:"..self:GetName()]) then
		return self:SetUserDisabled()
	end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	self.queuedStarted = nil
	self.queuedRemoved = nil
	self:GetParent():AddBlacklistMethod(self.OnAddMessageProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self.queuedStarted = nil
	self.queuedRemoved = nil
	self:GetParent():RemoveBlacklistMethod(self.OnAddMessageProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
