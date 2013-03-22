local PANEL = {}

function PANEL:Init ()
	self.Column = nil
	
	self:SetZPos (10)
end

function PANEL:GetColumn ()
	return self.Column
end

function PANEL:ResizeColumn (size)
	self:GetParent ():OnRequestResize (self:GetColumn (), size)
end

function PANEL:SetColumn (column)
	self.Column = column
end

function PANEL:SetWidth (width)
	width = math.Clamp (width, self.m_iMinWidth, self.m_iMaxWidth)
	
	if width ~= self:GetWide () then
		self:GetParent ():SetDirty (true)
	end
	
	self:SetWide (width)
	return width
end

Gooey.Register ("GListViewColumnX", PANEL, "DListView_Column")