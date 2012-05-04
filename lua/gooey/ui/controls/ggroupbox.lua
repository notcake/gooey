local PANEL = {}

function PANEL:Init ()
	self.Title = vgui.Create ("DLabel", self)
	self.Title:SetColor (Color (255, 255, 255, 255))
	
	self.Container = vgui.Create ("GPanel", self)
	
	self:SetOutlineColor (Color (160, 160, 160, 255))
	self:SetFont ("TabLarge")
	
	for k, _ in pairs (self:GetTable ()) do
		if k:sub (1, 6) == "Create" then
			self [k] = function (self, ...)
				return self:GetContainer () [k] (self:GetContainer (), ...)
			end
		end
	end
	
	Gooey.EventProvider (self)
end

function PANEL:GetContainer ()
	return self.Container
end

function PANEL:GetFont ()
	return self.Font
end

function PANEL:GetOutlineColor ()
	return self.OutlineColor
end

function PANEL:Paint ()
	local textHeight = draw.GetFontHeight (self:GetFont ()) * 0.5
	draw.RoundedBox (4, 0, textHeight, self:GetWide (), self:GetTall () - textHeight, self:GetOutlineColor ())
	draw.RoundedBox (4, 1, 1 + textHeight, self:GetWide () - 2, self:GetTall () - 2 - textHeight, self:GetBackgroundColor ())
	surface.SetDrawColor (self:GetBackgroundColor ())
	surface.DrawRect (self.Title:GetPos () - 4, 0, self.Title:GetWide () + 8, self.Title:GetTall ())
end

function PANEL:PerformLayout ()
	self.Title:SetPos (12, 0)
	self.Container:SetPos (6, self.Title:GetTall () + 4)
	self.Container:SetSize (self:GetWide () - 12, self:GetTall () - self.Title:GetTall () - 8)
	
	self:DispatchEvent ("PerformLayout")
end

function PANEL:SetFont (font)
	self.Font = font
	self.Title:SetFont (font)
end

function PANEL:SetOutlineColor (color)
	self.OutlineColor = color
end

function PANEL:SetText (text)
	_R.Panel.SetText (self, text)
	self.Title:SetText (text)
	self.Title:SizeToContents ()
end

vgui.Register ("GGroupBox", PANEL, "GPanel")