local self = {}
Gooey.LerpController = Gooey.MakeConstructor (self)

--[[
	Events:
		LerpCompleted ()
			Fired when the lerp has completed.
]]

function self:ctor ()
	self.TickController = nil
	
	self.Value = 0
	self.TargetValue = 0
	
	self.Rate = 100
	self.LastTickTime = SysTime ()
	
	Gooey.EventProvider (self)
end

function self:dtor ()
	self:SetTickController (nil)
end

function self:GetTargetValue ()
	return self.TargetValue
end

function self:GetValue ()
	local deltaTime = SysTime () - self.LastTickTime
	self.LastTickTime = SysTime ()
	
	if self.TargetValue == self.Value then
		return self.Value
	end
	
	local deltaValue
	if self.TargetValue > self.Value then
		deltaValue = self.Rate * deltaTime
	else
		deltaValue = -self.Rate * deltaTime
	end
	if math.abs (deltaValue) > math.abs (self.TargetValue - self.Value) then
		self.Value = self.TargetValue
		self:DispatchEvent ("FadeCompleted")
	else
		self.Value = self.Value + deltaValue
	end
	
	return self.Value
end

function self:SetRate (rate)
	if self.Rate == rate then return end
	if rate < 0 then rate = -rate end
	
	self.Rate = rate
end

function self:SetTargetValue (targetValue)
	if not targetValue then
		Gooey.Error ("LerpController:SetTargetValue : targetValue is nil!")
	end
	self.TargetValue = targetValue
end

function self:SetTickController (tickController)
	if self.TickController == tickController then return end
	
	self:UnhookTickController (self.TickController)
	self.TickController = tickController
	self:HookTickController (self.TickController)
end

function self:SetValue (value)
	if not value then
		Gooey.Error ("LerpController:SetValue : value is nil!")
	end
	self.Value = value
end

function self:Tick ()
	self:GetValue ()
end

-- Internal, do not call
function self:HookTickController (tickController)
	if not tickController then return end
	
	tickController:AddEventListener ("Tick", tostring (self),
		function ()
			self:Tick ()
		end
	)
end

function self:UnhookTickController (tickController)
	if not tickController then return end
	
	tickController:RemoveEventListener ("Tick", tostring (self))
end