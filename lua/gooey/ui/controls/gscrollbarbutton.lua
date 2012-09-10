local PANEL = {}

function PANEL:Init ()
	self.ScrollBar = nil
	self.ScrollIncrement = 1
	
	self.Direction = "Up"
	
	self:SetText ("")
	
	self.NextIncrementTime = 0
	self.FirstIncrementInterval = 0.5
	self.IncrementInterval = 0.050
	
	self:AddEventListener ("MouseDown",
		function (_, mouseCode)
			if mouseCode == MOUSE_LEFT then
				if self.ScrollBar then
					self.ScrollBar:Scroll (self:GetScrollIncrement ())
					self.NextIncrementTime = SysTime () + self.FirstIncrementInterval
				end
			end
		end
	)
end

function PANEL:GetDirection ()
	return self.Direction or "Up"
end

function PANEL:GetScrollBar ()
	return self.ScrollBar
end

function PANEL:GetScrollIncrement ()
	return self.ScrollIncrement
end

function PANEL:Paint (w, h)
	if VERSION < 150 then
		local w, h = self:GetSize ()
		derma.SkinHook ("Paint", "Button", self, w, h)
		
		local character = ""
		local color = GLib.Colors.White
		if not self:IsEnabled () then
			color = GLib.Colors.Gray
		end
		if self.Direction == "Up" then character = "5"
		elseif self.Direction == "Down" then character = "6"
		elseif self.Direction == "Left" then character = "3"
		elseif self.Direction == "Right" then character = "4" end
		draw.SimpleText (character, "Marlett", self:GetWide () * 0.5, self:GetTall () * 0.5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		derma.SkinHook ("Paint", "Button" .. self:GetDirection (), self, w, h)
	end
end

function PANEL:SetDirection (direction)
	self.Direction = direction or "Up"
end

function PANEL:SetScrollBar (scrollBar)
	self.ScrollBar = scrollBar
end

function PANEL:SetScrollIncrement (increment)
	self.ScrollIncrement = increment or 1
end

function PANEL:Think ()
	if self:IsPressed () then
		if SysTime () >= self.NextIncrementTime then
			if self.ScrollBar then
				self.ScrollBar:Scroll (self:GetScrollIncrement ())
				self.NextIncrementTime = SysTime () + self.IncrementInterval
			end
		end
	end
end

Gooey.Register ("GScrollBarButton", PANEL, "GButton")