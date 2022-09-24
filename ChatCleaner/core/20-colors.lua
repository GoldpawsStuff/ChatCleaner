local Addon, Private = ...
local Colors = Private.Colors

-- Import
local math_floor = math.floor
local string_format = string.format

-- Define Local Tables
local ColorTemplate = {}

-- Utility
-----------------------------------------------------------------
-- Convert a Blizzard Color or RGB value set
-- into our own custom color table format.
local createColor = function(...)
	local tbl
	if (select("#", ...) == 1) then
		local old = ...
		if (old.r) then
			tbl = {}
			tbl[1] = old.r or 1
			tbl[2] = old.g or 1
			tbl[3] = old.b or 1
		else
			tbl = { unpack(old) }
		end
	else
		tbl = { ... }
	end
	-- Do NOT use a metatable, just embed.
	for name,method in pairs(ColorTemplate) do
		tbl[name] = method
	end
	if (#tbl == 3) then
		tbl.colorCode = tbl:GenerateHexColorMarkup()
		tbl.colorCodeClean = tbl:GenerateHexColor()
	end
	return tbl
end

-- Convert a whole Blizzard color table
local createColorGroup = function(group)
	local tbl = {}
	for i,v in pairs(group) do
		tbl[i] = createColor(v)
	end
	return tbl
end

-- Assign proxies to the color table, for modules to use
Colors.CreateColor = function(_, ...) return createColor(...) end
Colors.CreateColorGroup = function(_, ...) return createColorGroup(...) end

-- Color Template
-----------------------------------------------------------------
-- Emulate some of the Blizzard methods,
-- since they too do colors this way now.
-- Goal is not to be fully interchangeable.
ColorTemplate.GetRGB = function(self)
	return self[1], self[2], self[3]
end

ColorTemplate.GetRGBAsBytes = function(self)
	return self[1]*255, self[2]*255, self[3]*255
end

ColorTemplate.GenerateHexColor = function(self)
	return string_format("ff%02x%02x%02x", math_floor(self[1]*255), math_floor(self[2]*255), math_floor(self[3]*255))
end

ColorTemplate.GenerateHexColorMarkup = function(self)
	return "|c" .. self:GenerateHexColor()
end

-- Color Table
-----------------------------------------------------------------
Colors.normal = createColor(229/255, 178/255, 38/255)
Colors.highlight = createColor(250/255, 250/255, 250/255)
Colors.title = createColor(255/255, 234/255, 137/255)
Colors.white = createColor(220/255, 220/255, 220/255)
Colors.offwhite = createColor(196/255, 196/255, 196/255)
Colors.green = createColor(25/255, 178/255, 25/255)
Colors.red = createColor(204/255, 25/255, 25/255)
Colors.palered = createColor(204/255, 68/255, 68/255)

-- Item Rarity
Colors.blizzquality = createColorGroup(ITEM_QUALITY_COLORS)
Colors.quality = {}
Colors.quality[0] = createColor(157/255, 157/255, 157/255) -- Poor
Colors.quality[1] = createColor(240/255, 240/255, 240/255) -- Common
Colors.quality[2] = createColor(30/255, 178/255, 0/255) -- Uncommon
Colors.quality[3] = createColor(0/255, 112/255, 221/255) -- Rare
Colors.quality[4] = createColor(163/255, 53/255, 238/255) -- Epic
Colors.quality[5] = createColor(225/255, 96/255, 0/255) -- Legendary
Colors.quality[6] = createColor(230/255, 204/255, 128/255) -- Artifact
Colors.quality[7] = createColor(79/255, 196/255, 225/255) -- Heirloom
Colors.quality[8] = createColor(79/255, 196/255, 225/255) -- Blizard

Colors.quality.Poor = Colors.quality[0]
Colors.quality.Common = Colors.quality[1]
Colors.quality.Uncommon = Colors.quality[2]
Colors.quality.Rare = Colors.quality[3]
Colors.quality.Epic = Colors.quality[4]
Colors.quality.Legendary = Colors.quality[5]
Colors.quality.Artifact = Colors.quality[6]
Colors.quality.Heirloom = Colors.quality[7]
Colors.quality.WoWToken = Colors.quality[8]
Colors.quality.Blizard = Colors.quality[8]

-- Difficulty
Colors.quest = {}
Colors.quest.red = createColor(204/255, 26/255, 26/255)
Colors.quest.orange = createColor(255/255, 106/255, 26/255)
Colors.quest.yellow = createColor(255/255, 178/255, 38/255)
Colors.quest.green = createColor(89/255, 201/255, 89/255)
Colors.quest.gray = createColor(120/255, 120/255, 120/255)

-- Unit Class
-- Original colors at https://wow.gamepedia.com/Class#Class_colors
-- *Note that for classic, SHAMAN and PALADIN are the same.
Colors.blizzclass = createColorGroup(RAID_CLASS_COLORS)
Colors.class = {}
Colors.class.DEATHKNIGHT = createColor(176/255, 31/255, 79/255)
Colors.class.DEMONHUNTER = createColor(163/255, 48/255, 201/255)
Colors.class.DRUID = createColor(225/255, 125/255, 35/255)
Colors.class.EVOKER = createColor(51/255, 147/255, 127/255)
Colors.class.HUNTER = createColor(191/255, 232/255, 115/255)
Colors.class.MAGE = createColor(105/255, 204/255, 240/255)
Colors.class.MONK = createColor(0/255, 255/255, 150/255)
Colors.class.PALADIN = createColor(225/255, 160/255, 226/255)
Colors.class.PRIEST = createColor(176/255, 200/255, 225/255)
Colors.class.ROGUE = createColor(255/255, 225/255, 95/255)
Colors.class.SHAMAN = createColor(32/255, 122/255, 222/255)
Colors.class.WARLOCK = createColor(148/255, 130/255, 201/255)
Colors.class.WARRIOR = createColor(229/255, 156/255, 110/255)
Colors.class.UNKNOWN = createColor(195/255, 202/255, 217/255)

-- Reactions
Colors.reaction = {}
Colors.reaction[1] = createColor(205/255, 46/255, 36/255) -- hated
Colors.reaction[2] = createColor(205/255, 46/255, 36/255) -- hostile
Colors.reaction[3] = createColor(192/255, 68/255, 0/255) -- unfriendly
Colors.reaction[4] = createColor(249/255, 188/255, 65/255) -- neutral
Colors.reaction[5] = createColor( 64/255, 131/255, 38/255) -- friendly
Colors.reaction[6] = createColor( 64/255, 131/255, 69/255) -- honored
Colors.reaction[7] = createColor( 64/255, 131/255, 104/255) -- revered
Colors.reaction[8] = createColor( 64/255, 131/255, 131/255) -- exalted
Colors.reaction.civilian = createColor(64/255, 131/255, 38/255) -- used for friendly player nameplates

-- Friendship
-- Just using these as pointers to the reaction colors,
-- so there won't be a need to ever edit these.
Colors.friendship = {}
Colors.friendship[1] = Colors.reaction[3] -- Stranger
Colors.friendship[2] = Colors.reaction[4] -- Acquaintance
Colors.friendship[3] = Colors.reaction[5] -- Buddy
Colors.friendship[4] = Colors.reaction[6] -- Friend (honored color)
Colors.friendship[5] = Colors.reaction[7] -- Good Friend (revered color)
Colors.friendship[6] = Colors.reaction[8] -- Best Friend (exalted color)
Colors.friendship[7] = Colors.reaction[8] -- Best Friend (exalted color) - brawler's stuff
Colors.friendship[8] = Colors.reaction[8] -- Best Friend (exalted color) - brawler's stuff

Private.Colors = Colors
