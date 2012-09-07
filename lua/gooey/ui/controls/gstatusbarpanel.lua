local PANEL = {}

function PANEL:Init ()
	self.StatusBar = nil
	
	self.Contents = nil
	self.OwnsContents = false
	
	self.SizingMethod = Gooey.SizingMethod.ExpandToFit
	self.FixedWidth = 300
	self.PercentageWidth = 100
end

function PANEL:GetContents ()
	return self.Contents
end

function PANEL:GetSizingMethod ()
	return self.SizingMethod
end

function PANEL:GetFixedWidth ()
	return self.FixedWidth
end

function PANEL:GetPercentageWidth ()
	return self.PercentageWidth
end

function PANEL:GetText ()
	if not self.Contents then return end
	return self.Contents:GetText ()
end

function PANEL:IsFixedWidth ()
	return self.SizingMethod == Gooey.SizingMethod.FixedWidth
end

function PANEL:IsPercentageWidth ()
	return self.SizingMethod == Gooey.SizingMethod.PercentageWidth
end

function PANEL:Paint ()
end

function PANEL:PerformLayout ()
	self.Contents:SetPos (0, 0)
	self.Contents:SetSize (self:GetWide (), self:GetTall ())
end

function PANEL:SetContents (contents, ownsContents)
	if self.Contents == contents then return end
	if ownsContents == nil then ownsContents = true end
	
	if self.Contents then
		if self.OwnsContents then
			self.Contents:Remove ()
		end
		self.Contents = nil
	end
	
	self.Contents = contents
	self.OwnsContents = contents
	
	if self.Contents then
		self.Contents:SetParent (self)
		self.Contents:SetVisible (true)
	end
	
	self:InvalidateLayout ()
end

function PANEL:SetFixedWidth (width)
	self:SetSizingMethod (Gooey.SizingMethod.Fixed)
	
	if self.FixedWidth == width then return end
	self.FixedWidth = width
	self:GetParent ():InvalidateLayout ()
end

function PANEL:SetPercentageWidth (percentage)
	self:SetSizingMethod (Gooey.SizingMethod.Percentage)
	
	if self.PercentageWidth == percentage then return end
	self.PercentageWidth = percentage
	self:GetParent ():InvalidateLayout ()
end

function PANEL:SetSizingMethod (sizingMethod)
	if self.SizingMethod == sizingMethod then return end
	
	self.SizingMethod = sizingMethod
	self:GetParent ():InvalidateLayout ()
end

function PANEL:SetText (text)
	if not self.Contents then return end
	text = text or ""
	
	self.Contents:SetText (text)
end

Gooey.Register ("GStatusBarPanel", PANEL, "GPanel")