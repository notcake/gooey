local PANEL = {}

--[[
	Events:
		CheckedChanged (checked)
			Fired when this menu item's check state has changed.
]]

function PANEL:Init ()
	self.ContainingMenu = nil
	self.Checked = false
	self.Icon = nil
	
	self:SetContentAlignment (4)
	self:SetTextInset (20, 0)
	
	self:AddEventListener ("Click",
		function (_)
			self:RunAction ()
		end
	)
end

function PANEL:ContainsPoint (x, y)
	return x >= 0 and x < self:GetWide () and
	       y >= 0 and y < self:GetTall ()
end

function PANEL:DoClick ()
	self:DispatchEvent ("Click", self.ContainingMenu and self.ContainingMenu:GetTargetItem () or nil)
end

function PANEL:GetIcon ()
	return self.Icon and self.Icon.ImageName or nil
end

function PANEL:GetContainingMenu ()
	return self.ContainingMenu
end

function PANEL:IsChecked ()
	return self.Checked
end

function PANEL:Paint (w, h)
	if self:IsChecked () then
		surface.SetDrawColor (GLib.Colors.LightBlue)
		surface.DrawRect (2, 2, w - 4, h - 4)
		surface.SetDrawColor (GLib.Colors.CornflowerBlue)
		surface.DrawOutlinedRect (2, 2, w - 4, h - 4)
	end
	
	derma.SkinHook ("Paint", "MenuOption", self, w, h)
	
	surface.SetFont ("DermaDefault")
	if self:IsEnabled () then
		surface.SetTextColor (GLib.Colors.Black)
		surface.SetTextPos (22, 4)
	else
		surface.SetTextColor (GLib.Colors.White)
		surface.SetTextPos (23, 5)
		surface.DrawText (self:GetText ())
		surface.SetTextColor (GLib.Colors.Gray)
		surface.SetTextPos (22, 4)
	end
	surface.DrawText (self:GetText ())
	return true
end

function PANEL:SetChecked (checked)
	if self.Checked == checked then return self end
	
	self.Checked = checked
	self:DispatchEvent ("CheckedChanged", self.Checked)
	
	return self
end

function PANEL:SetIcon (icon)
	if not icon then
		self.Icon:Remove ()
		self.Icon = nil
		return
	end
	if not self.Icon then
		self.Icon = vgui.Create ("GImage", self)
		self.Icon:SetPos (3, 3)
		self.Icon:SetSize (16, 16)
	end
	
	self.Icon:SetImage (icon)
	
	return self
end

function PANEL:SetContainingMenu (menu)
	self.ContainingMenu = menu
end

-- Event handlers
function PANEL:OnMousePressed (mouseCode)
	if not self:IsEnabled () then
		return false
	end
	
	self.m_MenuClicking = true
	
	DButton.OnMousePressed (self, mouseCode)
end

function PANEL:OnMouseReleased (mouseCode)
	if not self:IsEnabled () then
		return false
	end
	
	DButton.OnMouseReleased (self, mouseCode)

	if self.m_MenuClicking then
		self.m_MenuClicking = false
		self.ContainingMenu:CloseMenus ()
	end
end

Gooey.Register ("GMenuItem", PANEL, "DMenuOption")