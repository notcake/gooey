local PANEL = {}

function PANEL:Init ()
	self.Text = ""
end

function PANEL:GetKeyboardMap ()
	return self.KeyboardMap
end

function PANEL:GetText ()
	return self.Text or ""
end

function PANEL:Paint ()
	draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), self:GetBackgroundColor ())
end

function PANEL:SetKeyboardMap (keyboardMap)
	self.KeyboardMap = keyboardMap
end

function PANEL:SetText (text)
	self.Text = text or ""
end

-- Event handlers
function PANEL:OnCursorEntered ()
	self:DispatchEvent ("MouseEnter")
	if self.OnMouseEnter then self:OnMouseEnter () end
end

function PANEL:OnCursorMoved (x, y)
	self:DispatchEvent ("MouseMove", 0, x, y)
	if self.OnMouseMove then self:OnMouseMove (0, self:CursorPos ()) end
end

function PANEL:OnCursorExited ()
	self:DispatchEvent ("MouseLeave")
	if self.OnMouseLeave then self:OnMouseLeave () end
end

function PANEL:OnKeyCodePressed (keyCode)
	local ctrl    = input.IsKeyDown (KEY_LCONTROL) or input.IsKeyDown (KEY_RCONTROL)
	local shift   = input.IsKeyDown (KEY_LSHIFT)   or input.IsKeyDown (KEY_RSHIFT)
	local alt     = input.IsKeyDown (KEY_LALT)     or input.IsKeyDown (KEY_RALT)
	
	local keyboardMap = self:GetKeyboardMap ()
	if keyboardMap then
		keyboardMap:Execute (self, keyCode, ctrl, shift, alt)
	end
end
PANEL.OnKeyCodeTyped = PANEL.OnKeyCodePressed

function PANEL:OnMousePressed (mouseCode)
	self:DispatchEvent ("MouseDown", mouseCode, self:CursorPos ())
	if self.OnMouseDown then self:OnMouseDown (mouseCode, self:CursorPos ()) end
end

function PANEL:OnMouseReleased (mouseCode)
	self:DispatchEvent ("MouseUp", mouseCode, self:CursorPos ())
	if self.OnMouseUp then self:OnMouseUp (mouseCode, self:CursorPos ()) end
	
	if mouseCode == MOUSE_LEFT then
		self:DispatchEvent ("Click")
	elseif mouseCode == MOUSE_RIGHT then
		self:DispatchEvent ("RightClick")
	end
end

function PANEL:OnMouseWheeled (delta)
	self:DispatchEvent ("MouseWheel", delta)
	if self.OnMouseWheel then self:OnMouseWheel (delta) end
end

Gooey.Register ("GPanel", PANEL, "DPanel")