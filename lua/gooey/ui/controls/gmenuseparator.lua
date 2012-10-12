local PANEL = {}

function PANEL:Init ()
	self:SetTall (1)
end

function PANEL:Paint ()
	surface.SetDrawColor (Color (0, 0, 0, 100))
	surface.DrawRect (0, 0, self:GetWide (), self:GetTall ())
end

Gooey.Register ("GMenuSeparator", PANEL, "DPanel")