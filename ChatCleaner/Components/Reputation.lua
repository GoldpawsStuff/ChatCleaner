--[[

	The MIT License (MIT)

	Copyright (c) 2023 Lars Norberg

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]]
local Addon, ns = ...

local Module = ns:NewModule("Reputation")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))
-- GLOBALS: GetNumFactions, GetFactionInfo, GetFriendshipReputation, CollapseFactionHeader, ExpandFactionHeader

-- Lua API
local ipairs = ipairs
local next = next
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local table_insert = table.insert
local tonumber = tonumber
local type = type

-- WoW Globals
local G = {
	INCREASED = FACTION_STANDING_INCREASED, -- "Your %s reputation has increased by %d."
	DECREASED = FACTION_STANDING_DECREASED, -- "Your %s reputation has decreased by %d."
	INCREASED_GENERIC = FACTION_STANDING_INCREASED_GENERIC, -- "Reputation with %s increased."
	DECREASED_GENERIC = FACTION_STANDING_DECREASED_GENERIC, -- "Reputation with %s decreased."
	REPUTATION = REPUTATION
}

-- Convert a WoW global string to a search pattern
local makePattern = function(msg)
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
	return string,number
end

Module.GetFactionColored = function(self, faction)
	local Colors = ns.Colors
	local standingID, factionID, isFriend

	for i = 1, GetNumFactions() do
		local factionName, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(i)

		if (factionName == faction) then
			standingID = standingId
			factionID = factionId

			if (ns.IsRetail) then
				local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
				if (friendID) then
					isFriend = true
				end
			end

			if (factionID) and (standingID) then
				faction = Colors[isFriend and "friendship" or "reaction"][standingID].colorCode .. faction .. "|r"
			end
			break
		end
	end

	-- If nothing was found, the header was most likely collapsed.
	-- Going to force all headers to be expanded now, and repeat.
	if (not factionID) then

		-- Expand all headers in order to search.
		local collapsedHeaders = {}
		for i = GetNumFactions(),1,-1 do
			local factionName, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(i)
			if (isHeader) and (isCollapsed) then
				collapsedHeaders[i] = true
				ExpandFactionHeader(i)
			end
		end
		for i = 1, GetNumFactions() do
			local factionName, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(i)
			if (factionName == faction) then
				standingID = standingId
				factionID = factionId

				if (ns.IsRetail) then
					local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
					if (friendID) then
						isFriend = true
					end
				end

				if (factionID) and (standingID) then
					faction = Colors[isFriend and "friendship" or "reaction"][standingID].colorCode .. faction .. "|r"
				end
				break
			end
		end

		-- Collapse headers we previously expanded.
		for i in next,collapsedHeaders do
			CollapseFactionHeader(i)
		end
	end
	return faction
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	local faction,value

	faction,value = fix(string_match(message,P[G.INCREASED]))
	if (faction) then
		if (value) then
			return false, string_format(ns.out.standing, value, G.REPUTATION, faction), author, ...
		else
			return false, string_format(ns.out.standing_generic, G.REPUTATION, faction), author, ...
		end
	end

	faction,value = fix(string_match(message,P[G.DECREASED]))
	if (faction) then
		if (value) then
			return false, string_format(ns.out.standing_deficit, value, G.REPUTATION, faction), author, ...
		else
			return false, string_format(ns.out.standing_deficit_generic, G.REPUTATION, faction), author, ...
		end
	end

	faction = fix(string_match(message,P[G.INCREASED_GENERIC]))
	if (faction) then
		return false, string_format(ns.out.standing_generic, G.REPUTATION, faction), author, ...
	end

	faction = fix(string_match(message,P[G.DECREASED_GENERIC]))
	if (faction) then
		return false, string_format(ns.out.standing_deficit_generic, G.REPUTATION, faction), author, ...
	end
end

local onChatEventProxy = function(...)
	return Module:OnChatEvent(...)
end

Module.OnEnable = function(self)
	self:RegisterMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", onChatEventProxy)
end

Module.OnDisable = function(self)
	self:UnregisterMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", onChatEventProxy)
end
