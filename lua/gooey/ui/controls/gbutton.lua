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
end

function PANEL:OnMouseReleased (mouseCode)
	self:DispatchEvent ("MouseUp", mouseCode, self:CursorPos ())
	DButton.OnMouseReleased (self, mouseCode)
end

Gooey.Register ("GButton", PANEL, "DButton")