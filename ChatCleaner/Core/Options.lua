--[[

	The MIT License (MIT)

	Copyright (c) 2024 Lars Norberg

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

local Options = ns:NewModule("Options", "LibMoreEvents-1.0", "AceConsole-3.0")

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- Libraries
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
--local AceGUI = LibStub("AceGUI-3.0")

-- GLOBALS: CopyTable, GetAddOnEnableState, GetNumAddOns, UnitName

-- Lua API
local ipairs = ipairs
local next = next
local select = select
local string_gsub = string.gsub
local string_upper = string.upper
local table_sort = table.sort
local type = type

-- WoW 11.0.x
local GetAddOnEnableState = GetAddOnEnableState or function(character, name) return C_AddOns.GetAddOnEnableState(name, character) end
local GetAddOnInfo = GetAddOnInfo or C_AddOns.GetAddOnInfo
local GetNumAddOns = GetNumAddOns or C_AddOns.GetNumAddOns

-- Utility
-------------------------------------------------------
local hasaddons = function(...)
	for i = 1,GetNumAddOns() do
		local name, _, _, loadable = GetAddOnInfo(i)
		for j = 1, select("#", ...) do
			local addon = select(j, ...)
			if (name == addon) then
				return (loadable and not(GetAddOnEnableState(UnitName("player"), i) == 0))
			end
		end
	end
end

local setter = function(info,val)
	ns.db.filters[info[#info]] = val
	local moduleName = string_gsub(info[#info], "^%l", string_upper)
	local module = ns:GetModule(moduleName, true)
	if (module) then
		if (val and not module:IsEnabled()) then
			module:Enable()
		elseif (not val and module:IsEnabled()) then
			module:Disable()
		end
	end
end

local getter = function(info)
	return ns.db.filters[info[#info]]
end

-- OptionsDBs
-------------------------------------------------------
local optionDB = {
	type = "group",
	args = {
		-- NOT YET IMPLEMENTED!
		--styleWindows = {
		--	order = 1,
		--	name = L["Style Chat Windows"],
		--	desc = L["Will apply a clean, minimalistic styling to the chat windows."],
		--	width = "full",
		--	type = "toggle",
		--	disabled = function(info) return hasaddons("AzeriteUI","TukUI","ElvUI","KkthnxUI","Prat-3.0","ls_Glass") end,
		--	set = function(info,value)
		--		ns.db.styling = value
		--		local windows = ns:GetModule("Windows", true)
		--		if (windows) then
		--			windows:UpdateSettings()
		--		end
		--	end,
		--	get = function(info) return ns.db.styling end,
		--},
		filterHeader = {
			order = 100,
			type = "header",
			name = L["Filter Selection"]
		}
	}
}

local filterDB = {
	achievements = (ns.IsWrath or ns.IsRetail) and {
		name = L["Achievements"],
		desc = L["Simplify Achievement messages."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	auctions = {
		name = L["Auctions"],
		desc = L["Suppress auction messages while auction frame is open, display summary after."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	channels = {
		name = L["Chat Channel Names"],
		desc = L["Abbreviate and simplify chat channel display names."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	experience = {
		name = L["Experience"],
		desc = L["Abbreviate and simplify experience- and level gains."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	followers = ns.IsRetail and {
		name = L["Garrison Followers"],
		desc = L["Abbreviate and simplify garrison- and mission table messages related to gained or lost followers."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	loot = {
		name = L["Loot"],
		desc = L["Abbreviate and simplify loot-, currency- and received item messages."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	names = {
		name = L["Player Names"],
		desc = L["Remove brackets from player names."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	quests = {
		name = L["Quests"],
		desc = L["Simplify quest completion- and progress messages."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	reputation = {
		name = L["Reputation"],
		desc = L["Simplify messages about reputation gain and loss."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	spells = {
		name = L["Learning (Spells)"],
		desc = L["Blacklist messages about new or removed spells, typically spammed on specialization changes."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	status = {
		name = L["Player Status"],
		desc = L["Simplify status messages about AFK, DND and being rested."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	},
	tradeskills = {
		name = L["Learning (Crafting)"],
		desc = L["Simplify messages about new or improved trade skills."],
		width = "full",
		type = "toggle",
		set = setter,
		get = getter
	}
}

Options.GenerateOptionsMenu = function(self)

	-- Sort filter entries by localized name.
	local sorted = {}
	for name,item in next,filterDB do
		if (item) then
			sorted[#sorted + 1] = { name = name, item = item }
		end
	end
	table_sort(sorted, function(a,b) return a.item.name < b.item.name end)

	-- Generate the options table.
	local options = CopyTable(optionDB)
	local order,count = 0,0
	for i,data in ipairs(sorted) do
		local item
		if (type(data.item) == "function") then
			item = data.item()
		else
			item = data.item
		end
		if (item) then
			count = count + 1
			order = order + 10
			item.order = 100 + order
			options.args[data.name] = item
		end
	end

	AceConfigRegistry:RegisterOptionsTable(Addon, options)
	AceConfigDialog:SetDefaultSize(Addon, 400, 180 + count*24)
end

Options.OpenOptionsMenu = function(self)
	if (AceConfigRegistry:GetOptionsTable(Addon)) then
		AceConfigDialog:Open(Addon)
	end
end

Options.OnEvent = function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		local isInitialLogin, isReloadingUi = ...
		if (isInitialLogin or isReloadingUi) then
			self:GenerateOptionsMenu()
			self:UnregisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
		end
	end
end

Options.OnInitialize = function(self)
	self:RegisterChatCommand("cc", "OpenOptionsMenu")
	self:RegisterChatCommand("chatcleaner", "OpenOptionsMenu")
end

Options.OnEnable = function(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
end
