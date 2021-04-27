local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Money")

-- Lua API
local math_abs = math.abs
local math_floor = math.floor
local math_mod = math.fmod
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local tonumber = tonumber

-- WoW API
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local ChatFrame_RemoveMessageEventFilter = ChatFrame_RemoveMessageEventFilter
local ChatTypeInfo = ChatTypeInfo
local GetMoney = GetMoney
local UnitOnTaxi = UnitOnTaxi

-- WoW Strings
local GOLD_AMOUNT = GOLD_AMOUNT
local GOLD_AMOUNT_SYMBOL = GOLD_AMOUNT_SYMBOL
local SILVER_AMOUNT = SILVER_AMOUNT
local SILVER_AMOUNT_SYMBOL = SILVER_AMOUNT_SYMBOL
local COPPER_AMOUNT = COPPER_AMOUNT
local COPPER_AMOUNT_SYMBOL = COPPER_AMOUNT_SYMBOL
local LARGE_NUMBER_SEPERATOR = LARGE_NUMBER_SEPERATOR

-- Sourced from SharedXML\FormattingUtil.lua#54
local COPPER_PER_SILVER = 100
local SILVER_PER_GOLD = 100
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD

local getFilter = function(msg)
	msg = string_gsub(msg, "%%d", "(%%d+)")
	msg = string_gsub(msg, "%%s", "(.+)")
	msg = string_gsub(msg, "%%(%d+)%$d", "%%%%%1$(%%d+)")
	msg = string_gsub(msg, "%%(%d+)%$s", "%%%%%1$(%%s+)")
	return msg
end

local Coin = setmetatable({}, { __index = function(t,k) 
	local useBlizz = Core.db.useBlizzardCoins
	local frame = DEFAULT_CHAT_FRAME or ChatFrame1 -- do we need this fallback?
	local _,size = frame:GetFont()
	size = math_floor((size or 20) * (useBlizz and .6 or .8))
	if (k == "Gold") then
		if (useBlizz) then
			return string_format([[|TInterface\MoneyFrame\UI-GoldIcon:%d:%d:2:0|t]], size, size)
		else
			return string_format([[|TInterface\AddOns\%s\media\coins.tga:%d:%d:-2:0:64:64:0:32:0:32|t]], Addon, size, size)
		end
	elseif (k == "Silver") then
		if (useBlizz) then
			return string_format([[|TInterface\MoneyFrame\UI-SilverIcon:%d:%d:2:0|t]], size, size)
		else
			return string_format([[|TInterface\AddOns\%s\media\coins.tga:%d:%d:-2:0:64:64:32:64:0:32|t]], Addon, size, size)
		end
	elseif (k == "Copper") then
		if (useBlizz) then
			return string_format([[|TInterface\MoneyFrame\UI-CopperIcon:%d:%d:2:0|t]], size, size)
		else
			return string_format([[|TInterface\AddOns\%s\media\coins.tga:%d:%d:-2:0:64:64:0:32:32:64|t]], Addon, size, size)
		end
	end
end })

-- Search Pattern Cache.
-- This will generate the pattern on the first lookup.
local P = setmetatable({}, { __index = function(t,k) 
	rawset(t,k,getFilter(k))
	return rawget(t,k)
end })

local CreateMoneyString = function(gold, silver, copper, colorCode)
	colorCode = colorCode or "|cfff0f0f0"
	local moneyString
	if (gold > 0) then 
		moneyString = string_format(colorCode.."%d|r%s", gold, Coin.Gold)
	end
	if (silver > 0) then 
		moneyString = (moneyString and moneyString.." " or "") .. string_format(colorCode.."%d|r%s", silver, Coin.Silver)
	end
	if (copper > 0) then 
		moneyString = (moneyString and moneyString.." " or "") .. string_format(colorCode.."%d|r%s", copper, Coin.Copper)
	end 
	return moneyString
end

