local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Loot")

-- Lua API
local ipairs = ipairs
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local string_sub = string.sub
local table_insert = table.insert
local tonumber = tonumber

-- WoW Globals
local LEARN_COMPANION = ERR_LEARN_COMPANION_S -- "You have added the pet %s to your collection."
local LEARN_MOUNT = ERR_LEARN_MOUNT_S -- "You have added the mount %s to your collection."
local LEARN_TOY = ERR_LEARN_TOY_S -- "%s has been added to your Toy Box."
local LEARN_TRANSMOG = ERR_LEARN_TRANSMOG_S -- "%s has been added to your appearance collection."
local COMPANIONS = COMPANIONS -- "Companions"
local MOUNTS = MOUNTS -- "Mounts"
local TOY_BOX = TOY_BOX -- "Toy Box"
local WARDROBE = WARDROBE -- "Appearances"
local LOOT_SPEC_CHANGED = ERR_LOOT_SPEC_CHANGED_S -- "Loot Specialization set to: %s"
local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION -- "Loot Specialization"

local _,playerClass = UnitClass("player")

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

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	if (event == "CHAT_MSG_LOOT") or (event == "CHAT_MSG_CURRENCY") then
		for i,pattern in ipairs(self.patterns) do

			local item, count = string_match(message,pattern)
			if (item) then
				-- The patterns above tend to fail on the number,
				-- so we do this ugly non-localized hack instead.
				-- |cffffffff|Hitem:itemID:::::|h[display name]|h|r
				local first, last = string_find(message, "|c(.+)|r")
				if (first and last) then
					local item = string_sub(message, first, last)
					item = string_gsub(item, "[%[/%]]", "") -- kill brackets
					local countString = string_sub(message, last + 1)
					local count = tonumber(string_match(countString, "(%d+)"))
					if (count) and (count > 1) then
						return false, string_format(self.output.item_multiple, item, count), author, ...
					else
						return false, string_format(self.output.item_single, item), author, ...
					end
				end
			end
		end

	elseif (event == "CHAT_MSG_SYSTEM") then

		-- When new toys are learned and put into the toy box.
		local toy = string_match(message, P[LEARN_TOY])
		if (toy) then
			return false, string_format(self.output.item_transfer, TOY_BOX, toy), author, ...
		end

		-- When new transmogs are learned and put into the appearance collection.
		local appearance = string_match(message, P[LEARN_TRANSMOG])
		if (appearance) then
			return false, string_format(self.output.item_transfer, WARDROBE, appearance), author, ...
		end

		-- When a new mount is learned
		local mount = string_match(message, P[LEARN_MOUNT])
		if (mount) then
			return false, string_format(self.output.item_transfer, MOUNTS, mount), author, ...
		end

		-- When a new companion is learned (doesn't do "has been added to your pet journal!")
		local companion = string_match(message, P[LEARN_COMPANION])
		if (companion) then
			return false, string_format(self.output.item_transfer, COMPANIONS, companion), author, ...
		end

		-- Loot spec changed, or just reported
		-- This one fires on manual changes after login.
		-- The initial message on reloads or login is not captured here, 
		-- as the chat frames haven't yet been registered for user events at that point.
		local lootspec = string_match(message, P[LOOT_SPEC_CHANGED])
		if (lootspec) then 
			lootspec = Private.Colors.class[playerClass].colorCode .. lootspec .. "|r"
			return false, string_format(self.output.item_transfer, SELECT_LOOT_SPECIALIZATION, lootspec), author, ...
		end

	end
end

Module.OnReplacementSet = function(self, msg, r, g, b, chatID, ...)

	-- Loot spec changed, or just reported
	-- This one will fire at the initial PLAYER_ENTERING_WORLD, 
	-- as the chat frames haven't yet been registered for user events at that point.
	local lootspec = string_match(msg, P[LOOT_SPEC_CHANGED])
	if (lootspec) then
		lootspec = Private.Colors.class[playerClass].colorCode .. lootspec .. "|r"
		return string_format(self.output.item_transfer, SELECT_LOOT_SPECIALIZATION, lootspec)
	end

end

Module.OnInit = function(self)
	self.output = self:GetParent():GetOutputTemplates()
	self.patterns = {}
	for i,global in ipairs({
		"LOOT_ITEM_CREATED_SELF", 					-- "You create: %s."
		"LOOT_ITEM_SELF_MULTIPLE", 					-- "You receive loot: %sx%d."
		"LOOT_ITEM_SELF", 							-- "You receive loot: %s."
		"LOOT_ITEM_PUSHED_SELF_MULTIPLE", 			-- "You receive item: %sx%d."
		"LOOT_ITEM_PUSHED_SELF", 					-- "You receive item: %s."
		"CURRENCY_GAINED", 							-- "You receive currency: %s."
		"CURRENCY_GAINED_MULTIPLE", 				-- "You receive currency: %s x%d."
		"CURRENCY_GAINED_MULTIPLE_BONUS", 			-- "You receive currency: %s x%d. (Bonus Objective)" -- Redundant?
	}) do 
		-- Currency globals dont exist in Classic.
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
	self:GetParent():AddReplacementSet(self.OnReplacementSetProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self:GetParent():RemoveReplacementSet(self.OnReplacementSetProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CURRENCY", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_LOOT", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
