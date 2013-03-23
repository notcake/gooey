local self = {}
Gooey.ListView.Column = Gooey.MakeConstructor (self)

--[[
	Events:
		AlignmentChanged (HorizontalAlignment alignment)
			Fired when this column's alignment has changed.
		HeaderAlignmentChanged (HorizontalAlignment headerAlignment)
			Fired when this column's header alignment has changed.
		TextChanged (text)
			Fired when this column's text has changed.
		VisibleChanged (visible)
			Fired when this column's visibility has changed.
]]

function self:ctor (columnCollection, id)
	self.ColumnCollection = columnCollection
	self.ListView = self.ColumnCollection:GetListView ()
	self.Header = nil
	
	-- Column
	self.Id = nil
	self.Visible = true
	
	-- Header
	self.Text = nil
	self.HeaderAlignment = Gooey.HorizontalAlignment.Left
	
	-- Items
	self.Alignment = Gooey.HorizontalAlignment.Left
	self.Type = Gooey.ListView.ColumnType.Text
	
	-- Positioning and Sizing
	self.Index = 0
	self.MinimumWidth = 128
	self.MaximumWidth = 256
	
	-- Sorting
	self.Comparator = self.DefaultComparator
	
	Gooey.EventProvider (self)
	
	self.Header = vgui.Create ("GListViewColumnHeader", self.ListView:GetHeader ())
	self.Header:SetColumn (self)
	self:UpdateHeaderAlignment ()
	self:HookHeader (self.Header)
	self:SetId (id)
	self:SetText (id)
end

function self:dtor ()
	if self.Header then
		self:UnhookHeader (self.Header)
		self.Header:Remove ()
		self.Header = nil
	end
end

-- Column
function self:GetColumnCollection ()
	return self.ColumnCollection
end

function self:GetId (id)
	return self.Id
end

function self:GetListView ()
	return self.ListView
end

function self:IsVisible ()
	return self.Visible
end

function self:SetId (id)
	self.Id = id
	
	if not self.Header then return self end
	self.Header:SetName (id)
	return self
end

function self:SetVisible (visible)
	if self.Visible == visible then return self end
	
	self.Visible = visible
	self.Header:SetVisible (self.Visible)
	self:DispatchEvent ("VisibleChanged", self.Visible)
	return self
end

-- Header
function self:GetHeader ()
	return self.Header
end

function self:GetHeaderAlignment ()
	return self.HeaderAlignment
end

function self:GetText ()
	return self.Text
end

function self:SetHeaderAlignment (headerAlignment)
	if self.HeaderAlignment == headerAlignment then return self end
	
	self.HeaderAlignment = headerAlignment
	self:UpdateHeaderAlignment ()
	
	self:DispatchEvent ("HeaderAlignmentChanged", self.HeaderAlignment)
	return self
end

function self:SetText (text)
	if self.Text == text then return self end
	
	self.Text = text
	self.Header:SetText (self.Text)
	self:DispatchEvent ("TextChanged", self.Text)
	return self
end

-- Items
function self:GetAlignment ()
	return self.Alignment
end

function self:GetType ()
	return self.Type
end

function self:SetAlignment (alignment)
	if self.Alignment == alignment then return end
	
	self.Alignment = alignment
	self:DispatchEvent ("AlignmentChanged", self.Alignment)
	return self
end

function self:SetType (columnType)
	if self.Type == columnType then return self end
	
	self.Type = columnType
	return self
end

-- Positioning and Sizing
function self:GetIndex ()
	return self.Index
end

function self:GetMaximumWidth ()
	return self.MaximumWidth
end

function self:GetMinimumWidth ()
	return self.MinimumWidth
end

function self:GetWidth ()
	return self.Header:GetWide ()
end

function self:SetIndex (index)
	self.Index = index
	return self
end

function self:SetMaximumWidth (maximumWidth)
	self.MaximumWidth = maximumWidth
	return self
end

function self:SetMinimumWidth (minimumWidth)
	self.MinimumWidth = minimumWidth
	return self
end

-- Sorting
function self.DefaultComparator (a, b)
	return a:GetText () < b:GetText ()
end

function self:GetComparator ()
	return self.Comparator
end

function self:SetComparator (comparator)
	self.Comparator = comparator or self.DefaultComparator
end

-- Internal, do not call
function self:UpdateHeaderAlignment ()
	if self.HeaderAlignment == Gooey.HorizontalAlignment.Left then
		self.Header:SetContentAlignment (4)
	elseif self.HeaderAlignment == Gooey.HorizontalAlignment.Center then
		self.Header:SetContentAlignment (5)
	elseif self.HeaderAlignment == Gooey.HorizontalAlignment.Right then
		self.Header:SetContentAlignment (6)
	end
end

function self:HookHeader (header)
	if not header then return end
	
	header:AddEventListener ("Removed", tostring (self),
		function ()
			self:dtor ()
		end
	)
end

function self:UnhookHeader (header)
	if not header then return end
	
	header:RemoveEventListener ("Removed", tostring (self))
end