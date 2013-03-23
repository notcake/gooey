local PANEL = {}

function PANEL:Init ()
	self.Column = nil
	
	self:SetWide (8)
	self:SetCursor ("sizewe")
	
	self:SetZPos (10)
	
	self.DragController = Gooey.DragController (self)
	self.DragController:AddEventListener ("PositionCorrectionChanged",
		function (_, deltaX, deltaY)
			local width = self.Column:GetHeader ():GetWide () + deltaX
			width = math.max (0, self.Column:GetMinimumWidth (), width)
			self.Column:GetHeader ():SetWide (width)
			
			local _, y = self:GetPos ()
			self:SetPos (self.Column:GetHeader ():GetPos () + self.Column:GetHeader ():GetWide () - self:GetWide () / 2, y)
		end
	)
end

function PANEL:Paint (w, h)
	surface.SetDrawColor (Color (255, 0, 0, 128))
	surface.DrawRect (0, 0, w, h)
end

function PANEL:SetColumn (column)
	self.Column = column
	return self
end

Gooey.Register ("GListViewColumnSizeGrip", PANEL, "GPanel")