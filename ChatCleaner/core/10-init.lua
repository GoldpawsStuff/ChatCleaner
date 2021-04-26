local Addon, Private = ...

-- Lua API
local tonumber = tonumber
local tostring = tostring

-- Addon version
------------------------------------------------------
-- Keyword substitution requires the packager, 
-- and does not affect direct GitHub repo pulls.
local version = "@project-version@"
if (version:find("project%-version")) then
	version = "Development"
end
Private.Version = version

-- WoW client version
------------------------------------------------------
local patch, build = GetBuildInfo()
local major, minor = string.split(".", patch)

-- Store major, minor and build.
Private.ClientMajor = tonumber(major)
Private.ClientMinor = tonumber(minor)
Private.ClientBuild = tonumber(build)

-- Sourced from FrameXML/BNet.lua
if (WOW_PROJECT_ID) then
	Private.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
	Private.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
else
	Private.IsClassic = Private.ClientMajor == 1
	Private.IsRetail = Private.ClientMajor >= 9
end

Private.IsTBC = Private.ClientMajor == 2
Private.IsShadowlands = Private.ClientMajor == 9

-- Addon libraries
------------------------------------------------------
Private.API = {} -- Functions, methods and templates.
Private.Colors = {} -- Color library.
Private.Frame = _G.CreateFrame("Frame") -- Frame for events and updates.
Private.Frame_MT = { __index = _G.CreateFrame("Frame") } -- Frame metatable.
Private.Modules = {} -- Module registry.
Private.Module = {} -- Module template.
Private.Module_MT = { __index = Private.Module } -- Module template metatable.
