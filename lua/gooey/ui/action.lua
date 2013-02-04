local self = {}
Gooey.Action = Gooey.MakeConstructor (self)

--[[
	Events:
		EnabledChanged (enabled)
			Fired when this action has been enabled or disabled.
]]

function self:ctor (name)
	self.Name        = name
	self.DisplayName = name
	
	self.Enabled = true
	
	self.CanRunFunction = nil
	self.Handler = Gooey.NullCallback
	
	Gooey.EventProvider (self)
end

function self:CanRun (control, ...)
	if not self:IsEnabled () then return false end
	
	if self.CanRunFunction and not self.CanRunFunction (control, ...) then
		return false
	end
	return true
end

function self:Execute (control, ...)
	if not self:CanRun (control, ...) then return end
	
	self.Handler (control, ...)
end

function self:GetDisplayName ()
	return self.DisplayName
end

function self:GetName ()
	return self.Name
end

function self:IsEnabled ()
	return self.Enabled
end

function self:SetCanRunFunction (canRunFunction)
	self.CanRunFunction = canRunFunction
end

function self:SetDisplayName (displayName)
	self.DisplayName = displayName
end

function self:SetEnabled (enabled)
	if self.Enabled == enabled then return end
	
	self.Enabled = enabled
	
	self:DispatchEvent ("EnabledChanged", self.Enabled)
	
	return self
end

function self:SetHandler (handler)
	handler = handler or Gooey.NullCallback
	self.Handler = handler
end