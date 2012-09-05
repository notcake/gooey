local PANEL = {}
Gooey.VPanel = Gooey.MakeConstructor (PANEL)

function PANEL:ctor ()
	PANEL.Init (self)
end

function PANEL:Init ()
	self.Id = ""
	
	self.Parent = nil
	self.Children = {}
	
	self.Enabled = true
	self.Visible = true
	
	self.Hovered = false
	self.Pressed = false
	self.ShouldCaptureMouse = false
	self.MouseCaptured = false
	
	-- Positioning
	self.X = 0
	self.Y = 0
	self.Width = 24
	self.Height = 24
	
	self.Text = ""
	
	self.LayoutValid = false
	
	Gooey.EventProvider (self)
	
	self:AddEventListener ("MouseLeave",
		function (_)
			if self:IsPressed () and not self:HasMouseCapture () then
				self:SetPressed (false)
			end
		end
	)
	
	self:AddEventListener ("MouseDown",
		function (_, mouseCode, x, y)
			if mouseCode == MOUSE_LEFT then
				self:SetPressed (true)
				if self.ShouldCaptureMouse then
					self:CaptureMouse (true)
				end
			end
		end
	)
	
	self:AddEventListener ("MouseUp",
		function (_, mouseCode, x, y)
			if mouseCode == MOUSE_LEFT then
				self:SetPressed (false)
				if self:ContainsPoint (x, y) and self:IsEnabled () then
					self:DispatchEvent ("Click")
				end
				if self:HasMouseCapture () then
					self:CaptureMouse (false)
				end
			elseif mouseCode == MOUSE_RIGHT then
				if self:ContainsPoint (x, y) and self:IsEnabled () then
					self:DispatchEvent ("RightClick")
				end
			end
		end
	)
end

function PANEL:CaptureMouse (capture, control)
	control = control or self
	
	if not self:GetParent () then return end
	self:GetParent ():CaptureMouse (capture, control)
	
	self.MouseCaptured = capture
end

function PANEL:ContainsPoint (x, y)
	return x >= 0 and x < self:GetWidth () and
	       y >= 0 and y < self:GetHeight ()
end

function PANEL:GetBottom ()
	return self.Y + self.Height
end

function PANEL:GetHeight ()
	return self.Height
end

function PANEL:GetId ()
	return self.Id
end

function PANEL:GetLeft ()
	return self.X
end

function PANEL:GetParent ()
	return self.Parent
end

function PANEL:GetPos ()
	return self.X, self.Y
end

function PANEL:GetRight ()
	return self.X + self.Width
end

function PANEL:GetText ()
	return self.Text
end

function PANEL:GetTop ()
	return self.Y
end

function PANEL:GetWidth ()
	return self.Width
end

function PANEL:HasMouseCapture ()
	return self.MouseCaptured
end

function PANEL:InvalidateLayout ()
	self.LayoutValid = false
end

function PANEL:IsEnabled ()
	return self.Enabled
end

function PANEL:IsHovered ()
	return self.Hovered
end

function PANEL:IsLayoutValid ()
	return self.LayoutValid
end

function PANEL:IsPressed ()
	return self.Pressed
end

function PANEL:IsVisible ()
	return self.Visible
end

function PANEL:ParentToLocal (x, y)
	return x - self.X, y - self.Y
end

function PANEL:PerformLayout ()
end

function PANEL:SetEnabled (enabled)
	self.Enabled = enabled
	return self
end

function PANEL:SetHeight (height)
	self.Height = height
	return self
end

function PANEL:SetHovered (hovered)
	if self.Hovered == hovered then return end
	self.Hovered = hovered
	
	if self.Hovered then
		self:DispatchEvent ("MouseEnter")
	else
		self:DispatchEvent ("MouseLeave")
	end
	return self
end

function PANEL:SetId (id)
	self.Id = id
	return self
end

function PANEL:SetLeft (x)
	self.X = x
	return self
end

function PANEL:SetParent (parent)
	self.Parent = parent
end

function PANEL:SetPos (x, y)
	self.X = x
	self.Y = y
	return self
end

function PANEL:SetPressed (pressed)
	self.Pressed = pressed
	return self
end

function PANEL:SetShouldCaptureMouse (shouldCaptureMouse)
	self.ShouldCaptureMouse = shouldCaptureMouse
end

function PANEL:SetSize (width, height)
	self.Width = width
	self.Height = height
	return self
end

function PANEL:SetText (text)
	self.Text = text
	return self
end

function PANEL:SetTop (y)
	self.Y = y
	return self
end

function PANEL:SetVisible (visible)
	self.Visible = visible
end

function PANEL:SetWidth (width)
	self.Width = width
	return self
end

function PANEL:ValidateLayout ()
	self.LayoutValid = true
end