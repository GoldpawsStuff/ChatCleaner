local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end

local L = Core.L
local GUI = Core:NewModule("GUI")

-- Lua API
local pairs = pairs
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local table_insert = table.insert
local table_sort = table.sort
local type = type

-- WoW API
local CreateFont = CreateFont

-- Utility
-----------------------------------------------------------
-- Metatable that automatically
-- creates the needed tables and font objects.
local font_metatable
do
	local prefix, count = Addon.."Font", 0
	font_metatable = {
		__index = function(t,k)
			if (type(k) == "string") then
				local new = setmetatable({},font_metatable)
				rawset(t,k,new)
				return new
			elseif (type(k) == "number") then
				count = count + 1
				local new = CreateFont(prefix..count)
				rawset(t,k,new)
				return new
			end
		end
	}
end

-- Return a font object, re-use existing ones that match.
local Fonts = setmetatable({}, font_metatable)
local GetFont = function(size, outline, type)
	local inherit = type == "Chat" and ChatFontNormal or type == "Number" and NumberFont_Normal_Med or Game16Font
	local fontObject = Fonts[type or "Normal"][outline and "Outline" or "None"][size]
	if (fontObject:GetFontObject() ~= inherit) then
		fontObject:SetFontObject(inherit)
		fontObject:SetFont(fontObject:GetFont(), size, outline and "OUTLINE" or "")
		fontObject:SetShadowColor(0,0,0,0)
		fontObject:SetShadowOffset(0,0)
	end
	return fontObject
end

-- Retrieve media from the disk
local GetMedia = function(name, type)
	return ([[Interface\AddOns\%s\media\%s.%s]]):format(Addon, name, type or "tga")
end

local SortByName = function(a,b)
	if (a) and (b) then
		if (a.title) and (b.title) then
			return (a.title > b.title)
		else
			return (a.title) and true or false
		end
	else
		return (a) and true or false
	end
end

-- Widget API
-----------------------------------------------------------


-- Module API
-----------------------------------------------------------
GUI.GetGUI = function(self)
	if (not self.gui) then
		local gui = CreateFrame("Frame", nil, UIParent, Private.BackdropTemplate)
		gui:Hide()

		gui:SetIgnoreParentScale(true)
		gui:SetScale(768/1080)
		gui:SetSize(660,60)
		gui:SetPoint("CENTER")

		local r, g, b, a = 0, 0, 0, .75
		local centerSize = 660/3

		local center = gui:CreateTexture(nil, "BACKGROUND")
		center:SetPoint("RIGHT", gui, "CENTER", centerSize/2, 0)
		center:SetPoint("LEFT", gui, "CENTER", -centerSize/2, 0)
		center:SetPoint("TOP", gui, "TOP")
		center:SetPoint("BOTTOM", gui, "BOTTOM")
		center:SetColorTexture(r, g, b, a)

		local left = gui:CreateTexture(nil, "BACKGROUND")
		left:SetPoint("RIGHT", center, "LEFT")
		left:SetPoint("LEFT", gui, "LEFT")
		left:SetPoint("TOP", gui, "TOP")
		left:SetPoint("BOTTOM", gui, "BOTTOM")
		left:SetColorTexture(r, g, b, a)
		left:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 0, 1, 1, 1, 1)

		local right = gui:CreateTexture(nil, "BACKGROUND")
		right:SetPoint("LEFT", center, "RIGHT")
		right:SetPoint("RIGHT", gui, "RIGHT")
		right:SetPoint("TOP", gui, "TOP")
		right:SetPoint("BOTTOM", gui, "BOTTOM")
		right:SetColorTexture(r, g, b, a)
		right:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 1, 1, 1, 1, 0)

		local label = gui:CreateFontString(nil, "OVERLAY")
		label:SetFontObject(GetFont(32), true)
		label:SetTextColor(unpack(Private.Colors.offwhite))
		label:SetPoint("CENTER")
		label:SetJustifyH("CENTER")
		label:SetJustifyV("MIDDLE")
		label:SetText("Achievements")

		local createDummyList = function()
			local list = {
				"Achievements",
				"Auctions",
				"Experience",
				"Loot & Currency",
				"Learning & Unlearning",
				"Reputation",
				"Colors: Class",
				"Colors: Quality",
			}
		end
		createDummyList()

		local onShow = function(self)
			-- Pass keyboard input to other frames while visible.
			self:SetPropagateKeyboardInput(true)
		end

		local onKeyDown = function(self, key)
			if (key == "ESCAPE") then
				-- If Escape is pressed, consume the input,
				-- to prevent it from closing any other windows than ours.
				self:SetPropagateKeyboardInput(false)
				self:Hide()
			end
		end

		local onEnter = function(self)
		end

		local onLeave = function(self)
		end

		gui:EnableKeyboard(true)
		gui:EnableMouse(true)
		gui:EnableMouseWheel(true)
		gui:SetMouseMotionEnabled(true)
		gui:SetMouseClickEnabled(true)
		gui:SetScript("OnKeyDown", onKeyDown)
		gui:SetScript("OnEnter", onEnter)
		gui:SetScript("OnLeave", onLeave)
		gui:SetScript("OnShow", onShow)

		self.gui = gui
	end
	return self.gui
end

GUI.OpenGUI = function(self)
	local gui = self:GetGUI()
	if (not gui) then
		return
	end
	gui:Show()
end

GUI.CloseGUI = function(self)
	local gui = self:GetGUI()
	if (not gui) then
		return
	end
	gui:Hide()
end

GUI.ToggleGUI = function(self)
	local gui = self:GetGUI()
	if (not gui) then
		return
	end
	gui:SetShown((not gui:IsShown()))
end

GUI.RegisterModule = function(self, module, title, description)
	local card = { module = module, title = title, description = description }
	if (not self.cards) then
		self.cards = {}
	end
	table_insert(self.cards, card)
	table_sort(self.cards, SortByName)

	if (not self.cardsByModule) then
		self.cardsByModule = {}
	end
	self.cardsByModule[module] = card
end

GUI.OnInit = function(self)
	if (Private.Version ~= "Development2") then
		return
	end
	self:RegisterChatCommand("cc", "ToggleGUI")
end

GUI.OnEnable = function(self)
end

GUI.OnDisable = function(self)
end
