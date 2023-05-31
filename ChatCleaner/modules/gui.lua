local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end

local GUI = Core:NewModule("GUI")

-- Addon Localization
local L = Core.L

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local setter = function(info,val)
	Core:GetSavedSettings()["DisableFilter:"..info[#info]] = not val
end

local getter = function(info)
	return not Core:GetSavedSettings()["DisableFilter:"..info[#info]]
end

GUI.AddMenuItem = function(self, moduleName, optionName, optionDescription)
	if (not self.objects) then
		self.objects = {}
	end
	self.objects[#self.objects + 1] = {
		name = moduleName,
		item = {
			name = optionName,
			desc = optionDescription,
			width = "full",
			type = "toggle",
			set = setter,
			get = getter
		}
	}
end

GUI.GenerateOptionsObject = function(self)
	local options = {
		type = "group",
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Filter Selection"]
			},
			applyHeader = {
				order = 1000,
				type = "header",
				name = APPLY
			},
			apply = {
				order = 1001,
				name = RELOADUI,
				type = "execute",
				width = "full",
				desc = L["Apply the current settings and reload the UI. Settings will still be stored if you don't do this, but won't be applied until you reload the user interface, relog or exit the game."],
				func = ReloadUI
			}
		}
	}
	return options
end

GUI.GenerateOptionsMenu = function(self)
	if (not self.objects) then return end

	-- Sort groups by localized name.
	table.sort(self.objects, function(a,b) return a.item.name < b.item.name end)

	-- Generate the options table.
	local options = self:GenerateOptionsObject()
	local order,count = 0,0
	for i,data in ipairs(self.objects) do

		local item
		if (type(data.item) == "function") then
			item = data.item()
		else
			item = data.item
		end
		if (item) then
			count = count + 1
			order = order + 10
			item.order = order
			options.args[data.name] = item
		end
	end

	AceConfigRegistry:RegisterOptionsTable(Addon, options)
	AceConfigDialog:SetDefaultSize(Addon, 400, 180 + count*24)
end

GUI.OpenOptionsMenu = function(self)
	if (AceConfigRegistry:GetOptionsTable(Addon)) then
		AceConfigDialog:Open(Addon)
	end
end

GUI.OnEvent = function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		local isInitialLogin, isReloadingUi = ...
		if (isInitialLogin or isReloadingUi) then
			self:GenerateOptionsMenu()
			self:UnregisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
		end
	end
end

GUI.OnInit = function(self)
	self:RegisterChatCommand("/cc", "OpenOptionsMenu")
	self:RegisterChatCommand("/chatcleaner", "OpenOptionsMenu")
end

GUI.OnEnable = function(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
end
