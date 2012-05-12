local PANEL = {}

function PANEL:Init ()
	self.ListView = nil

	self.LastClickTime = 0
	self.Disabled = false

	self.Icon = nil
	
	-- Selection
	self.Selectable = true
end

function PANEL:DataLayout (listView)
	self:ApplySchemeSettings ()
	local height = self:GetTall ()
	local x = 0
	local w = listView:ColumnWidth (1)
	local Columns = listView:GetColumns ()
	if self.Icon then
		local image = Gooey.ImageCache:GetImage (self.Icon)
		local spacing = (self:GetTall () - image:GetHeight ()) * 0.5
		x = x + image:GetWidth () + spacing + 1 - 4
		w = w - image:GetWidth () - spacing     + 4
		-- The offset of 4 is to correct for the padding applied to every column text label
	end
	for i = 1, #self.Columns do
		if Columns [i]:GetType () == "Checkbox" then
			self.Columns [i]:SetPos (x + (listView:ColumnWidth (i) - 14) * 0.5, (height - 14) * 0.5)
			self.Columns [i]:SetSize (14, 14)
		else
			self.Columns [i]:SetPos (x + 4, 0)
		end
		if Columns [i]:GetType () == "Text" then
			self.Columns [i]:SetSize (w - 8, height)
			self.Columns [i]:SetContentAlignment (self.ListView:GetColumn (i):GetAlignment ())
		end
		x = x + w
		w = listView:ColumnWidth (i + 1)
	end
end

function PANEL:CanSelect ()
	return self.Selectable
end

function PANEL:GetIcon ()
	return self.Icon
end

function PANEL:GetListView ()
	return self.ListView
end

function PANEL:GetText (i)
	return self.Columns [i or 1]:GetValue ()
end

function PANEL:IsDisabled ()
	return self.Disabled
end

function PANEL:IsSelected ()
	return self.ListView.SelectionController:IsSelected (self)
end

function PANEL:Paint ()
	DListView_Line.Paint (self)
	
	if self.Icon then
		local image = Gooey.ImageCache:GetImage (self.Icon)
		local spacing = (self:GetTall () - image:GetHeight ()) * 0.5
		image:Draw (spacing + 1, spacing)
	end
end

function PANEL:Remove ()
	local listView = self:GetListView ()
	if listView then
		self:SetListView (nil)
		listView:RemoveItem (self)
	end
	_R.Panel.Remove (self)
end

function PANEL:Select ()
	self.ListView.SelectionController:ClearSelection ()
	self.ListView.SelectionController:AddToSelection (self)
end

function PANEL:SetCheckState (columnIdOrIndex, checked)
	if type (columnIdOrIndex) == "string" then columnIdOrIndex = self.ListView:ColumnIndexFromId (columnIdOrIndex) end
	if self.Columns [columnIdOrIndex] then
		self.Columns [columnIdOrIndex]:SetValue (checked)
		return
	end
	self.Columns [columnIdOrIndex] = vgui.Create ("GCheckbox", self)
	if self.Disabled then
		self.Columns [columnIdOrIndex]:SetDisabled (self.Disabled)
	end
	self.Columns [columnIdOrIndex]:SetValue (checked)
	self.Columns [columnIdOrIndex]:AddEventListener ("CheckStateChanged", function (_, checked)
		self.ListView:ItemChecked (self, columnIdOrIndex, checked)
	end)
end

function PANEL:SetDisabled (disabled)
	if disabled == nil then disabled = true end
	self.Disabled = disabled
	for _, columnItem in pairs (self.Columns) do
		if columnItem.SetDisabled then columnItem:SetDisabled (disabled) end
	end
end

function PANEL:SetIcon (icon)
	self.Icon = icon
end

function PANEL:SetCanSelect (canSelect)
	self.Selectable = canSelect
end

function PANEL:SetColumnText (columnIdOrIndex, text)
	if type (columnIdOrIndex) == "string" then columnIdOrIndex = self.ListView:ColumnIndexFromId (columnIdOrIndex) end
	if not self.Columns [columnIdOrIndex] then
		self.Columns [columnIdOrIndex] = vgui.Create ("DListViewLabel", self)
	end
	self.Columns [columnIdOrIndex]:SetText (text)
end

function PANEL:SetListView (listView)
	self.ListView = listView
end

function PANEL:SetText (text)
	self:SetColumnText (1, text)
end

-- Events
function PANEL:DoClick ()
	self.ListView:DoClick (self)
end

function PANEL:DoRightClick ()
	self.ListView:DoRightClick (self)
end

function PANEL:OnMousePressed (mouseCode)
	self.ListView:OnMousePressed (mouseCode)
end

function PANEL:OnMouseReleased (mouseCode)
	self.ListView:OnMouseReleased (mouseCode)
end

vgui.Register ("GListViewItem", PANEL, "DListView_Line")