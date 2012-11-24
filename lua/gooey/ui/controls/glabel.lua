local PANEL = {}

function PANEL:Init ()
end

function PANEL:GetLineHeight ()
	surface.SetFont (self:GetFont ())
	local _, lineHeight = surface.GetTextSize ("W")
	return lineHeight
end

Gooey.Register ("GLabel", PANEL, "DLabel")