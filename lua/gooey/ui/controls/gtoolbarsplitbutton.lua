local PANEL = {}
Gooey.ToolbarSplitButton = Gooey.MakeConstructor (PANEL, Gooey.ToolbarItem)

function PANEL:ctor (text)
	self:Init ()
	
	self.Text = text
	self.Width = 36
	self.Height = 24
	
	self.DropDownMenu = vgui.Create ("GMenu")
	self.DropDownMenuOpen = false
	self.DropDownCloseTime = 0
	self.DropDownMenu:AddEventListener ("MenuClosed",
		function (_)
			self.DropDownMenuOpen = false
			self.DropDownCloseTime = CurTime ()
			self:DispatchEvent ("DropDownClosed", self.DropDownMenu)
		end
	)
	
	self:AddEventListener ("MouseDown", tostring (self),
		function (_, mouseCode, x, y)
			local buttonWidth = self.Height
			local rightWidth = self.Width - self.Height
			if x < buttonWidth then
				self:SetPressed (true)
			elseif self:IsEnabled () then
				if self.DropDownCloseTime ~= CurTime () then
					self.DropDownMenuOpen = true
					self:DispatchEvent ("DropDownOpening", self.DropDownMenu)
					self.DropDownMenu:Open ()
					self.DropDownMenu:SetPos (self:LocalToScreen (0, self.Height - 1))
				end
			end
		end
	)
end

function PANEL:Init ()
	self.Icon = nil
end

function PANEL:GetIcon ()
	return self.Icon
end

function PANEL:Paint (renderContext)
	local buttonWidth = self.Height
	local rightWidth = self.Width - self.Height
	
	if self:IsEnabled () and (self:IsHovered () or self.DropDownMenuOpen) then
		-- Enabled and hovered
		if self:IsPressed () then
			draw.RoundedBoxEx (4, 0, 0, self.Width,     self.Height,     GLib.Colors.Gray,      true, true, not self.DropDownMenuOpen, not self.DropDownMenuOpen)
			draw.RoundedBoxEx (4, 1, 1, self.Width - 2, self.Height - 2, GLib.Colors.DarkGray,  true, true, not self.DropDownMenuOpen, not self.DropDownMenuOpen)
		else
			draw.RoundedBoxEx (4, 0, 0, self.Width,     self.Height,     GLib.Colors.Gray,      true, true, not self.DropDownMenuOpen, not self.DropDownMenuOpen)
			draw.RoundedBoxEx (4, 1, 1, self.Width - 2, self.Height - 2, GLib.Colors.LightGray, true, true, not self.DropDownMenuOpen, not self.DropDownMenuOpen)
		end
		surface.SetDrawColor (GLib.Colors.Gray)
		surface.DrawLine (buttonWidth, 0, buttonWidth, self.Height)
	end
	
	local dropDownArrowColor = self:IsEnabled () and GLib.Colors.Black or GLib.Colors.Gray
	if self.DropDownMenuOpen then
		draw.RoundedBoxEx (4, buttonWidth,     0, rightWidth,     self.Height,     GLib.Colors.Gray,     false, true, false, not self.DropDownMenuOpen)
		draw.RoundedBoxEx (4, buttonWidth + 1, 1, rightWidth - 2, self.Height - 2, GLib.Colors.DarkGray, false, true, false, not self.DropDownMenuOpen)
		draw.SimpleText ("6", "Marlett", self.Height + rightWidth * 0.5 + 1, self.Height * 0.5 + 1, dropDownArrowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText ("6", "Marlett", self.Height + rightWidth * 0.5,     self.Height * 0.5,     dropDownArrowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	if self.Icon then
		local image = Gooey.ImageCache:GetImage (self.Icon)
		if self:IsEnabled () then
			-- Enabled
			if self:IsPressed () then
				image:Draw (renderContext, (buttonWidth - image:GetWidth ()) * 0.5 + 1, (self.Height - image:GetHeight ()) * 0.5 + 1)
			else
				image:Draw (renderContext, (buttonWidth - image:GetWidth ()) * 0.5, (self.Height - image:GetHeight ()) * 0.5)
			end
		else
			-- Disabled
			image:Draw (renderContext, (buttonWidth - image:GetWidth ()) * 0.5, (self.Height - image:GetHeight ()) * 0.5, 0, 0, 0, 160)
			image:Draw (renderContext, (buttonWidth - image:GetWidth ()) * 0.5, (self.Height - image:GetHeight ()) * 0.5, nil, nil, nil, 32)
		end
	end
end

function PANEL:SetIcon (icon)
	self.Icon = icon
	
	return self
end

function PANEL:OnRemoved ()
	self.DropDownMenu:Remove ()
end