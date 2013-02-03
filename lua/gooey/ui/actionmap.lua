local self = {}
Gooey.ActionMap = Gooey.MakeConstructor (self)

function self:ctor ()
	self.ChainedActionMap = nil
	self.Actions = {}
end

function self:CanRunAction (actionName, target, ...)
	local action = self:GetAction (actionName)
	if not action then return false end
	
	return action:CanRun (target, ...)
end

function self:Execute (actionName, target, ...)
	local action = self:GetAction (actionName)
	if not action then return false end
	if not action:CanRun (target, ...) then return false end
	
	action:Execute (target, ...)
	return true
end

function self:GetAction (actionName)
	if self.ChainedActionMap then
		local action = self.ChainedActionMap:GetAction (actionName)
		if action then return action end
	end
	
	return self.Actions [actionName]
end

function self:GetChainedActionMap ()
	return self.ChainedActionMap
end

function self:Register (actionName, handler, canRunFunction)
	local action = Gooey.Action (actionName)
	self.Actions [actionName] = action
	
	action:SetHandler (handler)
	action:SetCanRunFunction (canRunFunction)
	return action
end

function self:SetChainedActionMap (actionMap)
	self.ChainedActionMap = actionMap
end