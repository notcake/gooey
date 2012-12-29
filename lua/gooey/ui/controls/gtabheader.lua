local PANEL = {}

function PANEL:Init ()
	self.Tab = nil
	
	self.Offset = 0
	
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
				self.Tab:RequestFocus ()
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
	
	self.DragController = Gooey.DragController (self)
	self.DragController:AddEventListener ("DragEnded",
		function ()
			if not self:GetTabControl () then return end
			self:GetTabControl ():EndExternalTabDragging (self:GetTab ())
		end
	)
	self.DragController:AddEventListener ("PositionCorrectionChanged",
		function ()
			if not self:GetTabControl () then return end
			if not self:GetTabControl ():IsPointInHeaderArea (self:GetTabControl ():CursorPos ()) then
				self:GetTabControl ():BeginExternalTabDragging (self:GetTab ())
				return
			else
				self:GetTabControl ():EndExternalTabDragging (self:GetTab ())
			end
			
			local tabIndex = self.Tab:GetIndex ()
			local cursorX = self:CursorPos () + self:GetOffset ()
			if cursorX < self:GetOffset () then
				repeat
					tabIndex = tabIndex - 1
					self:GetTabControl ():SetTabIndex (self.Tab, tabIndex)
				until cursorX > self:GetOffset () or tabIndex < 1
			elseif cursorX > self:GetOffset () + self:GetWide () then
				repeat
					tabIndex = tabIndex + 1
					self:GetTabControl ():SetTabIndex (self.Tab, tabIndex)
				until cursorX <= self:GetOffset () + self:GetWide () or tabIndex > self:GetTabControl ():GetTabCount ()
			end
			if self.Tab:IsSelected () then
				self:GetTabControl ():EnsureTabVisible (self.Tab)
			end
		end
	)
end

function PANEL:GetIcon ()
	return self.Image:GetImage ()
end

function PANEL:GetOffset ()
	return self.Offset
end

function PANEL:GetTab ()
	return self.Tab
end

function PANEL:GetTabControl ()
	return self.Tab and self.Tab:GetTabControl () or nil
end

function PANEL:GetText ()
	return self.Text or ""
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

function PANEL:Paint (w, h)
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
	
	surface.SetFont ("DermaDefault")
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
	
	surface.SetFont ("DermaDefault")
	local w, h = surface.GetTextSize (self:GetText ())
	x = x + w + 4
	
	if self:IsCloseButtonVisible () then
		x = x + self.CloseButton:GetWidth () + 4
	end
	
	if x < 64 then x = 64 end
	self:SetWidth (x)
	
	if self:IsCloseButtonVisible () then
		local baseline = (self:GetTall () + h) * 0.5
		self.CloseButton:SetPos (x - 4 - self.CloseButton:GetWidth (), baseline - self.CloseButton:GetHeight ())
		self.CloseButton:SetPos (x - 4 - self.CloseButton:GetWidth (), (self:GetTall () - self.CloseButton:GetHeight ()) * 0.5 + 1)
	end
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

function PANEL:SetOffset (offset)
	self.Offset = offset
end

function PANEL:SetTab (tab)
	self.Tab = tab
end

function PANEL:SetText (text)
	text = text or ""
	if self.Text == text then return end
	
	self.Text = text
	self.Tab:DispatchEvent ("TextChanged", text)
	
	self:InvalidateLayout ()
end

-- Event handlers
function PANEL:OnMouseWheel (delta, x, y)
	if not self:GetTabControl () then return end
	self:GetTabControl ():OnMouseWheeled (delta)
end

Gooey.Register ("GTabHeader", PANEL, "GPanel")