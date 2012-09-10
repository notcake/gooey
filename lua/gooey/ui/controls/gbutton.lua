local PANEL = {}

function PANEL:Init ()
end

-- Event handlers
function PANEL:DoClick ()
	self:DispatchEvent ("Click")
end

function PANEL:DoRightClick ()
	self:DispatchEvent ("RightClick")
end

function PANEL:OnMousePressed (mouseCode)
	self:DispatchEvent ("MouseDown", mouseCode, self:CursorPos ())
	DButton.OnMousePressed (self, mouseCode)
	
	if mouseCode == MOUSE_LEFT then
		self.Depressed = true
		self.Pressed = true
	end
end

function PANEL:OnMouseReleased (mouseCode)
	self:DispatchEvent ("MouseUp", mouseCode, self:CursorPos ())
	DButton.OnMouseReleased (self, mouseCode)
	
	if mouseCode == MOUSE_LEFT then
		self.Depressed = false
		self.Pressed = false
	end
end

Gooey.Register ("GButton", PANEL, "DButton")