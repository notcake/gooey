local PANEL = {}

--[[
	Events:
		MenuOpening (GMenu menu)
			Fired when the menu is opening.
]]

function PANEL:Init ()
	self.Label = vgui.Create ("DLabel", self)
	self.Label:SetTextColor (GLib.Colors.Black)
	self.Label:SetTextInset (4)
	self.Label:SetContentAlignment (4)
	
	self.Menu = vgui.Create ("GMenu")
	self.MenuDownwards = true
	self.MenuOpen = false
	self.MenuCloseTime = 0
	self.Menu:AddEventListener ("MenuOpening",
		function ()
			self:DispatchEvent ("MenuOpening", self.Menu)
			self.Menu:PerformLayout ()
			self:PositionMenu ()
		end
	)
	self.Menu:AddEventListener ("MenuClosed",
		function ()
			self.MenuOpen = false
			self.MenuCloseTime = CurTime ()
			if not self:IsPressed () then
				self.Label:SetPos (0, 0)
			end
		end
	)
	
	
	self:AddEventListener ("MouseDown",
		function (_, mouseCode)
			if mouseCode == MOUSE_LEFT then
				self.Label:SetPos (1, 1)
				
				if self.MenuCloseTime ~= CurTime () then
					self.MenuOpen = true
					self.Menu:Open ()
				end
			end
		end
	)
	
	self:AddEventListener ("MouseEnter",
		function (_, mouseCode)
			if self:IsPressed () then
				self.Label:SetPos (1, 1)
			end
		end
	)
	
	self:AddEventListener ("MouseLeave",
		function (_, mouseCode)
			if not self.MenuOpen then
				self.Label:SetPos (0, 0)
			end
		end
	)
	
	self:AddEventListener ("MouseUp",
		function (_, mouseCode)
			if mouseCode == MOUSE_LEFT and not self.MenuOpen then
				self.Label:SetPos (0, 0)
			end
		end
	)
end

function PANEL:GetText ()
	return self.Label:GetText ()
end

function PANEL:Paint ()
	local w, h = self:GetSize ()
	surface.SetFont ("Default")
	local textWidth = surface.GetTextSize (self:GetText ())
	local arrowWidth = 14
	local boxWidth = 4 + textWidth + 2 + arrowWidth
	
	if self:IsHovered () or self.MenuOpen then
		draw.RoundedBoxEx (4, 0, 0, boxWidth, h, GLib.Colors.Gray, self.MenuDownwards or not self.MenuOpen, self.MenuDownwards or not self.MenuOpen, not self.MenuDownwards or not self.MenuOpen, not self.MenuDownwards or not self.MenuOpen)
		if self:IsPressed () or self.MenuOpen then
			draw.RoundedBoxEx (4, 1, 1, boxWidth - 2, h - 2, GLib.Colors.DarkGray,       self.MenuDownwards or not self.MenuOpen, self.MenuDownwards or not self.MenuOpen, not self.MenuDownwards or not self.MenuOpen, not self.MenuDownwards or not self.MenuOpen)
		else
			draw.RoundedBoxEx (4, 1, 1, boxWidth - 2, h - 2, self:GetBackgroundColor (), self.MenuDownwards or not self.MenuOpen, self.MenuDownwards or not self.MenuOpen, not self.MenuDownwards or not self.MenuOpen, not self.MenuDownwards or not self.MenuOpen)
		end
		
		draw.RoundedBoxEx (4, 4 + textWidth + 2,     0, arrowWidth,     h,     GLib.Colors.Gray, false, self.MenuDownwards or not self.MenuOpen, false, not self.MenuDownwards or not self.MenuOpen)
		if self:IsPressed () or self.MenuOpen then
			draw.RoundedBoxEx (4, 4 + textWidth + 2 + 1, 1, arrowWidth - 2, h - 2, GLib.Colors.DarkGray,       false, self.MenuDownwards or not self.MenuOpen, false, not self.MenuDownwards or not self.MenuOpen)
		else
			draw.RoundedBoxEx (4, 4 + textWidth + 2 + 1, 1, arrowWidth - 2, h - 2, self:GetBackgroundColor (), false, self.MenuDownwards or not self.MenuOpen, false, not self.MenuDownwards or not self.MenuOpen)
		end
	else
		draw.RoundedBoxEx (4, 4 + textWidth + 2,     0, arrowWidth,     h,     GLib.Colors.Gray,           true, self.MenuDownwards or not self.MenuOpen, true, not self.MenuDownwards or not self.MenuOpen)
		draw.RoundedBoxEx (4, 4 + textWidth + 2 + 1, 1, arrowWidth - 2, h - 2, self:GetBackgroundColor (), true, self.MenuDownwards or not self.MenuOpen, true, not self.MenuDownwards or not self.MenuOpen)
	end
	
	local arrowColor = self:IsEnabled () and GLib.Colors.Black or GLib.Colors.Gray
	if (self:IsHovered () and self:IsPressed ()) or self.MenuOpen then
		draw.SimpleText ("6", "Marlett", 4 + textWidth + 2 + arrowWidth * 0.5 + 1, h * 0.5 + 1, arrowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText ("6", "Marlett", 4 + textWidth + 2 + arrowWidth * 0.5,     h * 0.5,     arrowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function PANEL:PerformLayout ()
	self.Label:SetPos (0, 0)
	self.Label:SetSize (self:GetWide (), self:GetTall ())
end

function PANEL:PositionMenu ()
	local menuHeight = self.Menu:GetTall ()
	local x, y = self:LocalToScreen (0, self:GetTall () - 1)
	
	if y + menuHeight > ScrH () then
		x, y = self:LocalToScreen (0, 0 - menuHeight + 1)
		self.MenuDownwards = false
	else
		self.MenuDownwards = true
	end
	self.Menu:SetPos (x, y)
end

function PANEL:SetText (text)
	self.Label:SetText (text)
end

-- Event handlers
function PANEL:OnRemoved ()
	self.Menu:Remove ()
end

Gooey.Register ("GStatusBarComboBox", PANEL, "GPanel")