local Addon, Private = ...
if (Private.IsClassic) then
	return
end
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Achievements")

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local ACHIEVEMENT_BROADCAST = ACHIEVEMENT_BROADCAST

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
	-- Achievement announce
	local achievement_pattern = P[ACHIEVEMENT_BROADCAST] -- "%s has earned the achievement %s!"
	local player_name, achievement = string_match(message, achievement_pattern)
	if (player_name) and (achievement) then

		-- kill brackets
		player_name = string_gsub(player_name, "[%[/%]]", "")
		achievement = string_gsub(achievement, "[%[/%]]", "")
		
		return false, string_format("!%s: %s", player_name, achievement), author, ...
	end

	-- Pass everything else through
	return false, message, author, ...
end

Module.OnInit = function(self)
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_ACHIEVEMENT", self.OnChatEventProxy)
end