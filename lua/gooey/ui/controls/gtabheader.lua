local PANEL = {}

function PANEL:Init ()
	self.Tab = nil
	self.Image = Gooey.Image ()
	self.CloseButton = Gooey.CloseButton ()
	self.CloseButton:SetVisible (false)
	self.CloseButton:AddEventListener ("Click",
		function ()
			self.Tab:DispatchEvent ("CloseRequested")
		end
	)
	
	self.Text = "Tab"

	self:AddEventListener ("MouseDown",
		function (_, mouseCode, x, y)
			if mouseCode == MOUSE_LEFT then
				if not self.CloseButton:IsHovered () then
					self.Tab:Select ()
				end
			end
		end
	)
	
	self:AddEventListener ("RightClick",
		function (_)
			if self.Tab:GetContextMenu () then
				self.Tab:GetContextMenu ():Open (self.Tab)
			end
		end
	)
	
	self.VPanelContainer = Gooey.VPanelContainer (self)
	self.VPanelContainer:AddControl (self.Image)
	self.VPanelContainer:AddControl (self.CloseButton)
end

function PANEL:GetIcon ()
	return self.Image:GetImage ()
end

function PANEL:GetText ()
	return self.Text
end

function PANEL:IsCloseButtonVisible ()
	return self.CloseButton:IsVisible ()
end

function PANEL:IsHovered ()
	return self.Hovered
end

function PANEL:IsSelected ()
	return self.Tab:IsSelected ()
end

function PANEL:SetCloseButtonVisible (closeButtonVisible)
	self.CloseButton:SetVisible (closeButtonVisible)
	
	self:InvalidateLayout ()
end

function PANEL:SetIcon (icon)
	if self.Image:GetImage () == icon then return end
	
	self.Image:SetImage (icon)
	
	self:InvalidateLayout ()
end

function PANEL:SetTab (tab)
	self.Tab = tab
end

function PANEL:SetText (text)
	self.Text = text
	
	self:InvalidateLayout ()
end

function PANEL:Paint ()
	local w, h = self:GetSize ()
	
	if self.Tab:IsSelected () then
		draw.RoundedBoxEx (4, 0, 0, w, h, GLib.Colors.Silver, true, true, false, false)
	elseif self:IsHovered () then
		draw.RoundedBoxEx (4, 0, 0, w, h, GLib.Colors.DarkGray, true, true, false, false)
	else
		draw.RoundedBoxEx (4, 0, 0, w, h, GLib.Colors.Gray, true, true, false, false)
	end
	
	local x = 4
	if self:GetIcon () then
		x = x + self.Image:GetWidth () + 4
	end
	
	surface.SetFont ("Default")
	local _, textHeight = surface.GetTextSize (self:GetText ())
	surface.SetTextColor (GLib.Colors.Black)
	surface.SetTextPos (x, (self:GetTall () - textHeight) * 0.5)
	surface.DrawText (self:GetText ())
	
	self.VPanelContainer:Paint (Gooey.RenderContext)
end

function PANEL:PerformLayout ()
	local x = 4
	
	if self:GetIcon () then
		self.Image:SetPos (4, (self:GetTall () - self.Image:GetHeight ()) * 0.5)
		x = x + self.Image:GetWidth () + 4
	end
	
	surface.SetFont ("Default")
	local w, h = surface.GetTextSize (self:GetText ())
	x = x + w + 4
	
	if self:IsCloseButtonVisible () then
		local baseline = (self:GetTall () + h) * 0.5
		self.CloseButton:SetPos (x, baseline - self.CloseButton:GetHeight ())
		self.CloseButton:SetPos (x, (self:GetTall () - self.CloseButton:GetHeight ()) * 0.5 + 1)
		x = x + self.CloseButton:GetWidth () + 4
	end
	
	if x < 64 then x = 64 end
	self:SetWidth (x)
end

Gooey.Register ("GTabHeader", PANEL, "GPanel")