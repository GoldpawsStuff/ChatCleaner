local L = LibStub("AceLocale-3.0"):NewLocale((...), "enUS", true, true)

-- These are chat channel abbreviations.
-- For the most part these match the /slash command to type in these channels,
-- so unless that command is something else in different regions, don't localize it!
L["BGL"] = true 	-- Battleground Leader (WoW Classic)
L["BG"] = true 		-- Battleground (WoW Classic)
L["PL"] = true 		-- Party Leader
L["P"] = true 		-- Party
L["RL"] = true 		-- Raid Leader
L["R"] = true 		-- Raid
L["IL"] = true 		-- Instance Leader (WoW Retail)
L["I"] = true 		-- Instance (WoW Retail)
L["G"] = true 		-- Guild
L["O"] = true 		-- Officer

L["Style Chat Windows"] = true
L["Will apply a clean, minimalistic styling to the chat windows."] = true

L["Filter Selection"] = true
L["Choose which chat filters should be activated. Setting changes require a reload to take effect."] = true
L["Apply the current settings and reload the UI. Settings will still be stored if you don't do this, but won't be applied until you reload the user interface, relog or exit the game."] = true

L["Achievements"] = true
L["Simplify Achievement messages."] = true

L["Auctions"] = true
L["Suppress auction messages while auction frame is open, display summary after."] = true

L["Chat Channel Names"] = true
L["Abbreviate and simplify chat channel display names."] = true

L["Experience"] = true
L["Abbreviate and simplify experience- and level gains."] = true

L["Garrison Followers"] = true
L["Abbreviate and simplify garrison- and mission table messages related to gained or lost followers."] = true

L["Loot"] = true
L["Abbreviate and simplify loot-, currency- and received item messages."] = true

L["Player Names"] = true
L["Remove brackets from player names."] = true

L["Quests"] = true
L["Simplify quest completion- and progress messages."] = true

L["Reputation"] = true
L["Simplify messages about reputation gain and loss."] = true

L["Learning (Spells)"] = true
L["Blacklist messages about new or removed spells, typically spammed on specialization changes."] = true

L["Player Status"] = true
L["Simplify status messages about AFK, DND and being rested."] = true

L["Learning (Crafting)"] = true
L["Simplify messages about new or improved trade skills."] = true
