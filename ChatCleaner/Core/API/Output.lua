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
local _, ns = ...

-- Lua API
local _G = _G
local ipairs = ipairs
local rawset = rawset
local setmetatable = setmetatable
local string_gsub = string.gsub
local unpack = unpack

-- WoW Global Strings
local AUCTION_SOLD_MAIL = _G.AUCTION_SOLD_MAIL_SUBJECT -- "Auction successful: %s"
local AUCTION_CREATED = string_gsub(_G.ERR_AUCTION_STARTED, "%.", "") -- "Auction created."
local AUCTION_REMOVED = string_gsub(_G.ERR_AUCTION_REMOVED, "%.", "") -- "Auction cancelled."
local AWAY = _G.FRIENDS_LIST_AWAY -- "Away"
local BUSY = _G.FRIENDS_LIST_BUSY -- "Busy"
local COMPLETE = _G.COMPLETE -- "Complete"
local RESTED = _G.TUTORIAL_TITLE26 -- "Rested"

-- Private API
local Colors = ns.Private.Colors

-- Output patterns.
-- *uses a simple color tag system for new strings.
ns.out = setmetatable(ns.out or {}, { __newindex = function(t,k,msg)

	local colors = Colors or ns.Colors

	-- Have to do this with an indexed table,
	-- as the order of the entires matters.
	for _,entry in ipairs({
		{ "%*title%*", 		colors.title.colorCode },
		{ "%*white%*", 		colors.highlight.colorCode },
		{ "%*offwhite%*", 	colors.offwhite.colorCode },
		{ "%*palered%*", 	colors.palered.colorCode },
		{ "%*red%*", 		colors.quest.red.colorCode },
		{ "%*darkorange%*", colors.quality.Legendary.colorCode },
		{ "%*orange%*", 	colors.quest.orange.colorCode },
		{ "%*yellow%*", 	colors.quest.yellow.colorCode },
		{ "%*green%*", 		colors.quest.green.colorCode },
		{ "%*gray%*", 		colors.quest.gray.colorCode },
		{ "%*%*", "|r" } -- Always keep this at the end.
	}) do
		msg = string_gsub(msg, unpack(entry))
	end
	rawset(t,k,msg)
end })

local out = ns.out

-- Local templates
local plus = "*gray*+** %s"
local plus_yellow = "*gray*+** *white*%s:** *yellow*%s**"

-- Output formats used in the modules.
-- *everything should be gathered here, in this file.
out.achievement = "*offwhite*!**%s: %s"
out.achievement2 = "*offwhite*!***green*%s:** *white*%s**"
out.afk_added = "*orange*+ "..AWAY.."**"
out.afk_added_message = "*orange*+ "..AWAY..": ***white*%s**"
out.afk_cleared = "*green*- "..AWAY.."**"
out.auction_sold = "*offwhite*!***green*"..string_gsub(AUCTION_SOLD_MAIL, "%%s", "*white*%%s**").."**"
out.auction_single = "*gray*+** *white*"..AUCTION_CREATED.."**"
out.auction_multiple = "*gray*+** *white*"..AUCTION_CREATED.."** *offwhite*(%d)**"
out.auction_canceled_single = "*palered*- "..AUCTION_REMOVED.."**"
out.auction_canceled_multiple = "*palered*- "..AUCTION_REMOVED.."** *offwhite*(%d)**"
out.currency = "*gray*+** *white*%d** %s"
out.dnd_added = "*darkorange*+ "..BUSY.."**"
out.dnd_added_message = "*darkorange*+ "..BUSY..": ***white*%s**"
out.dnd_cleared = "*green*- "..BUSY.."**"
out.item_single = plus
out.item_multiple = "*gray*+** %s *offwhite*(%d)**"
out.item_single_other = "*offwhite*!**%s*gray*:** %s"
out.item_multiple_other = "*offwhite*!**%s*gray*:** %s *offwhite*(%d)**"
out.item_deficit = "*red*- %s**"
out.item_deficit_multiple = "*red*- %s** *offwhite*(%d)**"
out.item_transfer = "*gray*+** *white*%s:** %s"
out.money = plus
out.money_deficit = "*gray*-** %s"
out.objective_status = plus_yellow
out.quest_accepted = plus_yellow
out.quest_complete = plus_yellow
out.rested_added = "*gray*+ "..RESTED.."**"
out.rested_cleared = "*orange*- "..RESTED.."**"
out.set_complete = plus_yellow
out.standing = "*gray*+** *white*".."%d** *white*%s:** %s"
out.standing_generic = "*gray*+ %s:** %s"
out.standing_deficit = "*red*-** *white*".."%d** *white*%s:** %s"
out.standing_deficit_generic = "*red*-** *palered** %s:** %s"
out.xp_levelup = "*offwhite*!**%s*white*!**"
out.xp_named = "*gray*+** *white*%d** *white*%s:** *yellow*%s**"
out.xp_unnamed = "*gray*+** *white*%d** *white*%s**"
