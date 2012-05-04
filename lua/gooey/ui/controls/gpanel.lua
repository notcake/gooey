local PANEL = {}

function PANEL:Init ()
	self.BackgroundColor = nil
end

function PANEL:Create (class)
	return vgui.Create (class, self)
end

function PANEL:CreateLabel (text)
	local label = vgui.Create ("DLabel", self)
	label:SetText (text)
	return label
end

function PANEL:GetBackgroundColor ()
	if not self.BackgroundColor then
		self.BackgroundColor = self.m_Skin.control_color or Color (140, 140, 140, 255)
	end
	return self.BackgroundColor
end

function PANEL:Paint ()
	draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), self:GetBackgroundColor ())
end

function PANEL:SetBackgroundColor (color)
	self.BackgroundColor = color
end

vgui.Register ("GPanel", PANEL, "DPanel")