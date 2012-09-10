local PANEL = {}

--[[
	GVScrollBar
		
	Events:
		Scroll (viewOffset)
			Fired when the scroll bar has been scrolled.
]]

function PANEL:Init ()
	self.Grip:AddEventListener ("TargetPositionChanged",
		function (_, x, y)
			local scrollFraction = (y - self:GetThickness ()) / self:GetScrollableTrackSize ()
			if scrollFraction < 0 then scrollFraction = 0 end
			if scrollFraction > 1 then scrollFraction = 1 end
			local viewOffset = scrollFraction * (self.ContentSize - self.ViewSize)
			self:SetViewOffset (viewOffset)
		end
	)
	
	self.UpButton = vgui.Create ("GScrollBarButton", self)
	self.UpButton:SetScrollBar (self)
	self.UpButton:SetScrollIncrement (-1)
	self.UpButton:SetDirection ("Up")
	
	self.DownButton = vgui.Create ("GScrollBarButton", self)
	self.DownButton:SetScrollBar (self)
	self.DownButton:SetScrollIncrement (1)
	self.DownButton:SetDirection ("Down")
	
	self:SetSize (16, 256)
	
	self:AddEventListener ("EnabledChanged",
		function (_, enabled)
			self.UpButton:SetEnabled (enabled)
			self.DownButton:SetEnabled (enabled)
		end
	)
	self:AddEventListener ("MouseDown",
		function (_, mouseCode, x, y)
			if mouseCode == MOUSE_LEFT then
				self:ScrollToMouse (y)
				self.NextMouseScrollTime = SysTime () + self.FirstMouseScrollInterval
			end
		end
	)
	self:AddEventListener ("MouseWheel",
		function (_, delta)
			self:Scroll (delta * -2)
		end
	)
	self:AddEventListener ("Scroll",
		function (_, viewOffset)
			if self:GetParent ().OnVScroll then
				self:GetParent ():OnVScroll (viewOffset)
			else
				self:GetParent ():InvalidateLayout ()
			end
		end
	)
end

function PANEL:GetThickness ()
	return self:GetWide ()
end

function PANEL:GetTrackSize ()
	return self:GetTall () - self.UpButton:GetTall () - self.DownButton:GetTall ()
end

function PANEL:Paint (w, h)
	derma.SkinHook ("Paint", "VScrollBar", self, w, h)
	return true
end

function PANEL:PerformLayout ()
	local buttonSize = self:GetThickness ()
	
	self.UpButton:SetPos (0, 0)
	self.UpButton:SetSize (buttonSize, buttonSize)
	
	self.DownButton:SetPos (0, self:GetTall () - buttonSize)
	self.DownButton:SetSize (buttonSize, buttonSize)
	
	self.Grip:SetPos (0, math.floor (self.UpButton:GetTall () + self.ViewOffset / (self.ContentSize - self.ViewSize) * self:GetScrollableTrackSize () + 0.5))
	self.Grip:SetSize (buttonSize, self:GetGripSize ())
end

-- Event handlers
function PANEL:Think ()
	if self:IsPressed () then
		if SysTime () >= self.NextMouseScrollTime then
			local x, y = self:CursorPos ()
			self:ScrollToMouse (y)
		end
	end
end

Gooey.Register ("GVScrollBar", PANEL, "GBaseScrollBar")