local Addon, Private = ...

-- Lua API
local table_insert = table.insert

-- WoW API
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local ChatFrame_RemoveMessageEventFilter = ChatFrame_RemoveMessageEventFilter

-- Addon API
-----------------------------------------------------------
Private.GetCallbackWrapper = function(self, callback)
	local wrappers = self.CallbackWrappers
	if (not wrappers) then
		wrappers = {}
		self.CallbackWrappers = wrappers
	end
	if (not wrappers[callback]) then
		local self = self
		wrappers[callback] = function(...)
			return callback(self, ...)
		end 
	end
	return wrappers[callback]
end

Private.AddMessageEventFilter = function(self, chatEvent, callback)
	local events = self.ChatEvents
	if (not events) then
		events = {}
		self.ChatEvents = events
	end
	if (not events[chatEvent]) then
		events[chatEvent] = {}
	end
	table_insert(events[chatEvent], callback)
	ChatFrame_AddMessageEventFilter(chatEvent, self:GetCallbackWrapper(callback))
end

Private.RemoveMessageEventFilter = function(self, chatEvent, callback)
	local events = self.ChatEvents
	if (events) or (not events[chatEvent]) then
		return
	end
	local events = events[chatEvent]
	for k,infunc in next,events do
		if (infunc == callback) then
			events[k] = nil
			break
		end
	end
	if (not next(events)) then
		events[chatEvent] = nil
		ChatFrame_RemoveMessageEventFilter(chatEvent, self:GetCallbackWrapper(callback))
	end
end

-- Register a chat event filter.
Private.RegisterFilter = function(self, uniqueID, enable, disable, update)
	local filter = {
		Enable = enable,
		Disable = disable,
		Update = update
	}
	if (not self.Filters) then
		self.Filters = {}
	end
	self.Filters[uniqueID] = filter
end

-- Register a replacement. 
-- The order of registration decides the order of parsing. 
Private.RegisterReplacement = function(self, groupID, pattern, ...)
	if (not self.Replacements) then
		self.Replacements = {}
	end
	table_insert(self.Replacements, { groupID, pattern, ... })
end

Private.EnableFilter = function(self, id)
	local filter = self.Filters and self.Filters[id]
	if (not filter) then
		return
	end
	if (not self.FilterStatus) then
		self.FilterStatus = {}
	end
	local filterEnabled = self.FilterStatus[id]
	if (not filterEnabled) then
		self.FilterStatus[id] = true
		filter:Enable(self)
	end
end

Private.DisableFilter = function(self, id)
	local filter = self.Filters and self.Filters[id]
	if (not filter) then
		return
	end
	local filterEnabled = self.FilterStatus and self.FilterStatus[id]
	if (filterEnabled) then
		self.FilterStatus[id] = nil
		filter:Disable(self)
	end
end
