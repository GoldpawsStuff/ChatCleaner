local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Status")

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local CLEARED_AFK = CLEARED_AFK -- "You are no longer AFK."
local CLEARED_DND = CLEARED_DND -- "You are no longer marked DND."
local DEFAULT_AFK_MESSAGE = DEFAULT_AFK_MESSAGE -- "Away from Keyboard"
local DEFAULT_DND_MESSAGE = DEFAULT_DND_MESSAGE -- "Do not Disturb"
local MARKED_AFK = MARKED_AFK -- "You are now AFK."
local MARKED_AFK_MESSAGE = MARKED_AFK_MESSAGE -- "You are now AFK: %s"
local MARKED_DND = MARKED_DND -- "You are now DND: %s."
local EXHAUSTION_NORMAL = ERR_EXHAUSTION_NORMAL -- "You feel normal."
local EXHAUSTION_WELLRESTED = ERR_EXHAUSTION_WELLRESTED -- "You feel well rested."

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

	-- AFK
	if (message == MARKED_AFK) then
		return false, self.output.afk_added, author, ...
	end
	if (message == CLEARED_AFK) then
		return false, self.output.afk_cleared, author, ...
	end
	local afk_message = string_match(message, P[MARKED_AFK_MESSAGE])
	if (afk_message) then
		if (afk_message == DEFAULT_AFK_MESSAGE) then
			return false, self.output.afk_added, author, ...
		end
		return false, string_format(self.output.afk_added_message, afk_message), author, ...
	end

	-- DND
	if (message == CLEARED_DND) then
		return false, self.output.dnd_cleared, author, ...
	end
	local dnd_message = string_match(message, P[MARKED_DND] )
	if (dnd_message) then
		if (dnd_message == DEFAULT_DND_MESSAGE) then
			return false, self.output.dnd_added, author, ...
		end
		return false, string_format(self.output.dnd_added_message, dnd_message), author, ...
	end

	-- Rested TODO: Move to XP!
	if (message == EXHAUSTION_WELLRESTED) then
		return false, self.output.rested_added, author, ...
	end
	if (message == EXHAUSTION_NORMAL) then
		return false, self.output.rested_cleared, author, ...
	end

end

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.output = self:GetParent():GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
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
