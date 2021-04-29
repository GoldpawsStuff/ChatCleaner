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

local makePattern = function(msg)
	msg = string_gsub(msg, "%%d", "(%%d+)")
	msg = string_gsub(msg, "%%s", "(.+)")
	msg = string_gsub(msg, "%%(%d+)%$d", "%%%%%1$(%%d+)")
	msg = string_gsub(msg, "%%(%d+)%$s", "%%%%%1$(%%s+)")
	return msg
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
	local Colors = Private.Colors
	for i,pattern in ipairs(self.patterns) do
		local faction,value
		local a,b = string_match(message,pattern)
		if (type(a) == "string") then
			faction = a
			value = b
		elseif (type(b) == "string") then
			faction = b
			value = a
		end
		if (faction) then
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
			if (value) then
				return false, string_format("|cff888888+|r |cfff0f0f0".."%d|r |cffeaeaea%s:|r %s", value, REPUTATION, faction), author, ...
			else
				return false, string_format("|cff888888+ %s:|r %s", REPUTATION, faction), author, ...
			end
		end
	end

end

Module.OnInit = function(self)
	self.patterns = {}
	-- Patterns to identify reputation changes.
	for i,global in ipairs({
		"FACTION_STANDING_INCREASED", -- "Your %s reputation has increased by %d."
		--"FACTION_STANDING_DECREASED", -- "Your %s reputation has decreased by %d."
		"FACTION_STANDING_INCREASED_GENERIC", -- "Reputation with %s increased."
		--"FACTION_STANDING_DECREASED_GENERIC", -- "Reputation with %s decreased."
	}) do
		local msg = _G[global]
		if (msg) then
			table_insert(self.patterns, makePattern(msg))
		end
	end

	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", self.OnChatEventProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", self.OnChatEventProxy)
end
