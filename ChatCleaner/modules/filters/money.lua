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
local pairs = pairs
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

-- WoW Globals
local GOLD_AMOUNT = GOLD_AMOUNT
local GOLD_AMOUNT_SYMBOL = GOLD_AMOUNT_SYMBOL
local SILVER_AMOUNT = SILVER_AMOUNT
local SILVER_AMOUNT_SYMBOL = SILVER_AMOUNT_SYMBOL
local COPPER_AMOUNT = COPPER_AMOUNT
local COPPER_AMOUNT_SYMBOL = COPPER_AMOUNT_SYMBOL
local LARGE_NUMBER_SEPERATOR = LARGE_NUMBER_SEPERATOR
local ANIMA = POWER_TYPE_ANIMA
local ANIMA_V2 = POWER_TYPE_ANIMA_V2

-- Colorize the anima label.
local ANIMA_LABEL = Private.Colors.quality.Rare.colorCode .. ANIMA .. "|r"

-- To correctly track frame and font sizes
local CURRENT_CHAT_FRAME

-- Return a coin texture string.
local Coin = setmetatable({}, { __index = function(t,k)
	local useBlizz = Core.db.useBlizzardCoins
	local frame = CURRENT_CHAT_FRAME or DEFAULT_CHAT_FRAME or ChatFrame1 -- do we need this fallback?
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
local P = setmetatable({
	[ANIMA] = "^(%d+) "..ANIMA,
	[ANIMA_V2] = "^(%d+) "..ANIMA_V2,
}, { __index = function(t,k)
	rawset(t,k,makePattern(k))
	return rawget(t,k)
end })

-- Remove large number formatting
local simplifyNumbers = function(message)
	return string_gsub(message, "(%d)%"..LARGE_NUMBER_SEPERATOR.."(%d)", "%1%2")
end

-- Add pretty spacing to large numbers
-- *commas as separators are moronic
local prettify = function(value)
	local valueString
	if (value >= 1e9) then
		local billions =  math_floor(value / 1e9)
		local millions =  math_floor((value - billions*1e9) / 1e6)
		local thousands = math_floor((value - billions*1e9 - millions*1e6) / 1e3)
		local remainder = math_mod(value, 1e3)
		return string_format("%d %03d %03d %03d", billions, millions, thousands, remainder)
	elseif (value >= 1e6) then
		local millions =  math_floor(value / 1e6)
		local thousands = math_floor((value - millions*1e6) / 1e3)
		local remainder = math_mod(value, 1e3)
		return string_format("%d %03d %03d", millions, thousands, remainder)
	elseif (value >= 1e3) then
		local thousands = math_floor(value / 1e3)
		local remainder = math_mod(value, 1e3)
		return string_format("%d %03d", thousands, remainder)
	else
		return value..""
	end
end

local formatMoney = function(gold, silver, copper, colorCode)
	colorCode = colorCode or "|cfff0f0f0"
	local msg
	if (gold > 0) then
		msg = string_format(colorCode.."%s|r%s", prettify(gold), Coin["Gold"])
	end
	if (silver > 0) then
		msg = (msg and msg.." " or "") .. string_format(colorCode.."%d|r%s", silver, Coin["Silver"])
	end
	if (copper > 0) then
		msg = (msg and msg.." " or "") .. string_format(colorCode.."%d|r%s", copper, Coin["Copper"])
	end
	return msg
end

local parseForMoney = function(message)

	-- Remove large number formatting
	message = simplifyNumbers(message)

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

Module.SpecialFrameWasHidden = function(self, frame)
	if (MailFrame:IsShown()) or (MerchantFrame:IsShown()) or (ClassTrainerFrame and ClassTrainerFrame:IsShown()) then
		return
	end
	local money = GetMoney()
	if ((self.playerMoney or 0) > money) then
		self.playerMoney = money
		return
	end
	self:OnEvent("PLAYER_MONEY")
end

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)
	local g,s,c = parseForMoney(msg)
	if (g+s+c > 0) then
		return true
	end
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	if (event == "CHAT_MSG_MONEY") then
		-- We always hide this when this filter is active,
		-- so no need for any checks of any sort here.
		return true
	end
end

-- This might be triggered by C_CovenantSanctumUI.DepositAnima(),
-- and not sent into any chat channels or through any event handlers.
-- Good thing about this is that we don't need to parse for sender,
-- or make exceptions to avoid false positives from normal chat.
-- If it starts with the number, it can't be a player message,
-- because the channel or their name link would then be first.
Module.OnReplacementSet = function(self, msg, r, g, b, chatID, ...)
	local anima = string_match(simplifyNumbers(msg), P[ANIMA])
	if (anima) then
		return string_format(self.output.item_multiple, ANIMA_LABEL, anima)
	end
	anima = string_match(simplifyNumbers(msg), P[ANIMA_V2])
	if (anima) then
		return string_format(self.output.item_multiple, ANIMA_LABEL, anima)
	end
end

-- Output the message only to windows with the MONEY channel enabled.
Module.AddMessage = function(self, msg, r, g, b, chatID, ...)
	local chatWindow
	for _,chatFrameName in pairs(CHAT_FRAMES) do
		chatWindow = _G[chatFrameName]
		-- Don't use ChatFrame_ContainsChannel,
		-- that only registers manually joined channels,
		-- it does not apply to message groups.
		if (chatWindow and ChatFrame_ContainsMessageGroup(chatWindow, "MONEY")) then
			CURRENT_CHAT_FRAME = chatWindow
			chatWindow:AddMessage(msg, r, g, b, chatID, ...)
			CURRENT_CHAT_FRAME = nil
		end
	end
end

Module.OnEvent = function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		self.playerMoney = GetMoney()

	elseif (event == "PLAYER_MONEY") then
		local currentMoney = GetMoney()
		if (MerchantFrame:IsShown()) or (MailFrame:IsShown()) or (ClassTrainerFrame and ClassTrainerFrame:IsShown()) then
			-- The trainer frame is an addon, just hook it on-the-fly, don't check for loading.
			if (ClassTrainerFrame) and (not self.hooks[ClassTrainerFrame]) then
				self.hooks[ClassTrainerFrame] = true
				ClassTrainerFrame:HookScript("OnHide", self.hooks.proxy)
			end
			return
		end
		if (AuctionHouseFrame and AuctionHouseFrame:IsShown()) or (AuctionFrame and AuctionFrame:IsShown()) or (UnitOnTaxi("player")) then
			self.playerMoney = currentMoney
			return
		end
		if (self.playerMoney) then
			local money = currentMoney - self.playerMoney

			local value = math_abs(money)
			local g = math_floor(value / 1e4)
			local s = math_floor((value - (g*1e4)) / 100)
			local c = math_mod(value, 100)

			if (money > 0) then
				local msg = string_format(self.output.money, formatMoney(g,s,c))
				local info = ChatTypeInfo["MONEY"]
				self:AddMessage(msg, info.r, info.g, info.b, info.id)

			elseif (money < 0) then
				local msg = string_format(self.output.money_deficit, formatMoney(g,s,c, Private.Colors.palered.colorCode))
				local info = ChatTypeInfo["MONEY"]
				self:AddMessage(msg, info.r, info.g, info.b, info.id)
			end
		end
		self.playerMoney = currentMoney
	end
end

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.hooks = { proxy = function(...) return (self.filterEnabled) and self:SpecialFrameWasHidden(...) end }
	self.output = self:GetParent():GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
	self.OnReplacementSetProxy = function(...) return self:OnReplacementSet(...) end
	MailFrame:HookScript("OnHide", self.hooks.proxy)
	MerchantFrame:HookScript("OnHide", self.hooks.proxy)
	if (self.db["DisableFilter:"..self:GetName()]) then
		return self:SetUserDisabled()
	end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	self.playerMoney = GetMoney()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("PLAYER_MONEY", "OnEvent")
	self:GetParent():AddBlacklistMethod(self.OnAddMessageProxy)
	self:GetParent():AddReplacementSet(self.OnReplacementSetProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self:UnregisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:UnregisterEvent("PLAYER_MONEY", "OnEvent")
	self:GetParent():RemoveBlacklistMethod(self.OnAddMessageProxy)
	self:GetParent():RemoveReplacementSet(self.OnReplacementSetProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONEY", self.OnChatEventProxy)
end
