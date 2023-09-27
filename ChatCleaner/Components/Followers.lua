local Addon, ns = ...

if (ns.IsClassic or ns.IsWrath) then return end

local Module = ns:NewModule("Followers")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- Lua API
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

-- WoW Globals
local GARRISON_FOLLOWER_ADDED = GARRISON_FOLLOWER_ADDED -- "%s recruited."
local GARRISON_FOLLOWER_DISBANDED = GARRISON_FOLLOWER_DISBANDED -- "%s has been exhausted."
local GARRISON_FOLLOWER_REMOVED = GARRISON_FOLLOWER_REMOVED -- "%s is no longer your follower."

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

	-- Exhausted
	local follower_exhausted_pattern = P[GARRISON_FOLLOWER_DISBANDED] -- "%s has been exhausted."
	local follower_name = string_match(message, follower_exhausted_pattern)
	if (follower_name) then
		return false, string_format(self.output.item_deficit, follower_name), author, ...
	end

	-- Removed
	local follower_removed_pattern = P[GARRISON_FOLLOWER_REMOVED] -- "%s is no longer your follower."
	follower_name = string_match(message, follower_removed_pattern)
	if (follower_name) then
		return false, string_format(self.output.item_deficit, follower_name), author, ...
	end

	-- Added
	local follower_added_pattern = P[GARRISON_FOLLOWER_ADDED] -- "%s recruited."
	follower_name = string_match(message, follower_added_pattern)
	if (follower_name) then
		follower_name = string_gsub(follower_name, "[%[/%]]", "") -- kill brackets
		return false, string_format(self.output.item_single, follower_name), author, ...
	end

	-- GARRISON_FOLLOWER_LEVEL_UP = "LEVEL UP!"
	-- GARRISON_FOLLOWER_XP_ADDED_ZONE_SUPPORT = "%s has earned %d xp."
	-- GARRISON_FOLLOWER_XP_ADDED_ZONE_SUPPORT_LEVEL_UP = "%s is now level %d!"
	-- GARRISON_FOLLOWER_XP_ADDED_ZONE_SUPPORT_QUALITY_UP = "%s has gained a quality level!"
end

Module.OnInitialize = function(self)
	self.output = ns:GetOutputTemplates()
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnChatEventProxy)
end
