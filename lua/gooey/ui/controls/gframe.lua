local PANEL = {}

function PANEL:Init ()
	self.ResizeGrip = vgui.Create ("GResizeGrip", self)
	self.ResizeGrip:SetSize (16, 16)
end

function PANEL:SetSizable (sizable)
	DFrame.SetSizable (self, sizable)
	self.ResizeGrip:SetVisible (sizable)
end

-- Event handlers
function PANEL:OnCursorMoved (x, y)
	self:DispatchEvent ("MouseMove", 0, x, y)
	if self.OnMouseMove then self:OnMouseMove (0, self:CursorPos ()) end
end

function PANEL:OnKeyCodePressed (keyCode)
	self:DispatchKeyboardAction (keyCode)
end
PANEL.OnKeyCodeTyped = PANEL.OnKeyCodePressed

function PANEL:OnMousePressed (mouseCode)
	DFrame.OnMousePressed (self, mouseCode)
	
	self:DispatchEvent ("MouseDown", mouseCode, self:CursorPos ())
	if self.OnMouseDown then self:OnMouseDown (mouseCode, self:CursorPos ()) end
end

function PANEL:OnMouseReleased (mouseCode)
	DFrame.OnMouseReleased (self, mouseCode)
	
	self:DispatchEvent ("MouseUp", mouseCode, self:CursorPos ())
	if self.OnMouseUp then self:OnMouseUp (mouseCode, self:CursorPos ()) end
	
	if mouseCode == MOUSE_LEFT then
		self:DispatchEvent ("Click")
	elseif mouseCode == MOUSE_RIGHT then
		self:DispatchEvent ("RightClick")
	end
end

function PANEL:OnMouseWheeled (delta)
	self:DispatchEvent ("MouseWheel", delta, self:CursorPos ())
	if self.OnMouseWheel then self:OnMouseWheel (delta, self:CursorPos ()) end
end

Gooey.Register ("GFrame", PANEL, "DFrame")