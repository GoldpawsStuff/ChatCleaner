local Addon, Private = ...

local Update = function(self, chatFrame, event, message, author, ...)
end

local Enable = function(self)
	self.playerMoney = GetMoney()
	--self:RegisterEvent("PLAYER_ENTERING_WORLD", OnEvent)
	--self:RegisterEvent("PLAYER_MONEY", OnEvent)
	--self:AddMessageEventFilter("CHAT_MSG_MONEY", Update)
end

local Disable = function(self)
	--self:RemoveMessageEventFilter("CHAT_MSG_MONEY", Update)
end

Private:RegisterFilter("Money", Enable, Disable, Update)
