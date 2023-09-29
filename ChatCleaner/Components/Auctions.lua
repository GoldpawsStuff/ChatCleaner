--[[

	The MIT License (MIT)

	Copyright (c) 2023 Lars Norberg

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]]
local Addon, ns = ...

local Module = ns:NewModule("Auctions", "AceHook-3.0")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- GLOBALS: DEFAULT_CHAT_FRAME
-- GLOBALS: AuctionFrame, AuctionHouseFrame, ChatTypeInfo
-- GLOBALS: ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilte

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local G = {
	AUCTION_REMOVED = ERR_AUCTION_REMOVED, -- "Auction cancelled."
	AUCTION_SOLD = ERR_AUCTION_SOLD_S, -- "A buyer has been found for your auction of %s."
	AUCTION_STARTED = ERR_AUCTION_STARTED, -- "Auction created."
	AUCTIONS = AUCTIONS -- "Auctions"
}

-- Convert a WoW global string to a search pattern
local makePattern = function(msg)
	msg = string_gsub(msg, "%%([%d%$]-)d", "(%%d+)")
	msg = string_gsub(msg, "%%([%d%$]-)s", "(.+)")
	return msg
end

-- Search Pattern Cache.
-- This will generate the pattern on the first lookup.
local P = setmetatable({}, { __index = function(t,k)
	rawset(t,k,makePattern(k))
	return rawget(t,k)
end })

Module.SpecialFrameWasHidden = function(self)
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

Module.OnSpecialFrameHide = function(self, frame, ...)
	return (self.filterEnabled) and self:SpecialFrameWasHidden(frame, ...)
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	if (ns:IsProtectedMessage(message)) then return end

	-- Auction created. Let's queue them?
	if (message == G.AUCTION_STARTED) then

		self.queuedStarted = (self.queuedStarted or 0) + 1

		local frame = AuctionHouseFrame or AuctionFrame
		if (frame and frame:IsShown()) then

			if (not self:IsHooked(frame, "OnHide")) then
				self:HookScript(frame, "OnHide", self.OnAuctionFrameHide)
			end

			return true

		else
			local message = (self.queuedStarted > 1) and string_format(self.output.auction_multiple, self.queuedStarted) or self.output.auction_single

			self.queuedStarted = nil

			return false, message, author, ...
		end

	elseif (message == G.AUCTION_REMOVED) then

		self.queuedRemoved = (self.queuedRemoved or 0) + 1

		local frame = AuctionHouseFrame or AuctionFrame
		if (frame and frame:IsShown()) then

			if (not self:IsHooked(frame, "OnHide")) then
				self:HookScript(frame, "OnHide", self.OnAuctionFrameHide)
			end

			return true
		else
			local message = (self.queuedRemoved > 1) and string_format(self.output.auction_canceled_multiple, self.queuedRemoved) or self.output.auction_canceled_single

			self.queuedRemoved = nil

			return false, message, author, ...
		end
	end

	-- Auction sold
	local item = string_match(message, P[G.AUCTION_SOLD])
	if (item) then
		return false, string_format(self.output.auction_sold, item), author, ...
	end

end

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)

	-- Auction created. Let's queue them?
	if (msg == G.AUCTION_STARTED) then

		self.queuedStarted = (self.queuedStarted or 0) + 1

		local frame = AuctionHouseFrame or AuctionFrame
		if (frame and frame:IsShown()) then

			if (not self:IsHooked(frame, "OnHide")) then
				self:HookScript(frame, "OnHide", self.OnAuctionFrameHide)
			end

			return true

		else
			local message = (self.queuedStarted > 1) and string_format(self.output.auction_multiple, self.queuedStarted) or self.output.auction_single

			self.queuedStarted = nil

			return message
		end

	elseif (msg == G.AUCTION_REMOVED) then

		self.queuedRemoved = (self.queuedRemoved or 0) + 1

		local frame = AuctionHouseFrame or AuctionFrame
		if (frame and frame:IsShown()) then

			if (not self:IsHooked(frame, "OnHide")) then
				self:HookScript(frame, "OnHide", self.OnAuctionFrameHide)
			end

			return true
		else
			local message = (self.queuedRemoved > 1) and string_format(self.output.auction_canceled_multiple, self.queuedRemoved) or self.output.auction_canceled_single

			self.queuedRemoved = nil

			return message
		end
	end

end

Module.OnInitialize = function(self)
	self.output = ns:GetOutputTemplates()

	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end

	self.OnAuctionFrameHide = function(...) return (self.filterEnabled) and self:SpecialFrameWasHidden(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	self.queuedStarted = nil
	self.queuedRemoved = nil

	ns:AddBlacklistMethod(self.OnAddMessageProxy)

	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self.queuedStarted = nil
	self.queuedRemoved = nil

	ns:RemoveBlacklistMethod(self.OnAddMessageProxy)

	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
