local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Names")

-- Lua API
local table_insert = table.insert

Module.OnInit = function(self)
	self.db = self:GetParent():GetSavedSettings()
	self.replacements = {}
	table_insert(self.replacements, {"|Hplayer:(.-)-(.-):(.-)|h%[|c(%w%w%w%w%w%w%w%w)(.-)-(.-)|r%]|h", "|Hplayer:%1-%2:%3|h|c%4%5|r|h"})
	table_insert(self.replacements, {"|Hplayer:(.-)-(.-):(.-)|h|c(%w%w%w%w%w%w%w%w)(.-)-(.-)|r|h", "|Hplayer:%1-%2:%3|h|c%4%5|r|h"})
	table_insert(self.replacements, {"|Hplayer:(.-)|h%[(.-)%]|h", "|Hplayer:%1|h%2|h"})
	table_insert(self.replacements, {"|HBNplayer:(.-)|h%[(.-)%]|h", "|HBNplayer:%1|h%2|h"})
	if (self.db["DisableFilter:"..self:GetName()]) then
		return self:SetUserDisabled()
	end
end

Module.OnEnable = function(self)
	self.filterEnabled = true
	self:GetParent():AddReplacementSet(self.replacements)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	self:GetParent():RemoveReplacementSet(self.replacements)
end
