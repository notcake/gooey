local self = {}
Gooey.ListView.ColumnCollection = Gooey.MakeConstructor (self)

--[[
	Events:
		ColumnAdded (Column column)
			Fired when a column has been added to this ColumnCollection.
]]

function self:ctor (listView)
	self.ListView = listView
	
	self.ColumnsById = {}
	self.OrderedColumns = {}
	
	Gooey.EventProvider (self)
end

function self:AddColumn (id)
	if self.ColumnsById [id] then
		return self.ColumnsById [id]
	end
	
	local column = Gooey.ListView.Column (self, id)
	self.ColumnsById [id] = column
	self.OrderedColumns [#self.OrderedColumns + 1] = column
	column:SetIndex (#self.OrderedColumns)
	self:HookColumn (column)
	
	self:DispatchEvent ("ColumnAdded", column)
	return column
end

function self:GetColumn (index)
	return self.OrderedColumns [index]
end

function self:GetColumnById (id)
	return self.ColumnsById [id]
end

function self:GetColumnCount ()
	return #self.OrderedColumns
end

function self:GetEnumerator ()
	local i = 0
	return function ()
		i = i + 1
		return self.OrderedColumns [i]
	end
end

function self:GetListView ()
	return self.ListView
end

-- Internal, do not call
function self:HookColumn (column)
	if not column then return end
end

function self:UnhookColumn (column)
	if not column then return end
end