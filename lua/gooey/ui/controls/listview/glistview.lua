local PANEL = {}

--[[
	Events:
		SelectionChanged (item)
			Fired when the selected item has changed.
		SelectionCleared ()
			Fired when the selection has been cleared.
]]

function PANEL:Init ()
	self.LastClickTime = 0

	self.Menu = nil
	
	-- Columns
	self.Columns = Gooey.ListView.ColumnCollection (self)
	self.ColumnComparators = {}
	
	self.Header = vgui.Create ("GListViewHeader", self)
	self.Header:SetColumnCollection (self.Columns)
	self.Header:SetZPos (10)
	
	self.HeaderHeight = 20
	self.HeaderVisible = true
	
	self.Columns:AddEventListener ("ColumnAdded",
		function (_, column)
			self:InvalidateSubItemLayout ()
		end
	)
	
	self.Columns:AddEventListener ("ColumnRemoved",
		function (_, column)
			self:InvalidateSubItemLayout ()
		end
	)
	
	self.Header:AddEventListener ("HeaderWidthChanged",
		function (_, headerWidth)
			self.ScrollableViewController:SetContentWidth (headerWidth + 2)
			self:InvalidateSubItemLayout ()
		end
	)
	
	-- Items
	self.Items = Gooey.ListView.ItemCollection (self)
	self.ItemHeight = 20
	self.ShowIcons = true
	
	self.Items:AddEventListener ("ItemAdded",
		function (_, listViewItem)
			listViewItem:SetParent (self.ItemCanvas)
			self:UpdateContentHeight ()
		end
	)
	
	self.Items:AddEventListener ("ItemRemoved",
		function (_, listViewItem)
			self:UpdateContentHeight ()
			self.SelectionController:RemoveFromSelection (listViewItem)
		end
	)
	
	-- Selection
	self.SelectionController = Gooey.SelectionController (self)
	
	self.SelectionController:AddEventListener ("SelectionChanged",
		function (_, listViewItem)
			self:DispatchEvent ("SelectionChanged", listViewItem)
		end
	)
	
	self.SelectionController:AddEventListener ("SelectionCleared",
		function (_, listViewItem)
			self:DispatchEvent ("SelectionCleared", listViewItem)
		end
	)
	
	-- Layout
	self.SubItemLayoutRevision = 0
	self.VerticalItemLayoutValid = true
	
	-- Scrolling
	self.VScroll = vgui.Create ("GVScrollBar", self)
	self.VScroll:SetZPos (20)
	self.HScroll = vgui.Create ("GHScrollBar", self)
	self.HScroll:SetZPos (20)
	self.ScrollBarCorner = vgui.Create ("GScrollBarCorner", self)
	self.ScrollableViewController = Gooey.ScrollableViewController ()
	self.ScrollableViewController:SetHorizontalScrollBar (self.HScroll)
	self.ScrollableViewController:SetVerticalScrollBar (self.VScroll)
	self.ScrollableViewController:SetScrollBarCorner (self.ScrollBarCorner)
	self.ScrollableViewController:SetViewSize (self:GetSize ())
	
	self.Header:SetScrollableViewController (self.ScrollableViewController)
	
	self.ScrollableViewController:AddEventListener ("ViewXChanged",
		function (_, viewY)
			self:InvalidateVerticalItemLayout ()
		end
	)
	
	self.ScrollableViewController:AddEventListener ("ViewYChanged",
		function (_, viewY)
			self:InvalidateVerticalItemLayout ()
		end
	)
	
	-- Sorting
	self.LastSortedByColumn = false
	self.LastSortColumn = 1
	self.LastSortDescending = false
	
	self:AddEventListener ("EnabledChanged",
		function (_, enabled)
			for listViewItem in self:GetItemEnumerator () do
				listViewItem:SetEnabled (enabled)
			end
		end
	)
	
	self:AddEventListener ("SizeChanged",
		function (_, w, h)
			self.ScrollableViewController:SetViewSize (w, h)
		end
	)
end

-- Control
function PANEL:Paint (w, h)
	return derma.SkinHook ("Paint", "ListView", self, w, h)
end

function PANEL:PaintOver ()
	self.SelectionController:PaintOver (self)
end

