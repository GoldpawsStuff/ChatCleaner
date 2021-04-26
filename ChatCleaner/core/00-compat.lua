local Addon, Private = ...

-- Backdrop template for Lua and XML
-- Allows us to always set these templates, even in Classic.
local MixinGlobal = Addon.."BackdropTemplateMixin"
_G[MixinGlobal] = {}
if (BackdropTemplateMixin) then
	_G[MixinGlobal] = CreateFromMixins(BackdropTemplateMixin) -- Usable in XML
	Private.BackdropTemplate = "BackdropTemplate" -- Usable in Lua
end
