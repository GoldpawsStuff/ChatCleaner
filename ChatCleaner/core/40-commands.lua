local Addon, Private = ...

-- Lua API
local split = Private.API.split
local string_gsub = string.gsub
local string_lower = string.lower
local string_upper = string.upper

-- WoW Objects
local SlashCmdList = SlashCmdList

-- This methods lets you register a chat command, and a callback function or private method name.
-- Your callback will be called as callback(Private, editBox, commandName, ...) where (...) are all the input parameters.
local module_template = Private.Module
module_template.RegisterChatCommand = function(self, command, callback)
	command = string_gsub(command, "^/", "") -- Remove any slash at the start.
	command = string_lower(command) -- Make it lowercase, keep it case-insensitive.
	local name = string_upper(Addon.."_CHATCOMMAND_"..command) -- Create a unique uppercase name for the command.
	_G["SLASH_"..name.."1"] = "/"..command -- Register the chat command, keeping it lowercase.
	-- If the callback is a method name, 
	-- create a lookup function that works
	-- even if the function is changed or removed.
	if (type(callback) == "string") then
		local method = callback
		callback = function(self, ...) 
			if (self[method]) then
				self[method](self,...) 
			end
		end
	end
	-- Proxy the global slash command to include the module as 'self'. 
	SlashCmdList[name] = function(msg, editBox)
		callback(self, editBox, command, split(string_lower(msg)))
	end 
end
