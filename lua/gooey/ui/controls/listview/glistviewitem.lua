local PANEL = {}

function PANEL:Init ()
	self.ListView = nil
	
	self.LastClickTime = 0

	self.Icon = nil
	
	-- Selection
	self.Selectable = true
	
	self:AddEventListener ("EnabledChanged",
		function (_, enabled)
			for _, columnItem in pairs (self.Columns) do
				if columnItem.SetEnabled == Gooey.BasePanel.SetEnabled then columnItem:SetEnabled (enabled)
				elseif columnItem.SetDisabled then columnItem:SetDisabled (not enabled) end
			end
		end
	)
	
	self:AddEventListener ("TextChanged",
		function (_, text)
			self:SetColumnText (1, text)
		end
	)
end

function PANEL:DataLayout (listView)
	self:ApplySchemeSettings ()
	local height = self:GetTall ()
	local x = 0
	local w = listView:GetColumnWidth (1)
	local columns = listView:GetColumns ()
	if self.Icon then
		local image = Gooey.ImageCache:GetImage (self.Icon)
		local spacing = (self:GetTall () - image:GetHeight ()) * 0.5
		x = x + image:GetWidth () + spacing + 1 - 4
		w = w - image:GetWidth () - spacing     + 4
		-- The offset of 4 is to correct for the padding applied to every column text label
	end
	for i = 1, #self.Columns do
		if columns [i]:GetType () == Gooey.ListView.ColumnType.Checkbox then
			self.Columns [i]:SetPos (x + (listView:GetColumnWidth (i) - 15) * 0.5, (height - 15) * 0.5)
			self.Columns [i]:SetSize (15, 15)
		else
			self.Columns [i]:SetPos (x + 4, 0)
		end
		if columns [i]:GetType () == Gooey.ListView.ColumnType.Text then
			self.Columns [i]:SetSize (w - 8, height)
			self.Columns [i]:SetContentAlignment (self.ListView:GetColumn (i):GetAlignment ())
		end
		self.Columns [i]:SetVisible (columns [i]:GetControl ():IsVisible ())
		if columns [i]:GetControl ():IsVisible () then
			x = x + w
		end
		w = listView:GetColumnWidth (i + 1)
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
	return self.Columns [i or 1] and self.Columns [i or 1]:GetValue () or ""
end

function PANEL:IsHovered ()
	if not self.Hovered then return false end
	
	local mouseX, mouseY = self:CursorPos ()
	return mouseX >= 0 and mouseX < self:GetWide () and
	       mouseY >= 0 and mouseY < self:GetTall ()
end

function PANEL:IsSelected ()
	return self.ListView.SelectionController:IsSelected (self)
end

function PANEL:Paint (w, h)
	if self.BackgroundColor then
		surface.SetDrawColor (self.BackgroundColor)
		self:DrawFilledRect ()
	end
	
	if self:IsSelected () then
		local col = self:GetSkin ().combobox_selected
		surface.SetDrawColor (col.r, col.g, col.b, col.a)
		self:DrawFilledRect ()
	elseif self:IsHovered () then
		local col = self:GetSkin ().combobox_selected
		surface.SetDrawColor (col.r, col.g, col.b, col.a * 0.25)
		self:DrawFilledRect ()
	end
	
	if self.Icon then
		local image = Gooey.ImageCache:GetImage (self.Icon)
		local spacing = (self:GetTall () - image:GetHeight ()) * 0.5
		image:Draw (Gooey.RenderContext, spacing + 1, spacing)
	end
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
	self.Columns [columnIdOrIndex]:SetEnabled (self:IsEnabled ())
	self.Columns [columnIdOrIndex]:SetValue (checked)
	self.Columns [columnIdOrIndex]:AddEventListener ("CheckStateChanged",
		function (_, checked)
			self.ListView:ItemChecked (self, columnIdOrIndex, checked)
		end
	)
end

function PANEL:SetIcon (icon)
	self.Icon = icon
end

function PANEL:SetCanSelect (canSelect)
	self.Selectable = canSelect
end

function PANEL:SetColumnText (columnIdOrIndex, text)
	local columnIndex = columnIdOrIndex
	if type (columnIdOrIndex) == "string" then columnIndex = self.ListView:ColumnIndexFromId (columnIdOrIndex) end
	if not columnIndex then error ("GListViewItem:SetColumnText : " .. tostring (columnIdOrIndex) .. " is not a valid column id.\n") end
	
	if not self.Columns [columnIndex] then
		self.Columns [columnIndex] = vgui.Create ("DListViewLabel", self)
	end
	self.Columns [columnIndex]:SetText (text)
end

function PANEL:SetListView (listView)
	self.ListView = listView
end

-- Event handlers
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

function PANEL:OnRemoved ()
	local listView = self:GetListView ()
	if listView then
		self:SetListView (nil)
		listView:RemoveItem (self)
	end
end

Gooey.Register ("GListViewItemX", PANEL, "DListView_Line")