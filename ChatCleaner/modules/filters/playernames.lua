local Addon, Private = ...
local Core = Private:GetModule("Core")
if (not Core) then
	return
end
local Module = Core:NewModule("Names")

Module.OnInit = function(self)
end

Module.OnEnable = function(self)
end

-- Player names
--Private:RegisterReplacement("Players", "|Hplayer:(.-)-(.-):(.-)|h%[|c(%w%w%w%w%w%w%w%w)(.-)-(.-)|r%]|h", "|Hplayer:%1-%2:%3|h|c%4%5|r|h")
--Private:RegisterReplacement("Players", "|Hplayer:(.-)-(.-):(.-)|h|c(%w%w%w%w%w%w%w%w)(.-)-(.-)|r|h", "|Hplayer:%1-%2:%3|h|c%4%5|r|h")
--Private:RegisterReplacement("Players", "|Hplayer:(.-)|h%[(.-)%]|h", "|Hplayer:%1|h%2|h")
--Private:RegisterReplacement("Players", "|HBNplayer:(.-)|h%[(.-)%]|h", "|HBNplayer:%1|h%2|h")
