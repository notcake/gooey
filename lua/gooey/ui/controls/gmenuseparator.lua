local PANEL = {}

function PANEL:Init ()
	self:SetTall (1)
end

function PANEL:Paint (w, h)
	surface.SetDrawColor (Color (0, 0, 0, 100))
	surface.DrawRect (0, 0, w, h)
end

Gooey.Register ("GMenuSeparator", PANEL, "DPanel")