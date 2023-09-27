local Addon, ns = ...

local Module = ns:NewModule("Spells")

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
local LEARN_ABILITY = ERR_LEARN_ABILITY_S -- "You have learned a new ability: %s."
local LEARN_PASSIVE = ERR_LEARN_PASSIVE_S -- "You have learned a new passive effect: %s."
local LEARN_SPELL = ERR_LEARN_SPELL_S -- "You have learned a new spell: %s."
local SPELL_UNLEARNED = ERR_SPELL_UNLEARNED_S -- "You have unlearned %s."

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

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
end

Module.OnInitialize = function(self)
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ns:AddBlacklistMethod(self.OnAddMessageProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ns:RemoveBlacklistMethod(self.OnAddMessageProxy)
end
