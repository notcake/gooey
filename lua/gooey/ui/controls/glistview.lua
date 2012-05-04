local PANEL = {}

function PANEL:Init ()
	self.Disabled = false

	self.Menu = nil
	self.ShowIcons = true
	
	self:SetItemHeight (20)
	
	Gooey.EventProvider (self)
end

function PANEL:AddColumn (name, material, position)
	local column = nil
	if self.m_bSortable then
		column = vgui.Create ("GListViewColumn", self)
	else
		column = vgui.Create ("DListView_ColumnPlain", self)
	end
	column:SetName (name)
	column:SetMaterial (material)
	column:SetZPos (10)
	
	if iPosition then
	else
		local ID = table.insert (self.Columns, column)
		column:SetColumnID(ID)
	end
	
	self:InvalidateLayout ()
	
	return column
end

function PANEL:AddLine (...)
	self:SetDirty (true)
	self:InvalidateLayout ()

	local line = vgui.Create ("GListViewItem", self.pnlCanvas)
	self.Lines [#self.Lines + 1] = line
	local id = #self.Lines

	line:SetListView (self)
	line:SetID (id)
	line:SetTall (self.ItemHeight)
	if self.Disabled then
		line:SetDisabled (self.Disabled)
	end

	local values = {...}
	for k, column in pairs (self.Columns) do
		if column:GetType () == "Text" then
			line:SetColumnText (k, values [k] or "")
		elseif column:GetType () == "Checkbox" then
			line:SetCheckState (k, values [k] or false)
		end
	end
	
	self.Sorted [#self.Sorted + 1] = line
	local sortID = #self.Sorted
	if sortID % 2 == 1 then
		line:SetAltLine (true)
	end

	return line
end

function PANEL:FindLine (text)
	for _, line in pairs (self.Lines) do
		if line:GetColumnText (1) == text then
			return line
		end
	end
	return nil
end

function PANEL:GetColumns ()
	return self.Columns
end

function PANEL:GetItemHeight ()
	return self:GetDataHeight ()
end

function PANEL:GetItems ()
	return self.Lines
end

function PANEL:GetSelectedItems ()
	local items = {}
	for _, line in pairs (self.Lines) do
		if line:GetSelected () then
			items [#items + 1] = line
		end
	end
	return items
end

function PANEL:IsDisabled ()
	return self.Disabled
end

function PANEL:SetDisabled (disabled)
	if disabled == nil then
		disabled = true
	end
	self.Disabled = disabled
	for _, Line in pairs (self.Lines) do
		Line:SetDisabled (disabled)
	end
end

function PANEL:Remove ()
	if self.Menu and
		self.Menu:IsValid () then
		self.Menu:Remove ()
	end
	_R.Panel.Remove (self)
end

function PANEL:SetItemHeight (itemHeight)
	self:SetDataHeight (itemHeight)
end

local function defaultComparator (a, b)
	return a:GetText () < b:GetText ()
end

function PANEL:Sort (comparator)
	comparator = comparator or defaultComparator

	table.sort (self.Sorted, comparator)
	
	self:SetDirty (true)
	self:InvalidateLayout ()
end

-- Events
function PANEL:DoDoubleClick (_, item)
	self:DispatchEvent ("DoubleClick", item)
end

function PANEL:DoRightClick (item)
	if self.Menu then
		self.Menu:Open (item)
	end
	self:DispatchEvent ("RightClick", item)
end

function PANEL:ItemChecked (line, i, checked)
	self:DispatchEvent ("ItemChecked", line, i, checked)
end

function PANEL:OnMouseReleased (mouseCode)
	self:ClearSelection ()
	if mouseCode == MOUSE_RIGHT then
		self:DoRightClick ()
	end
	if mouseCode == MOUSE_LEFT then
	end
end

vgui.Register ("GListView", PANEL, "DListView")