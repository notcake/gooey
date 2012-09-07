local PANEL = {}

--[[
	Events:
		CheckStateChanged (bool checked)
			Fired when this checkbox has been checked or unchecked.
]]

function PANEL:Init ()
	self.Checked = false
	
	self:SetContentAlignment (4)
	self:SetText ("")
end

function PANEL:Paint ()
	local h = 14
	local w = 14
	
	-- Outline and background
	if not self:IsEnabled () then
		draw.RoundedBox (4, 0, 0, w, h, Color (64, 64, 64, 255))
		draw.RoundedBox (4, 1, 1, w - 2, h - 2, Color (172, 172, 172, 255))
		self:SetTextColor (GLib.Colors.Gray)
	else
		if self.Hovered then
			draw.RoundedBox (4, 0, 0, w, h, GLib.Colors.Gray)
			self:SetTextColor (GLib.Colors.White)
		else
			draw.RoundedBox (4, 0, 0, w, h, Color (30, 30, 30, 255))
			self:SetTextColor (Color (200, 200, 200, 255))
		end
		draw.RoundedBox (4, 1, 1, w - 2, h - 2, GLib.Colors.White)
	end
	
	if self.Checked then
		surface.SetFont ("marlett")
		surface.SetTextPos (0, 0)
		if not self:IsEnabled () then
			surface.SetTextColor (Color (64, 64, 64, 255))
		else
			surface.SetTextColor (GLib.Colors.Black)
		end
		surface.DrawText ("a")
	end
	return false
end

function PANEL:PerformLayout ()
	self:SetTextInset (self:GetTall () + 4)
end

function PANEL:SetChecked (checked)
	if self.Checked == checked then return end
	self.Checked = checked
	self:DispatchEvent ("CheckStateChanged", checked)
end

PANEL.SetValue = PANEL.SetChecked

-- Event handlers
function PANEL:DoClick ()
	if not self:IsEnabled () then return end
	self:SetChecked (not self.Checked)
end

Gooey.Register ("GCheckbox", PANEL, "GButton")