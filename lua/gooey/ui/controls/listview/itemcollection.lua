local self = {}
Gooey.ListView.ItemCollection = Gooey.MakeConstructor (self)

--[[
	Events:
		Cleared ()
			Fired when this ItemCollection has been cleared.
		ItemAdded (GListViewItem listViewItem)
			Fired when a ListViewItem has been added.
		ItemRemoved (GListViewItem listViewItem)
			Fired when a ListViewItem has been removed.
]]

function self:ctor (listView)
	self.ListView = listView
	
	self.ItemsById = {}
	self.OrderedItems = {}
	
	Gooey.EventProvider (self)
end

function self:AddItem (...)
	local listViewItem = vgui.Create ("GListViewItem", self:GetListView ())
	local id = #self.ItemsById + 1
	listViewItem:SetListView (self:GetListView ())
	listViewItem:SetId (id)
	listViewItem:SetEnabled (self:GetListView ():IsEnabled ())
	
	local values = {...}
	for i = 1, self:GetListView ():GetColumns ():GetColumnCount () do
		local column = self:GetListView ():GetColumns ():GetColumn (i)
		if column:GetType () == Gooey.ListView.ColumnType.Text then
			listViewItem:SetColumnText (column:GetId (), tostring (values [i] or ""))
		elseif column:GetType () == Gooey.ListView.ColumnType.Checkbox then
			listViewItem:SetCheckState (column:GetId (), values [i] and true or false)
		end
	end
	
	self.ItemsById [id] = listViewItem
	self.OrderedItems [#self.OrderedItems + 1] = listViewItem
	
	self:DispatchEvent ("ItemAdded", listViewItem)
	
	return listViewItem
end

function self:Clear ()
	for id, listViewItem in pairs (self.ItemsById) do
		self.ItemsById [id] = nil
		listViewItem:Remove ()
		self:DispatchEvent ("ItemRemoved", listViewItem)
	end
	
	self.OrderedItems = {}
	
	self:DispatchEvent ("Cleared")
end

function self:GetEnumerator ()
	return GLib.ArrayEnumerator (self.OrderedItems)
end

function self:GetItem (index)
	return self.OrderedItems [index]
end

function self:GetItemById (id)
	return self.ItemsById [id]
end

function self:GetItemBySortedIndex (index)
	return self.OrderedItems [index]
end

function self:GetItemCount ()
	return #self.OrderedItems
end

function self:GetListView ()
	return self.ListView
end

function self:IsEmpty ()
	return #self.OrderedItems == 0
end

function self:RemoveItem (listViewItem)
	listViewItem = self.ItemsById [listViewItem] or listViewItem
	
	if not listViewItem then return end
	if not listViewItem:IsValid () then return end
	if self.ItemsById [listViewItem:GetId ()] ~= listViewItem then return end
	
	self.ItemsById [listViewItem:GetId ()] = nil
	
	table.remove (self.OrderedItems, self:IndexOf (listViewItem))
	
	listViewItem:Remove ()
	
	self:DispatchEvent ("ItemRemoved", listViewItem)
end

-- Search
function self:BinarySearch (director)
	local minIndex = 0
	local maxIndex = #self.OrderedItems + 1
	
	while maxIndex - minIndex > 1 do
		local midIndex = math.floor ((maxIndex + minIndex) * 0.5)
		
		local direction = director (self.OrderedItems [midIndex])
		if direction < 0 then
			maxIndex = midIndex
		elseif direction > 0 then
			minIndex = midIndex
		else
			return true, midIndex, self.OrderedItems [midIndex]
		end
	end
	
	return false, minIndex, self.OrderedItems [minIndex]
end

function self:IndexOf (listViewItem)
	for i = 1, #self.OrderedItems do
		if self.OrderedItems [i] == listViewItem then
			return i
		end
	end
	
	return nil
end

function self:SortedIndexOf (listBoxItem)
	return self:IndexOf (listBoxItem)
end

function self:Sort (comparator, sortOrder)
	if not comparator then return end
	sortOrder = sortOrder or Gooey.SortOrder.Ascending
	
	if sortOrder == Gooey.SortOrder.Ascending then
		table.sort (self.OrderedItems, comparator)
	elseif sortOrder == Gooey.SortOrder.Descending then
		table.sort (self.OrderedItems,
			function (a, b)
				return comparator (b, a)
			end
		)
	end
end