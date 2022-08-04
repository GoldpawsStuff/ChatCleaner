local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Quests")

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local SET_COMPLETE = ERR_COMPLETED_TRANSMOG_SET_S -- "You've completed the set %s."
local QUEST_ACCEPTED = ERR_QUEST_ACCEPTED_S -- "Quest accepted: %s"
local QUEST_COMPLETE = ERR_QUEST_COMPLETE_S -- "%s completed."
local QUEST = BATTLE_PET_SOURCE_2 -- "Quest"
local ACCEPTED = CALENDAR_STATUS_ACCEPTED -- "Accepted"
local COMPLETE = COMPLETE -- "Complete"

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
	local name

	-- Adding completed transmog sets here,
	-- to make sure they don't fire as completed quests.
	name = string_match(message, P[SET_COMPLETE])
	if (name) then
		name = string_gsub(name, "[%[/%]]", "")
		return false, string_format(self.output.set_complete, COMPLETE, name), author, ...
	end

	name = string_match(message, P[QUEST_ACCEPTED])
	if (name) then
		name = string_gsub(name, "[%[/%]]", "")
		return false, string_format(self.output.quest_accepted, ACCEPTED, name), author, ...
	end

	name = string_match(message, P[QUEST_COMPLETE])
	if (name) then
		name = string_gsub(name, "[%[/%]]", "")
		return false, string_format(self.output.quest_complete, COMPLETE, name), author, ...
	end
end

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.output = self:GetParent():GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	if (self.db["DisableFilter:"..self:GetName()]) then
		return self:SetUserDisabled()
	end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
