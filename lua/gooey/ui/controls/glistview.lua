local PANEL = {}

--[[
	Events:
		SelectionChanged (item)
			Fired when the selected item has changed.
		SelectionCleared ()
			Fired when the selection has been cleared.
]]

function PANEL:Init ()
	self.SelectionController = Gooey.SelectionController (self)
	
	self.LastClickTime = 0

	self.Menu = nil
	self.ShowIcons = true
	
	self:SetItemHeight (20)
	
	self.ColumnsById = {}
	self.ColumnComparators = {}
	
	self.LastSortedByColumn = false
	self.LastSortColumn = 1
	self.LastSortDescending = false
	
	self.SelectionController:AddEventListener ("SelectionChanged",
		function (_, item)
			self:DispatchEvent ("SelectionChanged", item)
		end
	)
	
	self.SelectionController:AddEventListener ("SelectionCleared",
		function (_, item)
			self:DispatchEvent ("SelectionCleared", item)
		end
	)
	
	self:AddEventListener ("EnabledChanged",
		function (_, enabled)
			for _, line in pairs (self.Lines) do
				line:SetEnabled (enabled)
			end
		end
	)
end

function PANEL:AddColumn (id, material, position)
	local column = nil
	if self.m_bSortable then
		column = vgui.Create ("GListViewColumn", self)
	else
		column = vgui.Create ("DListView_ColumnPlain", self)
	end
	column:SetName (id)
	column:SetMaterial (material)
	column:SetZPos (10)
	
	if iPosition then
	else
		local columnIndex = table.insert (self.Columns, column)
		column:SetIndex (columnIndex)
	end
	column:SetId (id)
	self.ColumnsById [id] = column
	
	self:InvalidateLayout ()
	
	return column
end

function PANEL:AddLine (...)
	self:SetDirty (true)
	self:InvalidateLayout ()

	local line = vgui.Create ("GListViewItem", self.pnlCanvas)
	local id = #self.Lines + 1
	
	self.Lines [id] = line
	line:SetListView (self)
	line:SetID (id)
	line:SetTall (self.ItemHeight)
	line:SetEnabled (self:IsEnabled ())

	local values = {...}
	for k, column in pairs (self.Columns) do
		if column:GetType () == "Text" then
			line:SetColumnText (k, values [k] or "")
		elseif column:GetType () == "Checkbox" then
			line:SetCheckState (k, values [k] or false)
		end
	end
	
	local sortId = #self.Sorted + 1
	self.Sorted [sortId] = line
	if sortId % 2 == 1 then
		line:SetAltLine (true)
	end

	return line
end

function PANEL:ClearSelection ()
	self.SelectionController:ClearSelection ()
end

function PANEL:ColumnIndexFromId (id)
	return self.ColumnsById [id] and self.ColumnsById [id]:GetIndex () or nil
end

function PANEL.DefaultComparator (a, b)
	return a:GetText () < b:GetText ()
end

function PANEL:FindLine (text)
	for _, line in pairs (self.Lines) do
		if line:GetColumnText (1) == text then
			return line
		end
	end
	return nil
end

function PANEL:GetColumnComparator (id)
	return self.ColumnComparators [id] or self.Comparator or self.DefaultComparator
end

function PANEL:GetColumn (columnIdOrIndex)
	return self.ColumnsById [columnIdOrIndex] or self.Columns [columnIdOrIndex]
end

function PANEL:GetColumnHeight ()
	local column = self.Columns [1]
	return column and column:GetTall () or 0
end

function PANEL:GetColumns ()
	return self.Columns
end

function PANEL:GetContentBounds ()
	local scrollbarWidth = 0
	if self.VBar and self.VBar:IsVisible () then
		scrollbarWidth = self.VBar:GetWide ()
	end
	return 1, self:GetColumnHeight (), self:GetWide () - scrollbarWidth, self:GetTall () - 1
end

function PANEL:GetItemEnumerator ()
	local next, tbl, key = pairs (self:GetItems ())
	return function ()
		key = next (tbl, key)
		return tbl [key]
	end
end

function PANEL:GetItemHeight ()
	return self:GetDataHeight ()
end

function PANEL:GetItems ()
	return self.Lines
end

function PANEL:GetSelectedItems ()
	return self.SelectionController:GetSelectedItems ()
end

function PANEL:GetSelectedItem ()
	return self.SelectionController:GetSelectedItem ()
end

function PANEL:GetSelectionEnumerator ()
	return self.SelectionController:GetSelectionEnumerator ()
end

