local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Experience")

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local COMBATLOG_XPGAIN_EXHAUSTION1 = COMBATLOG_XPGAIN_EXHAUSTION1 -- "%s dies, you gain %d experience. (%s exp %s bonus)"
local COMBATLOG_XPGAIN_FIRSTPERSON = COMBATLOG_XPGAIN_FIRSTPERSON -- "%s dies, you gain %d experience."
local COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED = COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED -- "You gain %d experience."
local COMBATLOG_XPGAIN_QUEST = COMBATLOG_XPGAIN_QUEST -- "You gain %d experience. (%s exp %s bonus)"
local ERR_QUEST_REWARD_EXP_I = ERR_QUEST_REWARD_EXP_I -- "Experience gained: %d."
local ERR_ZONE_EXPLORED_XP = ERR_ZONE_EXPLORED_XP -- "Discovered %s: %d experience gained"
local XP = XP

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

	if (event == "CHAT_MSG_COMBAT_XP_GAIN") then

		-- Monster with rested bonus
		local xp_bonus_pattern = P[COMBATLOG_XPGAIN_EXHAUSTION1] -- "%s dies, you gain %d experience. (%s exp %s bonus)"
		local name, total, xp, bonus = string_match(message, xp_bonus_pattern)
		if (total) then
			return false, string_format("|cff888888+|r |cfff0f0f0%d|r |cffeaeaea%s:|r |cffffb200%s|r", total, XP, name), author, ...
		end

		-- Quest with rested bonus
		local xp_quest_rested_pattern = P[COMBATLOG_XPGAIN_QUEST] -- "You gain %d experience. (%s exp %s bonus)"
		name, total, xp, bonus = string_match(message, xp_bonus_pattern)
		if (total) then
			return false, string_format("|cff888888+|r |cfff0f0f0%d|r |cffeaeaea%s:|r |cffffb200%s|r", total, XP, name), author, ...
		end

		-- Named monster
		local xp_normal_pattern = P[COMBATLOG_XPGAIN_FIRSTPERSON] -- "%s dies, you gain %d experience."
		name, total = string_match(message, xp_normal_pattern)
		if (total) then
			return false, string_format("|cff888888+|r |cfff0f0f0%d|r |cffeaeaea%s:|r |cffffb200%s|r", total, XP, name), author, ...
		end

		-- Quest
		local xp_quest_pattern = P[COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED] -- "You gain %d experience."
		total = string_match(message, xp_quest_pattern)
		if (total) then
			return false, string_format("|cff888888+|r |cfff0f0f0%d|r |cffeaeaea%s|r", total, XP), author, ...
		end

	elseif (event == "CHAT_MSG_SYSTEM") then

		-- Unknown
		local xp_quest_pattern = P[ERR_QUEST_REWARD_EXP_I] -- "Experience gained: %d."
		total = string_match(message, xp_quest_pattern)
		if (total) then
			return false, string_format("|cff888888+|r |cfff0f0f0%d|r |cffeaeaea%s|r", total, XP), author, ...
		end
		
		-- Possibly CHAT_MSG_SYSTEM
		-- Discovery XP?
		local xp_discovery_pattern = P[ERR_ZONE_EXPLORED_XP] -- "Discovered %s: %d experience gained"
		local name, total = string_match(message, xp_discovery_pattern)
		if (total) then
			return false, string_format("|cff888888+|r |cfff0f0f0%d|r |cffeaeaea%s:|r |cffffb200%s|r", total, XP, name), author, ...
		end

	end

end

Module.OnInit = function(self)
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
