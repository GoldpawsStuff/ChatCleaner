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

local Module = ns:NewModule("Loot")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- GLOBALS: UnitClass
-- GLOBALS: ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilte

-- Lua API
local ipairs = ipairs
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local string_sub = string.sub
local table_insert = table.insert
local table_remove = table.remove
local tonumber = tonumber

-- WoW Globals
local G = {
	LEARN_BATTLE_PET = BATTLE_PET_NEW_PET, -- "%s has been added to your pet journal!"
	LEARN_COMPANION = ERR_LEARN_COMPANION_S, -- "You have added the pet %s to your collection."
	LEARN_HEIRLOOM = ERR_LEARN_HEIRLOOM_S, -- "%s has been added to your heirloom collection."
	LEARN_MOUNT = ERR_LEARN_MOUNT_S, -- "You have added the mount %s to your collection."
	LEARN_TOY = ERR_LEARN_TOY_S, -- "%s has been added to your Toy Box."
	LEARN_TRANSMOG = ERR_LEARN_TRANSMOG_S, -- "%s has been added to your appearance collection."
	COMPANIONS = COMPANIONS, -- "Companions"
	HEIRLOOMS = HEIRLOOMS, -- "Heirlooms"
	MOUNTS = MOUNTS, -- "Mounts"
	PETS = PETS, -- "Pets"
	TOY_BOX = TOY_BOX, -- "Toy Box"
	WARDROBE = WARDROBE, -- "Appearances"
	LOOT_SPEC_CHANGED = ERR_LOOT_SPEC_CHANGED_S, -- "Loot Specialization set to: %s"
	SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION -- "Loot Specialization"
}

