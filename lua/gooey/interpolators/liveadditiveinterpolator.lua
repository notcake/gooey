local self = {}
Gooey.LiveAdditiveInterpolator = Gooey.MakeConstructor (self, Gooey.TimeInterpolator)

--[[
	Events:
		InterpolationCompleted ()
			Fired when the interpolation has completed.
]]

function self:ctor ()
	self.TickController = nil
	
	self.Offset = 0
	self.FinalValue = 0
	self.Interpolators = {}
	self.InterpolatorStartTimes = {}
	
	self.TargetValue = 0
	
	Gooey.EventProvider (self)
end

function self:dtor ()
	self:SetTickController (nil)
end

function self:AddInterpolator (timeInterpolator, startTime)
	startTime = startTime or SysTime ()
	
	self.Interpolators [#self.Interpolators + 1] = timeInterpolator
	self.InterpolatorStartTimes [#self.InterpolatorStartTimes + 1] = startTime
	self.FinalValue = self.FinalValue + timeInterpolator:GetFinalValue ()
end

function self:GetDuration ()
	return math.huge
end

function self:GetFinalValue ()
	return self.FinalValue
end

function self:GetInitialValue ()
	return self.Offset
end

function self:GetOffset ()
	return self.Offset
end

function self:GetValue (t)
	t = t or SysTime ()
	
	local value = self.Offset
	if #self.Interpolators == 0 then return value end
	
	for i = #self.Interpolators, 1, -1 do
		local relativeTime = t - self.InterpolatorStartTimes [i]
		value = value + self.Interpolators [i]:GetValue (relativeTime)
		
		if relativeTime > self.Interpolators [i]:GetDuration () then
			self.Offset = self.Offset + self.Interpolators [i]:GetFinalValue ()
			table.remove (self.Interpolators, i)
			table.remove (self.InterpolatorStartTimes, i)
		end
	end
	
	if #self.Interpolators == 0 then
		self:DispatchEvent ("InterpolationCompleted")
	end
	
	return value
end

function self:SetOffset (offset)
	if self.Offset == offset then return end
	
	self.FinalValue = self.FinalValue + offset - self.Offset
	self.Offset = offset
end

function self:SetTickController (tickController)
	if self.TickController == tickController then return end
	
	self:UnhookTickController (self.TickController)
	self.TickController = tickController
	self:HookTickController (self.TickController)
end

function self:SetValue (value, t)
	self:SetOffset (self:GetOffset () + value - self:GetValue (t))
end

function self:Tick ()
	self:GetValue (SysTime ())
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