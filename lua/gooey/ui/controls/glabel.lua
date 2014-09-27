local PANEL = {}

function PANEL:Init ()
end

function PANEL:ApplySchemeSettings ()
	self:UpdateColours (self:GetSkin ())
	
	self:SetFGColor (self.m_colText or self.m_colTextStyle)
end

function PANEL:GetLineHeight ()
	surface.SetFont (self:GetFont ())
	local _, lineHeight = surface.GetTextSize ("W")
	return lineHeight
end

function PANEL:UpdateColours (skin)
	if self.TextColor then return end
	
	local ret = DLabel.UpdateColours (self, skin)
	self:SetTextColor (self:GetTextStyleColor ())
	return ret
end

Gooey.Register ("GLabel", PANEL, "DLabel")