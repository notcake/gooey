local self = {}
Gooey.ActionMap = Gooey.MakeConstructor (self)

function self:ctor ()
	self.ChainedActionMap = nil
	
	self.Target = nil
	self.Actions = {}
end

function self:CanRunAction (actionName, ...)
	local action, target = self:GetAction (actionName)
	if not action then return false end
	
	return action:CanRun (target, ...)
end

function self:Execute (actionName, ...)
	local action, target = self:GetAction (actionName)
	if not action then return false end
	if not action:CanRun (target, ...) then return false end
	
	action:Execute (target, ...)
	return true
end

function self:GetAction (actionName)
	if self.ChainedActionMap then
		local action, target = self.ChainedActionMap:GetAction (actionName)
		if action then return action, target end
	end
	
	return self.Actions [actionName], self.Target
end

function self:GetChainedActionMap ()
	return self.ChainedActionMap
end

function self:GetTarget ()
	return self.Target
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

function self:SetTarget (target)
	self.Target = target
end