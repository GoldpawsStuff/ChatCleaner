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
local SKILL_RANK_UP = SKILL_RANK_UP

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
	local skillup_pattern = P[SKILL_RANK_UP] -- "Your skill in %s has increased to %d."
	local skill, gain = string_match(message, skillup_pattern)
	if (skill and gain) then
		gain = tonumber(gain)
		if (gain) then
			return false, string_format(self.output.item_multiple, skill, gain), author, ...
		end
	end
end

Module.OnInit = function(self)
	self.output = self:GetParent():GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SKILL", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SKILL", self.OnChatEventProxy)
end
