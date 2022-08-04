local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Reputation")

-- Lua API
local ipairs = ipairs
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local table_insert = table.insert
local type = type

-- WoW API
local GetFactionInfo = GetFactionInfo
local GetFriendshipReputation = GetFriendshipReputation
local GetNumFactions = GetNumFactions
local ExpandFactionHeader = ExpandFactionHeader

-- WoW Globals
local INCREASED = FACTION_STANDING_INCREASED -- "Your %s reputation has increased by %d."
local DECREASED = FACTION_STANDING_DECREASED -- "Your %s reputation has decreased by %d."
local INCREASED_GENERIC = FACTION_STANDING_INCREASED_GENERIC -- "Reputation with %s increased."
local DECREASED_GENERIC = FACTION_STANDING_DECREASED_GENERIC -- "Reputation with %s decreased."
local REPUTATION = REPUTATION

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
	local Colors = Private.Colors
	local standingID, factionID, isFriend
	for i = 1, GetNumFactions() do
		local factionName, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(i)

		if (factionName == faction) then
			standingID = standingId
			factionID = factionId

			if (Private.IsRetail) then
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
		for i = GetNumFactions(),1,-1 do
			local factionName, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(i)
			if (isHeader) and (isCollapsed) then
				ExpandFactionHeader(i)
			end
		end
		for i = 1, GetNumFactions() do
			local factionName, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(i)
			if (factionName == faction) then
				standingID = standingId
				factionID = factionId

				if (Private.IsRetail) then
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
	end
	return faction
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	local faction,value

	faction,value = fix(string_match(message,P[INCREASED]))
	if (faction) then
		if (value) then
			return false, string_format(self.output.standing, value, REPUTATION, faction), author, ...
		else
			return false, string_format(self.output.standing_generic, REPUTATION, faction), author, ...
		end
	end

	faction,value = fix(string_match(message,P[DECREASED]))
	if (faction) then
		if (value) then
			return false, string_format(self.output.standing_deficit, value, REPUTATION, faction), author, ...
		else
			return false, string_format(self.output.standing_deficit_generic, REPUTATION, faction), author, ...
		end
	end

	faction = fix(string_match(message,P[INCREASED_GENERIC]))
	if (faction) then
		return false, string_format(self.output.standing_generic, REPUTATION, faction), author, ...
	end

	faction = fix(string_match(message,P[DECREASED_GENERIC]))
	if (faction) then
		return false, string_format(self.output.standing_deficit_generic, REPUTATION, faction), author, ...
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
	ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", self.OnChatEventProxy)
end
