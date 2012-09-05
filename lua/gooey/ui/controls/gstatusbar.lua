local PANEL = {}

function PANEL:Init ()
	self:SetTall (24)
	
	self:SetBackgroundColor (GLib.Colors.Silver)
end

function PANEL:Paint ()
	draw.RoundedBoxEx (4, 0, 0, self:GetWide (), self:GetTall (), self:GetBackgroundColor (), false, false, true, true)
	
	surface.SetFont ("Default")
	local w, h = surface.GetTextSize (self:GetText ())
	surface.SetTextColor (self:GetTextColor ())
	surface.SetTextPos (4, (self:GetTall () - h) * 0.5)
	surface.DrawText (self:GetText ())
end

function PANEL:PerformLayout ()
	self:SetWide (self:GetParent ():GetWide () - 4)
	self:SetPos (2, self:GetParent ():GetTall () - self:GetTall () - 2)
end

Gooey.Register ("GStatusBar", PANEL, "GPanel")