local PANEL = {}
Gooey.Image = Gooey.MakeConstructor (PANEL, Gooey.VPanel)

function PANEL:ctor ()
	self:Init ()
end

function PANEL:Init ()
	self.Image = nil
	self:SetSize (16, 16)
end

function PANEL:GetImage ()
	return self.Image
end

function PANEL:Paint ()
	if self.Image then
		local image = Gooey.ImageCache:GetImage (self.Image)
		if self.Disabled then
			image:Draw ((self:GetWide () - image:GetWidth ()) * 0.5, (self:GetTall () - image:GetHeight ()) * 0.5, 128, 128, 128)
		else
			image:Draw ((self:GetWide () - image:GetWidth ()) * 0.5, (self:GetTall () - image:GetHeight ()) * 0.5)
		end
	end
end

function PANEL:SetImage (image)
	self.Image = image
end

vgui.Register ("GImage", PANEL, "Panel")