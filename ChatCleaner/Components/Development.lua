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

-- Only run this module on GitHub repo downloads or my own local version.
if (ns.Version ~= "Development") then
	return
end

local Module = ns:NewModule("DevelopmentFilters")

-- Lua API
local string_find = string.find

Module.OnAddMessage = function(self, chatFrame, msg, r, g, b, chatID, ...)

	-- Kill off MaxDps ace console status messages.
	-- Definitely not recommended for the general user.
	if (string_find(msg, "|cff33ff99MaxDps|r%:")) then
		return true
	end
end

Module.OnChatEvent = function(self, chatFrame, event, message, author, ...)
end

Module.OnInitialize = function(self)
	self.OnChatEventProxy = function(...) return self:OnChatEvent(...) end
	self.OnAddMessageProxy = function(...) return self:OnAddMessage(...) end
end

Module.OnEnable = function(self)
	self.filterEnabled = true

	ns:AddBlacklistMethod(self.OnAddMessageProxy)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil

	ns:RemoveBlacklistMethod(self.OnAddMessageProxy)
end