function PANEL:PerformLayout ()
	self.Header:SetPos (1, 0)
	self.Header:SetSize (self:GetWide () - 2, self:GetHeaderHeight ())
	
	self.VScroll:SetPos (self:GetWide () - self.VScroll:GetWide (), 0)
	self.VScroll:SetTall (self:GetTall () - (self.HScroll:IsVisible () and self.HScroll:GetTall () or 0))
	self.HScroll:SetPos (0, self:GetTall () - self.HScroll:GetTall (), 0)
	self.HScroll:SetWide (self:GetWide () - (self.VScroll:IsVisible () and self.VScroll:GetWide () or 0))
	self.ScrollBarCorner:SetPos (self:GetWide () - self.ScrollBarCorner:GetWide (), self:GetTall () - self.ScrollBarCorner:GetTall ())
	self.ScrollBarCorner:SetVisible (self.VScroll:IsVisible () and self.HScroll:IsVisible ())
	
	if not self.VerticalItemLayoutValid then
		self.VerticalItemLayoutValid = true
	end
end

-- Columns
function PANEL:AddColumn (id)
	return self.Columns:AddColumn (id)
end

function PANEL:GetColumnComparator (id)
	return self.ColumnComparators [id] or self.Comparator or self.DefaultComparator
end

function PANEL:GetColumnEnumerator ()
	return self.Columns:GetEnumerator ()
end

function PANEL:GetColumn (columnIdOrIndex)
	return self.ColumnsById [columnIdOrIndex] or self.Columns [columnIdOrIndex]
end

function PANEL:GetColumns ()
	return self.Columns
end

function PANEL:GetHeader ()
	return self.Header
end

function PANEL:GetHeaderHeight ()
	return self.HeaderHeight
end

function PANEL:GetHeaderWidth ()
	return self.Header:GetHeaderWidth ()
end

function PANEL:SetHeaderHeight (headerHeight)
	if self.HeaderHeight == headerHeight then return end
	
	self.HeaderHeight = headerHeight
	self:UpdateContentHeight ()
end

-- Items
function PANEL:ClearSelection ()
	self.SelectionController:ClearSelection ()
end

function PANEL.DefaultComparator (a, b)
	return a:GetText () < b:GetText ()
end

function PANEL:FindLine (text)
	for item in self:GetItemEnumerator () do
		if item:GetColumnText (1) == text then
			return item
		end
	end
	return nil
end

function PANEL:GetContentBounds ()
	local scrollbarWidth = 0
	if self.VBar and self.VBar:IsVisible () then
		scrollbarWidth = self.VBar:GetWide ()
	end
	return 1, self:GetHeaderHeight (), self:GetWide () - scrollbarWidth, self:GetTall () - 1
end

function PANEL:GetItemCount ()
	return self.Items:GetItemCount ()
end

function PANEL:GetItemEnumerator ()
	return self.Items:GetEnumerator ()
end

function PANEL:GetItemHeight ()
	return self.ItemHeight
end

function PANEL:GetItems ()
	return self.Items
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
	for item in self:GetItemEnumerator () do
		local px, py = item:LocalToScreen (0, 0)
		local w, h = item:GetSize ()
		if px <= x and x < px + w and
		   py <= y and y < py + h then
			return item
		end
	end
	return nil
end

function PANEL:SetItemHeight (itemHeight)
	if self.ItemHeight == itemHeight then return self end
	
	self.ItemHeight = itemHeight
	self:InvalidateVerticalItemLayout ()
	return self
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

function PANEL:OnRequestResize (sizingColumn, size)
	local rightColumn = nil
	local passed = false
	for _, column in ipairs (self.Columns) do
		if passed then
			rightColumn = column
			break
		end
		
		if sizingColumn == column then passed = true end
	end
	
	if rightColumn then
		local sizeChange = sizingColumn:GetControl ():GetWide () - size
		rightColumn:GetControl ():SetWide (rightColumn:GetControl ():GetWide () + sizeChange )
	end
	
	sizingColumn:GetControl ():SetWide (size)
	self:SetDirty (true)
	
	self:InvalidateLayout ()
end

-- Internal, do not call
function PANEL:InvalidateSubItemLayout ()
	self.SubItemLayoutRevision = self.SubItemLayoutRevision + 1
end

function PANEL:InvalidateVerticalItemLayout ()
	self.VerticalItemLayoutValid = false
	self:InvalidateLayout ()
end

function PANEL:UpdateContentHeight ()
	self.ScrollableViewController:SetContentHeight (self:GetHeaderHeight () + self.Items:GetItemCount () * self:GetItemHeight ())
end

Gooey.Register ("GListViewX", PANEL, "GPanel")