local PANEL = {}
Gooey.VPanel = Gooey.MakeConstructor (PANEL)

function PANEL:ctor ()
	PANEL.Init (self)
end

function PANEL:Init ()
	self.Disabled = false

	self.X = 0
	self.Y = 0
	self.Width = 24
	self.Height = 24
end

function PANEL:GetHeight ()
	return self.Height
end

function PANEL:GetLeft ()
	return self.X
end

function PANEL:GetPos ()
	return self.X, self.Y
end

function PANEL:GetTop ()
	return self.Y
end

function PANEL:GetWidth ()
	return self.Width
end

function PANEL:IsDisabled ()
	return self.Disabled
end

function PANEL:SetDisabled (disabled)
	self.Disabled = disabled
end

function PANEL:SetHeight (height)
	self.Height = height
end

function PANEL:SetLeft (x)
	self.X = x
end

function PANEL:SetPos (x, y)
	self.X = x
	self.Y = y
end

function PANEL:SetSize (width, height)
	self.Width = width
	self.Height = height
end

function PANEL:SetTop (y)
	self.Y = y
end

function PANEL:SetWidth (width)
	self.Width = width
end