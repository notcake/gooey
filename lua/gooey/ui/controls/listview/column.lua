local self = {}
Gooey.ListView.Column = Gooey.MakeConstructor (self)

--[[
	Events:
		TextChanged (text)
			Fired when this column's text has changed.
		VisibleChanged (visible)
			Fired when this column's visibility has changed.
]]

function self:ctor (listView, id)
	self.ListView = listView
	self.Control = nil
	
	self.Id = nil
	self.Text = nil
	self.Alignment = 4
	self.Type = Gooey.ListView.ColumnType.Text
	
	self.Visible = true
	
	-- Positioning and Sizing
	self.Index = 0
	self.MaximumWidth = 256
	
	Gooey.EventProvider (self)
	
	self.Control = vgui.Create ("GListViewColumnX", self.ListView)
	self.Control:SetColumn (self)
	self:HookControl (self.Control)
	self:SetId (id)
	self:SetText (id)
end

function self:dtor ()
	if self.Control then
		self:UnhookControl (self.Control)
		self.Control:Remove ()
		self.Control = nil
	end
end

function self:GetAlignment ()
	return self.Alignment
end

function self:GetControl ()
	return self.Control
end

function self:GetId (id)
	return self.Id
end

function self:GetListView ()
	return self.ListView
end

function self:GetText ()
	return self.Text
end

function self:GetType ()
	return self.Type
end

function self:IsVisible ()
	return self.Visible
end

function self:SetAlignment (alignment)
	self.Alignment = alignment
	return self
end

function self:SetId (id)
	self.Id = id
	
	if not self.Control then return self end
	self.Control:SetName (id)
	return self
end

function self:SetText (text)
	if self.Text == text then return self end
	
	self.Text = text
	self.Control:SetText (self.Text)
	self:DispatchEvent ("TextChanged", self.Text)
	return self
end

function self:SetType (columnType)
	if self.Type == columnType then return self end
	
	self.Type = columnType
	return self
end

function self:SetVisible (visible)
	if self.Visible == visible then return self end
	
	self.Visible = visible
	self.Control:SetVisible (not self.ListView:GetHideHeaders () and self.Visible)
	self:DispatchEvent ("VisibleChanged", self.Visible)
	return self
end

-- Positioning and Sizing
function self:GetIndex ()
	return self.Index
end

function self:GetMaximumWidth ()
	return self.MaximumWidth
end

function self:SetIndex (index)
	self.Index = index
	
	if not self.Control then return self end
	self.Control:SetColumnID (index)
	return self
end

function self:SetMaximumWidth (maximumWidth)
	self.MaximumWidth = maximumWidth
end

-- Internal, do not call
function self:HookControl (control)
	if not control then return end
	
	control:AddEventListener ("Removed", tostring (self),
		function ()
			self:dtor ()
		end
	)
end

function self:UnhookControl (control)
	if not control then return end
	
	control:RemoveEventListener ("Removed", tostring (self))
end