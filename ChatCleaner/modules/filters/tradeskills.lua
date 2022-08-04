local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Tradeskills")

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local table_insert = table.insert
local tonumber = tonumber

-- WoW Globals
local SKILL_RANK_UP = SKILL_RANK_UP -- "Your skill in %s has increased to %d."
local LEARN_RECIPE = ERR_LEARN_RECIPE_S -- "You have learned how to create a new item: %s."
local LEARNED = TRADE_SKILLS_LEARNED_TAB -- "Learned"
local UNLEARNED = TRADE_SKILLS_UNLEARNED_TAB -- "Unlearned"

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

	local skill, gain = string_match(message, P[SKILL_RANK_UP])
	if (skill and gain) then
		gain = tonumber(gain)
		if (gain) then
			return false, string_format(self.output.item_multiple, skill, gain), author, ...
		end
	end

	local craft = string_match(message, P[LEARN_RECIPE])
	if (craft) then
		return false, string_format(self.output.objective_status, LEARNED, craft), author, ...
	end

end

Module.OnReplacementSet = function(self, msg, r, g, b, chatID, ...)
	-- Loot spec changed, or just reported
	-- This one will fire at the initial PLAYER_ENTERING_WORLD,
	-- as the chat frames haven't yet been registered for user events at that point.
	local craft = string_match(msg, P[LEARN_RECIPE])
	if (craft) then
		return string_format(self.output.objective_status, LEARNED, craft)
	end
end

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.output = self:GetParent():GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnReplacementSetProxy = function(...) return self:OnReplacementSet(...) end
	if (self.db["DisableFilter:"..self:GetName()]) then
		return self:SetUserDisabled()
	end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	self:GetParent():AddReplacementSet(self.OnReplacementSetProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SKILL", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self:GetParent():RemoveReplacementSet(self.OnReplacementSetProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SKILL", self.OnChatEventProxy)
end