local _,playerClass = UnitClass("player")

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

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	if (ns:IsProtectedMessage(message)) then return end

	if (event == "CHAT_MSG_CURRENCY") then
		for i,pattern in ipairs(self.patterns) do

			-- We use the pattern only as an identifier, not for information.
			local item, count = string_match(message,pattern)
			if (item) then
				-- Note: Currencies don't appear to be the same format as this.
				-- The patterns above tend to fail on the number,
				-- so we do this ugly non-localized hack instead.
				-- |cffffffff|Hitem:itemID:::::|h[display name]|h|r
				local first, last = string_find(message, "|c(.+)|r")
				if (first and last) then

					-- Find the actual item name
					local item = string_sub(message, first, last)
					item = string_gsub(item, "[%[/%]]", "") -- kill brackets

					-- Parse our way to the item count
					local countString = string_sub(message, last + 1)
					local count = tonumber(string_match(countString, "(%d+)"))
					if (count) and (count > 1) then
						--if (name) then
						--	return false, string_format(self.output.item_multiple_other, name, item, count), author, ...
						--else
							return false, string_format(self.output.item_multiple, item, count), author, ...
						--end
					else
						--if (name) then
						--	return false, string_format(self.output.item_single_other, name, item), author, ...
						--else
							return false, string_format(self.output.item_single, item), author, ...
						--end
					end
				end
			end
		end

	elseif (event == "CHAT_MSG_LOOT") then
		for i,pattern in ipairs(self.patterns) do

			-- We use the pattern only as an identifier, not for information.
			local results = { string_match(message,pattern) }
			if (#results > 0) then

				local item, count, name
				for i,j in ipairs(results) do
					local k = tonumber(j)
					if (k) then
						table_remove(results,i)
						count = k
						break
					end
				end

				if (#results == 2) then
					for i,j in ipairs(results) do
						if (string_find(j, "|c%x%x%x%x%x%x%x%x|Hitem")) then
							item = table_remove(results,i)
							item = string_gsub(item, "[%[/%]]", "") -- kill brackets
							break
						end
					end
					name = string_gsub(results[1], "[%[/%]]", "")

				elseif (#results == 1) then
					item = string_gsub(results[1], "[%[/%]]", "") -- kill brackets
				end

				if (item) then
					if (count) and (count > 1) then
						if (name) then
							return false, string_format(self.output.item_multiple_other, name, item, count), author, ...
						else
							return false, string_format(self.output.item_multiple, item, count), author, ...
						end
					else
						if (name) then
							return false, string_format(self.output.item_single_other, name, item), author, ...
						else
							return false, string_format(self.output.item_single, item), author, ...
						end
					end
				end

			end
		end

	elseif (event == "CHAT_MSG_SYSTEM") then

		-- When new toys are learned and put into the toy box.
		local toy = string_match(message, P[G.LEARN_TOY])
		if (toy) then
			return false, string_format(self.output.item_transfer, G.TOY_BOX, toy), author, ...
		end

		-- When new transmogs are learned and put into the appearance collection.
		local appearance = string_match(message, P[G.LEARN_TRANSMOG])
		if (appearance) then
			return false, string_format(self.output.item_transfer, G.WARDROBE, appearance), author, ...
		end

		-- When a new mount is learned
		local mount = string_match(message, P[G.LEARN_MOUNT])
		if (mount) then
			return false, string_format(self.output.item_transfer, G.MOUNTS, mount), author, ...
		end

		-- When a new companion is learned
		local companion = string_match(message, P[G.LEARN_COMPANION])
		if (companion) then
			return false, string_format(self.output.item_transfer, G.COMPANIONS, companion), author, ...
		end

		-- When a new battle pet is learned
		local pet = string_match(message, P[G.LEARN_BATTLE_PET])
		if (pet) then
			return false, string_format(self.output.item_transfer, G.PETS, pet), author, ...
		end

		-- When a new battle pet is learned
		local heirloom = string_match(message, P[G.LEARN_HEIRLOOM])
		if (heirloom) then
			return false, string_format(self.output.item_transfer, G.HEIRLOOMS, heirloom), author, ...
		end

		-- Loot spec changed, or just reported
		-- This one fires on manual changes after login.
		-- The initial message on reloads or login is not captured here,
		-- as the chat frames haven't yet been registered for user events at that point.
		local lootspec = string_match(message, P[G.LOOT_SPEC_CHANGED])
		if (lootspec) then
			--lootspec = ns.Colors.class[playerClass].colorCode .. lootspec .. "|r"
			--return false, string_format(self.output.item_transfer, SELECT_LOOT_SPECIALIZATION, lootspec), author, ...
			return false, string_format(self.output.achievement2, G.SELECT_LOOT_SPECIALIZATION, lootspec), author, ...
		end

	end
end

Module.OnReplacementSet = function(self, msg, r, g, b, chatID, ...)

	-- Loot spec changed, or just reported
	-- This one will fire at the initial PLAYER_ENTERING_WORLD,
	-- as the chat frames haven't yet been registered for user events at that point.
	local lootspec = string_match(msg, P[G.LOOT_SPEC_CHANGED])
	if (lootspec) then

		--lootspec = ns.Colors.class[playerClass].colorCode .. lootspec .. "|r"
		--return string_format(self.output.item_transfer, SELECT_LOOT_SPECIALIZATION, lootspec)
		return string_format(self.output.achievement2, G.SELECT_LOOT_SPECIALIZATION, lootspec)
	end

end

Module.OnInitialize = function(self)
	self.output = ns:GetOutputTemplates()
	self.patterns = {}

	for i,global in ipairs({

		-- These all return item,
		-- and optionally an item count.
		"LOOT_ITEM_CREATED_SELF_MULTIPLE", 			-- "You create: %sx%d."
		"LOOT_ITEM_CREATED_SELF", 					-- "You create: %s."
		"LOOT_ITEM_SELF_MULTIPLE", 					-- "You receive loot: %sx%d."
		"LOOT_ITEM_SELF", 							-- "You receive loot: %s."
		"LOOT_ITEM_PUSHED_SELF_MULTIPLE", 			-- "You receive item: %sx%d."
		"LOOT_ITEM_PUSHED_SELF", 					-- "You receive item: %s."
		"LOOT_ITEM_REFUND", 						-- "You are refunded: %s."
		"LOOT_ITEM_REFUND_MULTIPLE", 				-- "You are refunded: %sx%d."
		"CURRENCY_GAINED", 							-- "You receive currency: %s."
		"CURRENCY_GAINED_MULTIPLE", 				-- "You receive currency: %s x%d."
		"CURRENCY_GAINED_MULTIPLE_BONUS", 			-- "You receive currency: %s x%d. (Bonus Objective)" -- Redundant?

		-- These apply to other players and will include player NAMES, not always links.
		-- but should hopefully still work as identifiers for the messages. Needs testing.
		"LOOT_ITEM", 								-- "%s receives loot: %s."
		"LOOT_ITEM_BONUS_ROLL", 					-- "%s receives bonus loot: %s."
		"LOOT_ITEM_BONUS_ROLL_MULTIPLE", 			-- "%s receives bonus loot: %sx%d."
		"LOOT_ITEM_MULTIPLE", 						-- "%s receives loot: %sx%d."
		"LOOT_ITEM_PUSHED", 						-- "%s receives item: %s."
		"LOOT_ITEM_PUSHED_MULTIPLE", 				-- "%s receives item: %sx%d."

		-- Don't filter these here,
		-- they are pure text for both names and items!
		--"CREATED_ITEM", 							-- "%s creates: %s."
		--"CREATED_ITEM_MULTIPLE", 					-- "%s creates: %sx%d."

	}) do
		-- Always check if the global exists,
		-- as a lot of these strings and filters
		-- do not apply to the classic clients.
		local msg = _G[global]
		if (msg) then
			table_insert(self.patterns, makePattern(msg))
		end
	end

	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnReplacementSetProxy = function(...) return self:OnReplacementSet(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true

	ns:AddReplacementSet(self.OnReplacementSetProxy)

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil

	ns:RemoveReplacementSet(self.OnReplacementSetProxy)

	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CURRENCY", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_LOOT", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
