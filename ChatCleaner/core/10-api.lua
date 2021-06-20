local Addon, Private = ...

-- Lua API
local _G = _G
local real_print = print
local real_xpcall = xpcall
local setmetatable = setmetatable
local table_insert = table.insert
local unpack = unpack

local split = function(str, sep)
	if (not str) or (str == "") then 
		return str
	end
	local result = setmetatable({}, {__mode="kv"})
	local regex = ("([^%s]+)"):format(sep)
	for each in str:gmatch(regex) do
		table_insert(result, each)
	end
	return unpack(result)
end

local print = function(...) 
	real_print("|cff4488ff"..Addon..":|r ", ...) 
end

local error = function(...) 
	local message, level = ...
	if (not message) then
		return
	end
	print("|cffff0000"..message.."|r") 
end

local xpcall = function(func, ...) 
	return real_xpcall(func, error, ...) 
end

Private.API.print = print
Private.API.split = split
Private.API.error = error
Private.API.xpcall = xpcall
