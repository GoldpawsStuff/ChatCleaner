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

-- Convert a WoW global string to a search pattern
local makePattern = function(msg)
	msg = string_gsub(msg, "%%d", "(%%d+)")
	msg = string_gsub(msg, "%%s", "(.+)")
	msg = string_gsub(msg, "%%(%d+)%$d", "%%%%%1$(%%d+)")
	msg = string_gsub(msg, "%%(%d+)%$s", "%%%%%1$(%%s+)")
	return msg
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
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
					return false, string_format("|cff888888+|r %s |cffeaeaea(%d)|r", item, count), author, ...
				else
					return false, string_format("|cff888888+|r %s", item), author, ...
				end
			else
				return false, message, author, ...
				-- return false, string_gsub(message, "|", "||"), author, ... -- debug output
			end
		end
	end
end

Module.OnInit = function(self)
	self.patterns = {}
	for i,global in ipairs({
		"LOOT_ITEM_CREATED_SELF", 					-- "You create: %s."
		"LOOT_ITEM_SELF_MULTIPLE", 					-- "You receive loot: %sx%d."
		"LOOT_ITEM_SELF", 							-- "You receive loot: %s."
		"LOOT_ITEM_PUSHED_SELF_MULTIPLE", 			-- "You receive item: %sx%d."
		"LOOT_ITEM_PUSHED_SELF", 					-- "You receive item: %s."
		"CURRENCY_GAINED", 							-- "You receive currency: %s."
		"CURRENCY_GAINED_MULTIPLE", 				-- "You receive currency: %s x%d."
		"CURRENCY_GAINED_MULTIPLE_BONUS", 			-- "You receive currency: %s x%d. (Bonus Objective)"
	}) do 
		-- Currency globals dont exist in Classic.
		local msg = _G[global]
		if (msg) then 
			table_insert(self.patterns, makePattern(msg))
		end
	end
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_LOOT", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CURRENCY", self.OnChatEventProxy)
end