function PANEL:GetSelectionMode ()
	return self.SelectionController:GetSelectionMode ()
end

function PANEL:ItemFromPoint (x, y)
	x, y = self:LocalToScreen (x, y)
	for _, item in pairs (self:GetItems ()) do
		local px, py = item:LocalToScreen (0, 0)
		local w, h = item:GetSize ()
		if px <= x and x < px + w and
			py <= y and y < py + h then
			return item
		end
	end
	return nil
end

function PANEL:PaintOver ()
	self.SelectionController:PaintOver (self)
end

function PANEL:RemoveItem (listViewItem)
	if not listViewItem or not listViewItem:IsValid () then return end
	
	if self.Lines [listViewItem:GetID ()] ~= listViewItem then return end
	local selectedID = self:GetSortedID (listViewItem:GetID ())
	self.Lines [listViewItem:GetID ()] = nil
	table.remove (self.Sorted, selectedID)
	
	self.SelectionController:RemoveFromSelection (listViewItem)

	self:SetDirty (true)
	self:InvalidateLayout ()

	listViewItem:Remove ()
end

function PANEL:RemoveLine (lineId)
	Gooey.DeprecatedFunction ()
end

function PANEL:SetColumnComparator (id, comparator)
	self.ColumnComparators [id] = comparator
end

function PANEL:SetItemHeight (itemHeight)
	self:SetDataHeight (itemHeight)
end

function PANEL:Sort (comparator)
	if not comparator and self.LastSortedByColumn then
		self:SortByColumn (self.LastSortColumn, self.LastSortDescending)
		return
	end

	comparator = comparator or self.Comparator or self.DefaultComparator
	table.sort (self.Sorted,
		function (a, b)
			if a == nil then return false end
			if b == nil then return true end
			return comparator (a, b)
		end
	)
	
	self.LastSortedByColumn = false
	
	self:SetDirty (true)
	self:InvalidateLayout ()
end

function PANEL:SortByColumn (columnIdOrIndex, descending)
	if type (columnIdOrIndex) == "number" then
		columnIdOrIndex = self.Columns [columnIdOrIndex] and self.Columns [columnIdOrIndex]:GetId () or 1
	end
	local comparator = self:GetColumnComparator (columnIdOrIndex)

	table.Copy (self.Sorted, self.Lines)
	table.sort (self.Sorted,
		function (a, b)
			if descending then a, b = b, a end
			return comparator (a, b, descending)
		end
	)
	
	self.LastSortedByColumn = true
	self.LastSortColumn = columnIdOrIndex
	self.LastSortDescending = descending
	
	self:SetDirty (true)
	self:InvalidateLayout ()
end

function PANEL:SetSelectionMode (selectionMode)
	self.SelectionController:SetSelectionMode (selectionMode)
end

-- Event handlers
function PANEL:DoClick ()
	if SysTime () - self.LastClickTime < 0.3 then
		self:DoDoubleClick ()
		self.LastClickTime = 0
	else
		self:DispatchEvent ("Click", self:ItemFromPoint (self:CursorPos ()))
		self.LastClickTime = SysTime ()
	end
end

function PANEL:DoDoubleClick ()
	self:DispatchEvent ("DoubleClick", self:ItemFromPoint (self:CursorPos ()))
end

function PANEL:DoRightClick ()
	self:DispatchEvent ("RightClick", self:ItemFromPoint (self:CursorPos ()))
end

function PANEL:ItemChecked (line, i, checked)
	self:DispatchEvent ("ItemChecked", line, i, checked)
end

function PANEL:OnCursorMoved (x, y)
	self:DispatchEvent ("MouseMove", 0, x, y)
end

function PANEL:OnMousePressed (mouseCode)
	self:DispatchEvent ("MouseDown", mouseCode, self:CursorPos ())
end

function PANEL:OnMouseReleased (mouseCode)
	self:DispatchEvent ("MouseUp", mouseCode, self:CursorPos ())
	if mouseCode == MOUSE_LEFT then
		self:DoClick ()
	elseif mouseCode == MOUSE_RIGHT then
		self:DoRightClick ()
		if self:GetSelectionMode () == Gooey.SelectionMode.Multiple then
			if self.Menu then self.Menu:Open (self:GetSelectedItems ()) end
		else
			if self.Menu then self.Menu:Open (self:GetSelectedItem ()) end
		end
	end
end

function PANEL:OnRemoved ()
	if self.Menu and self.Menu:IsValid () then self.Menu:Remove () end
end

Gooey.Register ("GListView", PANEL, "DListView")