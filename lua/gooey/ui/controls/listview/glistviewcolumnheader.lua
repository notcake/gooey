local PANEL = {}

function PANEL:Init ()
	self.Column = nil
	
	self:SetCursor ("arrow")
	self:SetTextInset (8, 0)
	self:SetWide (256)
end

function PANEL:GetColumn ()
	return self.Column
end

function PANEL:GetListView (listView)
	return self.Column:GetListView ()
end

function PANEL:ResizeColumn (size)
	self:GetListView ():OnRequestResize (self:GetColumn (), size)
end

function PANEL:SetColumn (column)
	self.Column = column
end

function PANEL:SetWidth (width)
	width = math.Clamp (width, self.m_iMinWidth, self.m_iMaxWidth)
	
	if width ~= self:GetWide () then
		self:GetListView ():SetDirty (true)
	end
	
	self:SetWide (width)
	return width
end

Gooey.Register ("GListViewColumnHeader", PANEL, "GButton")