local ParseForMoney = function(message)

	-- Remove large number formatting 
	message = string_gsub(message, "(%d)%"..LARGE_NUMBER_SEPERATOR.."(%d)", "%1%2")

	-- Basic old-style parsing first.
	-- Doing it in two steps to limit number of needed function calls.
	local gold = string_match(message, P[GOLD_AMOUNT]) -- "%d Gold"
	local gold_amount = gold and tonumber(gold) or 0
	local silver = string_match(message, P[SILVER_AMOUNT]) -- "%d Silver"
	local silver_amount = silver and tonumber(silver) or 0
	local copper = string_match(message, P[COPPER_AMOUNT]) -- "%d Copper"
	local copper_amount = copper and tonumber(copper) or 0

	-- Now we have to do it the hard way. 
	if (gold_amount == 0) and (silver_amount == 0) and (copper_amount == 0) then

		-- Discover icon and currency existence.
		-- Could definitely simplify this. But. We don't.
		local hasGold, hasSilver, hasCopper
		if (ENABLE_COLORBLIND_MODE == "1") then
			hasGold = string_find(message,"%d"..GOLD_AMOUNT_SYMBOL)
			hasSilver = string_find(message,"%d"..SILVER_AMOUNT_SYMBOL)
			hasCopper = string_find(message,"%d"..COPPER_AMOUNT_SYMBOL)
		else
			hasGold = string_find(message,"(UI%-GoldIcon)")
			hasSilver = string_find(message,"(UI%-SilverIcon)")
			hasCopper = string_find(message,"(UI%-CopperIcon)")
		end

		-- These patterns should work for both coins and symbols. Let's parse!
		if (hasGold) or (hasSilver) or (hasCopper) then
			
			-- Now kill off texture strings, replace with space for number separation.
			message = string_gsub(message, "\124T(.-)\124t", " ") 

			-- Kill off color codes. They might fuck up this thing. 
			message = string_gsub(message, "\124[cC]%x%x%x%x%x%x%x%x", "")
			message = string_gsub(message, "\124[rR]", "")

			-- And again we do it the clunky way, to minimize needed function calls.
			if (hasGold) then
				if (hasSilver) and (hasCopper) then
					gold_amount, silver_amount, copper_amount = string_match(message,"(%d+).*%s+(%d+).*%s+(%d+).*")
					return tonumber(gold_amount) or 0, tonumber(silver_amount) or 0, tonumber(copper_amount) or 0

				elseif (hasSilver) then
					gold_amount, silver_amount = string_match(message,"(%d+).*%s+(%d+).*")
					return tonumber(gold_amount) or 0, tonumber(silver_amount) or 0, 0

				elseif (hasCopper) then
					gold_amount, copper_amount = string_match(message,"(%d+).*%s+(%d+).*")
					return tonumber(gold_amount), 0, tonumber(copper_amount) or 0

				else
					gold_amount = string_match(message,"(%d+).*%s")
					return tonumber(gold_amount) or 0,0,0

				end
			elseif (hasSilver) then
				if (hasCopper) then
					silver_amount, copper_amount = string_match(message,"(%d+).*%s+(%d+).*")
					return 0, tonumber(silver_amount) or 0, tonumber(copper_amount) or 0

				else
					silver_amount = string_match(message,"(%d+).*%s")
					return 0, tonumber(silver_amount) or 0,0

				end
			elseif (hasCopper) then
				copper_amount = string_match(message,"(%d+).*%s")
				return 0,0, tonumber(copper_amount) or 0
			end
		end
		
	end

	return gold_amount, silver_amount, copper_amount
end

local HasMoney = function(self, frame, msg, r, g, b, chatID, ...)
	local g,s,c = ParseForMoney(msg)
	if (g+s+c > 0) then
		return true
	end
end

local Filter = function(self, chatFrame, event, message, author, ...) 
	if (event == "CHAT_MSG_MONEY") then
		return true 
	end
end

local OnFrameHidden = function(self, frame)
	if (MailFrame:IsShown()) or (MerchantFrame:IsShown()) then
		return
	end
	local money = GetMoney()
	if ((self.playerMoney or 0) > money) then
		self.playerMoney = money
		return
	end
	Module:OnEvent("PLAYER_MONEY")
end


Module.OnEvent = function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then

		self.playerMoney = GetMoney()
		self.isAuctionHouseFrameShown = nil
		self.isMailFrameShown = nil
		self.isMerchantFrameShown = nil

	elseif (event == "PLAYER_MONEY") then

		-- Get the current money value.
		local currentMoney = GetMoney()

		-- Store the value and don't report anything
		-- if we're on a taxi or if the auction house is open.
		if (UnitOnTaxi("player")) 
		or ((AuctionHouseFrame) and (AuctionHouseFrame:IsShown()))
		or ((AuctionFrame) and (AuctionFrame:IsShown())) then 
			self.playerMoney = currentMoney
			return
		end

		-- Check for spam frames, and wait for them to hide.
		if (MerchantFrame:IsShown()) or (MailFrame:IsShown()) then
			return
		end

		-- Check if the value has been cached up previously.
		if (self.playerMoney) then
			local money = currentMoney - self.playerMoney
			local gold = math_floor(math_abs(money) / (COPPER_PER_SILVER * SILVER_PER_GOLD))
			local silver = math_floor((math_abs(money) - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
			local copper = math_mod(math_abs(money), COPPER_PER_SILVER)

			if (money > 0) then
			
				local moneyString = CreateMoneyString(gold, silver, copper)
				local moneyMessage = string_format("|cff888888+|r %s", moneyString)
				local info = ChatTypeInfo["MONEY"]
				
				DEFAULT_CHAT_FRAME:AddMessage(moneyMessage, info.r, info.g, info.b, info.id)

			elseif (money < 0) then

				local moneyString = CreateMoneyString(gold, silver, copper, red)
				local moneyMessage = string_format("|cff888888-|r %s", moneyString)
				local info = ChatTypeInfo["MONEY"]
				
				DEFAULT_CHAT_FRAME:AddMessage(moneyMessage, info.r, info.g, info.b, info.id)

			end
			self.playerMoney = currentMoney
		end
	end
end

Module.OnInit = function(self)
	self.FilterProxy = function(chatFrame, event, message, author, ...)
		return Filter(self, chatFrame, event, message, author, ...)
	end
	self.OnFrameHidden = function(frame)
		return OnFrameHidden(self, frame)
	end
	MailFrame:HookScript("OnHide", self.OnFrameHidden)
	MerchantFrame:HookScript("OnHide", self.OnFrameHidden)
end



Module.OnEnable = function(self)
	self.playerMoney = GetMoney()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("PLAYER_MONEY", "OnEvent")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", self.FilterProxy)
	-- New 9.0.5 "You gained:"-style of money.
	-- These are neither system- nor money loot events, 
	-- they are simply added to the frame.
	self:GetParent():AddBlacklistMethod(HasMoney)
end

Module.OnDisable = function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:UnregisterEvent("PLAYER_MONEY", "OnEvent")
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONEY", self.FilterProxy)
	self:GetParent():RemoveBlacklistMethod(HasMoney)
end
