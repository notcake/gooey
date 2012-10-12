local PANEL = {}

function PANEL:Init ()
	self.Type = "Text"
	
	self.Id = "Unknown"
	self.Index = 0
	
	self.Alignment = 4
end

function PANEL:GetAlignment ()
	return self.Alignment
end

function PANEL:GetId ()
	return self.Id
end

function PANEL:GetIndex ()
	return self.Index
end

function PANEL:GetType ()
	return self.Type
end

function PANEL:SetAlignment (alignment)
	self.Alignment = alignment
	return self
end

function PANEL:SetId (id)
	self.Id = id
end

function PANEL:SetIndex (index)
	self.Index = index
	self:SetColumnID (index)
end

function PANEL:SetText (text)
	_R.Panel.SetText (self, text)
	return self
end

function PANEL:SetType (type)
	self.Type = type
	return self
end

function PANEL:SetWidth (width)
	width = math.Clamp (width, self.m_iMinWidth, self.m_iMaxWidth)
	
	if width ~= self:GetWide () then
		self:GetParent ():SetDirty (true)
	end
	
	self:SetWide (width)
	return width
end

Gooey.Register ("GListViewColumn", PANEL, "DListView_Column")