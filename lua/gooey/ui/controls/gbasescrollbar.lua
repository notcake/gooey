local PANEL = {}

--[[
	GBaseScrollBar
		Code is based on DVScrollBar
		
	Events:
		Scroll (viewOffset)
			Fired when the scroll bar has been scrolled.
]]

function PANEL:Init ()
	self.ContentSize = 1
	
	self.ViewOffset = 0
	self.ViewSize = 1
	
	self.Grip = vgui.Create ("GScrollBarGrip", self)
	
	-- Mouse click scrolling
	self.NextMouseScrollTime = 0
	self.FirstMouseScrollInterval = 0.5
	self.MouseScrollInterval = 0.050
	
	self:SetSize (16, 16)
	
	self:AddEventListener ("EnabledChanged",
		function (_, enabled)
			self.Grip:SetEnabled (enabled)
			self.Grip:SetVisible (enabled)
		end
	)
	self:AddEventListener ("MouseDown",
		function (_, mouseCode, x, y)
			if mouseCode == MOUSE_LEFT then
				self:MouseCapture (true)
			end
		end
	)
	self:AddEventListener ("MouseUp",
		function (_, mouseCode, x, y)
			if mouseCode == MOUSE_LEFT then
				self:MouseCapture (false)
			end
		end
	)
end

function PANEL:GetContentSize ()
	return self.ContentSize
end

function PANEL:GetGripSize ()
	local gripFraction = self.ViewSize / self.ContentSize
	if gripFraction > 1 then gripFraction = 1 end
	local gripSize = gripFraction * self:GetTrackSize ()
	if gripSize < 10 then gripSize = 10 end
	return gripSize
end

function PANEL:GetScrollableTrackSize ()
	return self:GetTrackSize () - self:GetGripSize ()
end

function PANEL:GetThickness ()
	Gooey.Error (self.ClassName .. ":GetThickness : Not implemented.")
end

function PANEL:GetTrackSize ()
	Gooey.Error (self.ClassName .. ":GetTraceSize : Not implemented.")
end

function PANEL:GetViewOffset ()
	return self.ViewOffset
end

function PANEL:GetViewSize ()
	return self.ViewSize
end

function PANEL:Paint (w, h)
	derma.SkinHook ("Paint", "VScrollBar", self, w, h)
	return true
end

function PANEL:PerformLayout ()
end

function PANEL:Scroll (delta)
	if delta == 0 then return end
	
	self:SetViewOffset (self.ViewOffset + delta)
end

function PANEL:SetViewOffset (viewOffset)
	if not self:IsEnabled () then viewOffset = 0 end

	if viewOffset + self.ViewSize > self.ContentSize then
		viewOffset = self.ContentSize - self.ViewSize
	end
	if viewOffset <= 0 then
		viewOffset = 0
	end
	if self.ViewOffset == viewOffset then return end
	
	self.ViewOffset = viewOffset
	
	self:DispatchEvent ("Scroll", self.ViewOffset)
	self:InvalidateLayout ()
end

function PANEL:SetContentSize (contentSize)
	self.ContentSize = contentSize
	self:SetEnabled (self.ViewSize < self.ContentSize)
	if self.ViewOffset + self.ViewSize > self.ContentSize then
		self:SetViewOffset (self.ContentSize - self.ViewSize)
	end
	self:InvalidateLayout ()
end

function PANEL:SetViewSize (viewSize)
	self.ViewSize = viewSize
	self:SetEnabled (self.ViewSize < self.ContentSize)
	if self.ViewOffset + self.ViewSize > self.ContentSize then
		self:SetViewOffset (self.ContentSize - self.ViewSize)
	end
	self:InvalidateLayout ()
end

-- Internal, do not call
function PANEL:ScrollToMouse (mousePos)
	mousePos = mousePos - self:GetThickness ()
	local gripPos = mousePos - self:GetGripSize () * 0.5
	local scrollFraction = gripPos / self:GetScrollableTrackSize ()
	if scrollFraction < 0 then scrollFraction = 0 end
	if scrollFraction > 1 then scrollFraction = 1 end
	local viewOffset = scrollFraction * (self.ContentSize - self.ViewSize)
	local delta = viewOffset - self.ViewOffset
	if delta < -self.ViewSize then delta = -self.ViewSize end
	if delta > self.ViewSize then delta = self.ViewSize end
		
	self:SetViewOffset (self.ViewOffset + delta)
	
	self.NextMouseScrollTime = SysTime () + self.MouseScrollInterval
end

Gooey.Register ("GBaseScrollBar", PANEL, "GPanel")