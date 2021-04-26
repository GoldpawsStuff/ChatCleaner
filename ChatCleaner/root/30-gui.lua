local Addon, Private = ...

-- Lua API
local pairs = pairs
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
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

-- Addon API
-----------------------------------------------------------
Private.CreateGUI = function(self)
end

Private.OpenGUI = function(self)
end

Private.CloseGUI = function(self)
end
