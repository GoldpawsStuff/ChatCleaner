local Addon, ns = ...

local Module = ns:NewModule("Names")

local replacements = {
	{"|Hplayer:(.-)-(.-):(.-)|h%[|c(%w%w%w%w%w%w%w%w)(.-)-(.-)|r%]|h", "|Hplayer:%1-%2:%3|h|c%4%5|r|h"},
	{"|Hplayer:(.-)-(.-):(.-)|h|c(%w%w%w%w%w%w%w%w)(.-)-(.-)|r|h", "|Hplayer:%1-%2:%3|h|c%4%5|r|h"},
	{"|Hplayer:(.-)|h%[(.-)%]|h", "|Hplayer:%1|h%2|h"},
	{"|HBNplayer:(.-)|h%[(.-)%]|h", "|HBNplayer:%1|h%2|h"}
}

Module.OnEnable = function(self)
	self.filterEnabled = true
	ns:AddReplacementSet(replacements, true)
end

Module.OnDisable = function(self)
	self.filterEnabled = nil
	ns:RemoveReplacementSet(replacements)
end
