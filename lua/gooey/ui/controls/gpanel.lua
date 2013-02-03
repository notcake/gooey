local PANEL = {}

function PANEL:Init ()
	self.LastLeftMouseButtonReleaseTime = 0
end

function PANEL:GetKeyboardMap ()
	return self.KeyboardMap
end

function PANEL:Paint (w, h)
	draw.RoundedBox (4, 0, 0, w, h, self:GetBackgroundColor ())
end

function PANEL:SetKeyboardMap (keyboardMap)
	self.KeyboardMap = keyboardMap
end

-- Event handlers
function PANEL:OnCursorEntered ()
	self.Depressed = input.IsMouseDown (MOUSE_LEFT)
	self.Pressed   = input.IsMouseDown (MOUSE_LEFT)
	
	self:DispatchEvent ("MouseEnter")
	if self.OnMouseEnter then self:OnMouseEnter () end
end

function PANEL:OnCursorMoved (x, y)
	self:DispatchEvent ("MouseMove", 0, x, y)
	
	local mouseCode = 0
	if input.IsMouseDown (MOUSE_LEFT)   then mouseCode = mouseCode + MOUSE_LEFT end
	if input.IsMouseDown (MOUSE_RIGHT)  then mouseCode = mouseCode + MOUSE_RIGHT end
	if input.IsMouseDown (MOUSE_MIDDLE) then mouseCode = mouseCode + MOUSE_MIDDLE end
	
	if self.OnMouseMove then self:OnMouseMove (mouseCode, self:CursorPos ()) end
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
	
	if mouseCode == MOUSE_LEFT then
		self.Depressed = true
		self.Pressed   = true
	end
end

function PANEL:OnMouseReleased (mouseCode)
	self:DispatchEvent ("MouseUp", mouseCode, self:CursorPos ())
	if self.OnMouseUp then self:OnMouseUp (mouseCode, self:CursorPos ()) end
	
	if mouseCode == MOUSE_LEFT then
		if SysTime () - self.LastLeftMouseButtonReleaseTime < 0.4 then
			if self.OnDoubleClick then self:OnDoubleClick (mouseCode, self:CursorPos ()) end
			self:DispatchEvent ("DoubleClick", self:CursorPos ())
		else
			if self.OnClick then self:OnClick (mouseCode, self:CursorPos ()) end
			self:DispatchEvent ("Click", self:CursorPos ())
		end
		self.Depressed = false
		self.Pressed   = false
		
		self.LastLeftMouseButtonReleaseTime = SysTime ()
	elseif mouseCode == MOUSE_RIGHT then
		self:DispatchEvent ("RightClick", self:CursorPos ())
	end
end

function PANEL:OnMouseWheeled (delta)
	self:DispatchEvent ("MouseWheel", delta, self:CursorPos ())
	if self.OnMouseWheel then self:OnMouseWheel (delta, self:CursorPos ()) end
end

Gooey.Register ("GPanel", PANEL, "DPanel")