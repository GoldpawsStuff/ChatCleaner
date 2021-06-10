local Addon, Private = ...

-- Lua API
local error = Private.API.error
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable

-- WoW API
local IsLoggedIn = IsLoggedIn

-- Private
local modules = Private.Modules
local module_template = Private.Module
local module_template_mt = Private.Module_MT
local initializedModules = Private.InitializedModules
local enabledModules = Private.EnabledModules
local userDisabledModules = Private.UserDisabledModules

-- Module name registry
local Name = { [Private] = Addon }
setmetatable(Name, { __call = function(t,k) return rawget(Name,k) end })

-- Module parent registry
local Parent = {}
setmetatable(Parent, { __call = function(t,k) return rawget(Parent,k) end })

-- Submodule list metatable
-- usage: subModuleList(subModuleName)
-- format: subModuleList = { [subModuleName] = subModule, ... }
local subModuleList_mt = { 
	__call = function(subModuleList,subModuleName)
		return rawget(subModuleList,subModuleName)
	end
} 

-- Module list metatable
-- format: moduleList[moduleObject] = subModuleList
local moduleList_mt = { 
	__index = function(moduleList,moduleObject) 
		local subModuleList = setmetatable({}, subModuleList_mt)
		rawset(moduleList,moduleObject,subModuleList)
		return subModuleList
	end 
}
setmetatable(modules, moduleList_mt)

-- Module Template API
-----------------------------------------------------------------
module_template.NewModule = function(self, name)
	return Private.NewModule(self, name)
end

module_template.GetModule = function(self, name) 
	return Private.GetModule(self, name) 
end

module_template.SetUserDisabled = function(self, disable)
	if (disable) then
		userDisabledModules[self] = true
	else
		userDisabledModules[self] = nil
	end
end

module_template.IsUserDisabled = function(self)
	return userDisabledModules[self]
end

module_template.IsEnabled = function(self)
	return enabledModules[self]
end

module_template.IsInitialized = function(self)
	return initializedModules[self]
end

module_template.Init = function(self, ...)
	if (self:IsUserDisabled()) then
		return
	end
	if (not initializedModules[self]) then 
		initializedModules[self] = true
		if (self.OnInit) then
			self:OnInit(...)
		end
		for name,subModule in next,modules[self] do
			subModule:Init(...)
		end
	end
end

module_template.Enable = function(self)
	if (self:IsUserDisabled()) then
		return
	end
	if (not enabledModules[self]) then 
		if (not initializedModules[self]) then 
			self:Init("Forced")
			if (self:IsUserDisabled()) then
				return
			end
		end
		enabledModules[self] = true
		if (self.OnEnable) then
			self:OnEnable()
		end
		for name,subModule in next,modules[self] do
			subModule:Enable()
		end
	end
end

module_template.Disable = function(self)
	if (enabledModules[self]) then 
		enabledModules[self] = false
		if (self.OnDisable) then
			self:OnDisable()
		end
		for name,subModule in next,modules[self] do
			subModule:Disable()
		end
	end
end

module_template.GetName = Name 
module_template.GetParent = Parent 
module_template_mt.__call = module_template.GetModule
module_template_mt.__tostring = module_template.GetName

-- Private API
-----------------------------------------------------------------
Private.NewModule = function(self, name)
	if (modules[self][name]) then
		return error(("The submodule named '%s' already exists in '%s'"):format(name, self:GetName()))
	end
	local module = setmetatable({}, module_template_mt)
	modules[self][name] = module
	Name[module] = name
	Parent[module] = self
	return module
end

Private.GetModule = function(self, name) return modules[self][name] end
Private.GetName = Name 
Private.GetParent = Parent 

setmetatable(Private, { __call = Private.GetModule })

module_template.RegisterEvent({ OnEvent = function(self, event, ...) 
	if (event == "ADDON_LOADED") then
		-- Nothing happens before this has fired for your addon.
		-- When it fires, we remove the event listener 
		-- and call our initialization method.
		if ((...) == Addon) then
			-- Delete our initial registration of this event.
			-- Note that you are free to re-register it in any of the 
			-- addon namespace methods. 
			module_template.UnregisterEvent(self, "ADDON_LOADED", "OnEvent")
			-- Initialize all the top level modules.
			for name,subModule in next,modules[Private] do
				if (subModule.Init) then
					subModule:Init()
				end
			end
			-- If this was a load-on-demand addon, 
			-- then we might be logged in already.
			-- If that is the case, directly run 
			-- the enabling method.
			if (IsLoggedIn()) then
				for name,subModule in next,modules[Private] do
					if (subModule.Enable) then
						subModule:Enable()
					end
				end
			else
				-- If this is a regular always-load addon, 
				-- we're not yet logged in, and must listen for this.
				module_template.RegisterEvent(self, "PLAYER_LOGIN", "OnEvent")
			end
			-- Return. We do not wish to forward the loading event 
			-- for our own addon to the namespace event handler.
			-- That is what the initialization method exists for.
			return
		end
	elseif (event == "PLAYER_LOGIN") then
		-- This event only ever fires once on a reload, 
		-- and anything you wish done at this event, 
		-- should be put in the namespace enable method.
		module_template.UnregisterEvent(self, "PLAYER_LOGIN", "OnEvent")
		-- Call the enabling method.
		for name,subModule in next,modules[Private] do
			if (subModule.Enable) then
				subModule:Enable()
			end
		end
	end
end }, "ADDON_LOADED", "OnEvent")
