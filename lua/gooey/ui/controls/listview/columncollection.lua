local self = {}
Gooey.ListView.ColumnCollection = Gooey.MakeConstructor (self)

function self:ctor (listView)
	self.ListView = listView
	
	self.ColumnsById = {}
	self.OrderedColumns = {}
end

function self:AddColumn (id)
	if self.ColumnsById [id] then
		return self.ColumnsById [id]
	end
	local column = Gooey.ListView.Column (id)
	self.ColumnsById [id] = column
	self.OrderedColumns [#self.OrderedColumns + 1] = column
	self:HookColumn (column)
	
	column:GetControl ():SetParent (self.ListView)
	
	return column
end

function self:GetColumnById (id)
	return self.ColumnsById [id]
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
	
	column:AddEventListener ("VisibleChanged", tostring (self),
		function (_, visible)
			column:GetControl ():SetVisible (self.ListView:AreColumnHeadersVisible () and column:IsVisible ())
		end
	)
end

function self:UnhookColumn (column)
	if not column then return end
	
	column:RemoveEventListener ("VisibleChanged", tostring (self))
end