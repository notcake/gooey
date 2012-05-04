local PANEL = {}
Gooey.ToolbarButton = Gooey.MakeConstructor (PANEL, Gooey.ToolbarItem)

function PANEL:ctor (text, callback)
	self:Init ()
	
	self.Text = text
	self.Callback = callback
	self.Width = 24
	self.Height = 24
end

function PANEL:Init ()
	self.Icon = nil
end

function PANEL:Click ()
	if self.Callback then
		self.Callback (self)
	end
end

function PANEL:GetIcon ()
	return self.Icon
end

function PANEL:Paint (hovered)
	if hovered then
		draw.RoundedBox (4, 0, 0, self.Width, self.Height, Color (128, 128, 128, 255))
	end
	if self.Icon then
		local Image = Gooey.ImageCache:GetImage (self.Icon)
		if self.Disabled then
			Image:Draw ((self.Width - Image:GetWidth ()) * 0.5, (self.Height - Image:GetHeight ()) * 0.5, 128, 128, 128)
		else
			Image:Draw ((self.Width - Image:GetWidth ()) * 0.5, (self.Height - Image:GetHeight ()) * 0.5)
		end
	end
end

function PANEL:SetIcon (icon)
	self.Icon = icon
end