 local PANEL = {}

function PANEL:Init ()
	self.Items = {}
	
	self.HoveredItem = nil
	self:SetTall (28)
end

function PANEL:AddButton (text, callback)
	local Button = Gooey.ToolbarButton (text, callback)
	self.Items [#self.Items + 1] = Button
	
	return Button
end

function PANEL:AddSeparator ()
	local Separator = Gooey.ToolbarSeparator ()
	self.Items [#self.Items + 1] = Separator
	
	return Separator
end

function PANEL:OnMousePressed (mouseCode)
	if mouseCode == MOUSE_LEFT then
		if self.HoveredItem and type (self.HoveredItem.Click) == "function" then
			self.HoveredItem:Click ()
		end
	end
end

function PANEL:Paint ()
	DPanel.Paint (self)
	
	local MouseX, MouseY = self:CursorPos ()
	self.HoveredItem = nil
	for _, Item in ipairs (self.Items) do
		local Hovered = false
		render.SetViewPort (Item:GetLeft (), Item:GetTop (), ScrW (), ScrH ())
		if self.Hovered then
			if MouseX >= Item:GetLeft () and MouseX <= Item:GetLeft () + Item:GetWidth () and
				MouseY >= Item:GetTop () and MouseY <= Item:GetTop () + Item:GetHeight () then
				self.HoveredItem = Item
				Hovered = true
			end
		end
		Item:Paint (Hovered)
	end
	render.SetViewPort (0, 0, ScrW (), ScrH ())
end

function PANEL:PerformLayout ()
	local X = 2
	for _, Item in ipairs (self.Items) do
		Item:SetLeft (X)
		Item:SetTop ((self:GetTall () - Item:GetHeight ()) * 0.5)
		X = X + Item:GetWidth ()
	end
end

vgui.Register ("GToolbar", PANEL, "DPanel")