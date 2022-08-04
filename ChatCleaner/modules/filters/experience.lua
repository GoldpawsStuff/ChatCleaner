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
local ERR_ZONE_EXPLORED_XP = ERR_ZONE_EXPLORED_XP 		-- "Discovered %s: %d experience gained"
local ERR_QUEST_REWARD_EXP_I = ERR_QUEST_REWARD_EXP_I 	-- "Experience gained: %d."
local XP = XP

-- All of these contain the first pattern,
-- and the first pattern contains all we wish to show.
local NAMED = COMBATLOG_XPGAIN_FIRSTPERSON 				-- "%s dies, you gain %d experience."
-- COMBATLOG_XPGAIN_FIRSTPERSON_GROUP					-- "%s dies, you gain %d experience. (+%d group bonus)"
-- COMBATLOG_XPGAIN_FIRSTPERSON_RAID 					-- "%s dies, you gain %d experience. (-%d raid penalty)"
-- COMBATLOG_XPGAIN_EXHAUSTION1 						-- "%s dies, you gain %d experience. (%s exp %s bonus)"
-- COMBATLOG_XPGAIN_EXHAUSTION1_GROUP 					-- "%s dies, you gain %d experience. (%s exp %s bonus, +%d group bonus)"
-- COMBATLOG_XPGAIN_EXHAUSTION1_RAID 					-- "%s dies, you gain %d experience. (%s exp %s bonus, -%d raid penalty)"
-- COMBATLOG_XPGAIN_EXHAUSTION2 						-- "%s dies, you gain %d experience. (%s exp %s bonus)"
-- COMBATLOG_XPGAIN_EXHAUSTION2_GROUP 					-- "%s dies, you gain %d experience. (%s exp %s bonus, +%d group bonus)"
-- COMBATLOG_XPGAIN_EXHAUSTION2_RAID 					-- "%s dies, you gain %d experience. (%s exp %s bonus, -%d raid penalty)"
-- COMBATLOG_XPGAIN_EXHAUSTION4 						-- "%s dies, you gain %d experience. (%s exp %s penalty)"
-- COMBATLOG_XPGAIN_EXHAUSTION4_GROUP 					-- "%s dies, you gain %d experience. (%s exp %s penalty, +%d group bonus)"
-- COMBATLOG_XPGAIN_EXHAUSTION4_RAID 					-- "%s dies, you gain %d experience. (%s exp %s penalty, -%d raid penalty)"
-- COMBATLOG_XPGAIN_EXHAUSTION5 						-- "%s dies, you gain %d experience. (%s exp %s penalty)"
-- COMBATLOG_XPGAIN_EXHAUSTION5_GROUP 					-- "%s dies, you gain %d experience. (%s exp %s penalty, +%d group bonus)"
-- COMBATLOG_XPGAIN_EXHAUSTION5_RAID 					-- "%s dies, you gain %d experience. (%s exp %s penalty, -%d raid penalty)"

-- Same applies here as above. A single pattern is enough.
local UNNAMED = COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED 	-- "You gain %d experience."
-- COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_GROUP 			-- "You gain %d experience. (+%d group bonus)"
-- COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_RAID 			-- "You gain %d experience. (-%d raid penalty)"
-- COMBATLOG_XPGAIN_QUEST 								-- "You gain %d experience. (%s exp %s bonus)"

-- "Congratulations, you have reached |cffFF4E00|Hlevelup:%d:LEVEL_UP_TYPE_CHARACTER|h[Level %d]|h|r!"
local LEVEL_UP = LEVEL_UP

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
local P = setmetatable({
	-- Special handling. We capture the entire colored, clickable level link.
	[LEVEL_UP] = string_gsub(LEVEL_UP, "(|.+|r)", "(.+)")
}, { __index = function(t,k)
	rawset(t,k,makePattern(k))
	return rawget(t,k)
end })

local fix = function(...)
	local string,number,n
	for i,v in next,{...} do
		n = tonumber(v)
		if (n) and (n > 0) then
			number = n
		elseif (not n) then
			string = v
		end
	end
	return number,string
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	local value,source
	if (event == "CHAT_MSG_COMBAT_XP_GAIN") then

		value,source = fix(string_match(message, P[NAMED]))
		if (value) then
			return false, string_format(self.output.xp_named, value, XP, source), author, ...
		end

		value = string_match(message, P[UNNAMED])
		if (value) then
			return false, string_format(self.output.xp_unnamed, value, XP), author, ...
		end

	elseif (event == "CHAT_MSG_SYSTEM") then

		-- Area discovery
		value,source = fix(string_match(message, P[ERR_ZONE_EXPLORED_XP]))
		if (value) then
			return false, string_format(self.output.xp_named, value, XP, source), author, ...
		end

		-- Level up
		value = string_match(message, P[LEVEL_UP])
		if (value) then
			value = string_gsub(value, "[%[/%]]", "")
			return false, string_format(self.output.xp_levelup, value), author, ...
		end

		-- Quest Completed (also reported in the XP channel)
		if (string_match(message, P[ERR_QUEST_REWARD_EXP_I])) then
			return true
		end
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
	ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", self.OnChatEventProxy)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", self.OnChatEventProxy)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
