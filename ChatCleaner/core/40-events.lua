local Addon, Private = ...

-- Lua API
local next = next
local setmetatable = setmetatable
local table_insert = table.insert
local table_remove = table.remove
local type = type

-- Private API
local frame = Private.Frame
local frame_index = Private.Frame_MT.__index
local module_template = Private.Module
local xpcall = Private.API.xpcall

-- Frame Methods
local registerEvent = frame_index.RegisterEvent
local registerUnitEvent = frame_index.RegisterUnitEvent
local unregisterEvent = frame_index.UnregisterEvent
local isEventRegistered = frame_index.IsEventRegistered

-- Fire the events for a single module.
-- This is a table mimicking a function, 
-- and will be called by the metatable below.
-- events[event][module](event, ...)
local event_mt = {
	__call = function(funcs, module, event, ...)
		for _,func in next,funcs do
			if (type(func) == "string") then
				module[func](module, event, ...)
			else
				func(module, event, ...)
			end
		end
	end
}

-- Fire an event to all registered modules.
-- events[event](...)
local events_mt = {
	__call = function(modules, event, ...)
		for module,funcs in next,modules do
			 -- funcs can be a function, a method name, or a table of those.
			if (type(funcs) == "string") then
				module[funcs](module, event, ...)
			else
				funcs(module, event, ...)
			end
		end
	end
}

-- Event registry.
-- events[event][module] = { func, func, ... }
local events = setmetatable({}, { 
	__index = function(t,k)
		local new = setmetatable({}, events_mt)
		rawset(t,k,new)
		return new
	end
})

-- Invoke the __call metamethod of the event registry, 
-- which in turn iterates all modules and fires its methods.
local onEvent = function(_, event, ...)
	return events[event](event, ...)
end

local validator = CreateFrame("Frame")
local validateEvent = function(event)
	local isOK = xpcall(validator.RegisterEvent, validator, event)
	if (isOK) then
		validator:UnregisterEvent(event)
	end
	return isOK
end

-- Module Template API
--------------------------------------------------
module_template.RegisterEvent = function(self, event, callback)
	-- If the callback is a method, transform it into a function.
	--if (type(callback) == "string") then
	--	local method = callback
	--	callback = function(self, ...) self[method](self,...) end
	--end
	local curev = events[event][self]
	if (curev) then
		local kind = type(curev)
		if ((kind == "function") and (curev ~= callback)) then
			events[event][self] = setmetatable({ curev, callback }, event_mt)

		elseif (kind == "table") then
			for _, infunc in next, curev do
				if (infunc == callback) then 
					return 
				end
			end
			table_insert(curev, callback)
		end
		registerEvent(frame, event)

	elseif (validateEvent(event)) then
		events[event][self] = callback

		if (not frame:GetScript("OnEvent")) then
			frame:SetScript("OnEvent", onEvent)
		end
		registerEvent(frame, event)

	end
end

module_template.UnregisterEvent = function(self, event, callback)
	local cleanUp = false
	local curev = events[event][self]

	-- Retrieve the actual function if listed as a method.
	--if (type(callback) == "string") then
	--	callback = self[callback]
	--end

	-- We have multiple event registrations on the module,
	-- so iterate them all and remove only the current.
	if ((type(curev) == "table") and (callback)) then
		for k,infunc in next,curev do
			if (infunc == callback) then
				curev[k] = nil
				break
			end
		end
		-- This module has no more entries for this event, 
		-- so schedule a cleanup down below to see if
		-- the event listener is still needed.
		if (not next(curev)) then
			cleanUp = true
		end
	end

	if ((cleanUp) or (curev == callback)) then
		-- Clear the event entry for this module.
		events[event][self] = nil 
		-- Kill the event listener if no more modules
		-- has registered for it. 
		if (not next(events[event])) then
			unregisterEvent(frame, event) 
		end
	end
end

module_template.RegisterMessage = function(self, message, callback)
end

module_template.UnregisterMessage = function(self, message, callback)
end

module_template.SendMessage = function(self, message, ...)
end
