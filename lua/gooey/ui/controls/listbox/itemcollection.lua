local self = {}
Gooey.ListBox.ItemCollection = Gooey.MakeConstructor (self)

--[[
	Events:
		Cleared ()
			Fired when this ItemCollection has been cleared.
		ItemAdded (ListBoxItem listBoxItem)
			Fired when a ListBoxItem has been added.
		ItemRemoved (ListBoxItem listBoxItem)
			Fired when a ListBoxItem has been removed.
]]

function self:ctor (listBox)
	self.ListBox = listBox
	
	self.ItemSet      = {}
	self.ItemsById    = {}
	self.OrderedItems = {}
	
	Gooey.EventProvider (self)
end

-- Factories
function self.ListBoxItemFactory (self, listBox, ...)
	return listBox.ListBoxItemFactory (listBox, listBox, ...)
end

-- ListBox
function self:GetListBox ()
	return self.ListBox
end

-- Items
function self:AddItem (id, text)
	local listBoxItem = self.ListBoxItemFactory (self, self:GetListBox ())
	
	text = text or id
	id   = id   or listBoxItem:GetHashCode ()
	text = text or ("ListBoxItem " .. listBoxItem:GetHashCode ())
	
	listBoxItem:SetListBox (self:GetListBox ())
	listBoxItem:SetId (id)
	listBoxItem:SetText (text)
	listBoxItem:SetEnabled (self:GetListBox ():IsEnabled ())
	
	self.ItemSet [listBoxItem] = true
	self.ItemsById [id] = listBoxItem
	self.OrderedItems [#self.OrderedItems + 1] = listBoxItem
	
	self:DispatchEvent ("ItemAdded", listBoxItem)
	
	return listBoxItem
end

function self:Clear ()
	for listboxItem, _ in pairs (self.ItemSet) do
		self.ItemSet [listBoxItem] = nil
		listBoxItem:Remove ()
		self:DispatchEvent ("ItemRemoved", listBoxItem)
	end
	
	self.ItemsById = {}
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

function self:GetItemCount ()
	return #self.OrderedItems
end

function self:RemoveItem (listBoxItem)
	if not listBoxItem then return end
	if self.ItemSet [listBoxItem] then return end
	
	self.ItemSet [listBoxItem] = nil
	if self.ItemsById [listBoxItem:GetId ()] == listBoxItem then
		self.ItemsById [listBoxItem:GetId ()] = nil
	end
	
	table.remove (self.OrderedItems, self:IndexOf (listBoxItem))
	
	listBoxItem:Remove ()
	
	self:DispatchEvent ("ItemRemoved", listBoxItem)
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

function self:IndexOf (listBoxItem)
	for i = 1, #self.OrderedItems do
		if self.OrderedItems [i] == listBoxItem then
			return i
		end
	end
	
	return nil
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