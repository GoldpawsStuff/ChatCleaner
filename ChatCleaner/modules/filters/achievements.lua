local Addon, Private = ...
if (Private.IsClassic) then
	return
end
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Achievements")

-- Addon Localization
local L = Core.L

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local ACHIEVEMENT_BROADCAST = ACHIEVEMENT_BROADCAST -- "%s has earned the achievement %s!"

-- Convert a WoW global string to a search pattern
local makePattern = function(msg)
	--msg = string_gsub(msg, "%%d", "(%%d+)")
	--msg = string_gsub(msg, "%%s", "(.+)")
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
	if (string_find(message, "|Hquestie")) then return end

	local player_name, achievement = string_match(message, P[ACHIEVEMENT_BROADCAST])
	if (player_name) and (achievement) then

		-- kill brackets
		player_name = string_gsub(player_name, "[%[/%]]", "")
		achievement = string_gsub(achievement, "[%[/%]]", "")

		return false, string_format(self.output.achievement, player_name, achievement), author, ...
	end
end

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.output = self:GetParent():GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end

	Core:GetModule("GUI"):AddMenuItem(self:GetName(),
		L["Achievements"],
		L["Simplify Achievement messages."]
	)

	if (self.db["DisableFilter:"..self:GetName()]) then
		return self:SetUserDisabled(true)
	end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_ACHIEVEMENT", self.OnChatEventProxy)
end
