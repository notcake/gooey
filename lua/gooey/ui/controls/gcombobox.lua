local PANEL = {}

--[[
	GComboBox
	
	Events:
		SelectedItemChanged (ComboBoxItem lastSelectedItem, ComboBoxItem selectedItem)
			Fired when the selected item has changed.
]]

function PANEL:Init ()
	self.Items = {}
	self.ItemsById = {}
	self.SelectedItem = nil
end

function PANEL:AddItem (text, id)
	local comboBoxItem = Gooey.ComboBoxItem (self, id)
	comboBoxItem:SetText (text)
	
	self.Items [#self.Items + 1] = comboBoxItem
	self.ItemsById [comboBoxItem:GetId ()] = comboBoxItem
	
	self:HookComboBoxItem (comboBoxItem)
	
	self:AddChoice (text, comboBoxItem)
	
	if not self:GetSelectedItem () then
		self:SetSelectedItem (comboBoxItem)
	end
	
	return comboBoxItem
end

function PANEL:Clear ()
	self.Items = {}
	self.ItemsById = {}
	self:SetSelectedItem (nil)
end

function PANEL:GetItemCount ()
	return #self.Items
end

function PANEL:GetSelectedItem ()
	return self.SelectedItem
end

function PANEL:SetSelectedItem (comboBoxItem)
	if self.SelectedItem == comboBoxItem then return self end
	
	local lastSelectedItem = self.SelectedItem
	
	if self.SelectedItem then
		self.SelectedItem:DispatchEvent ("Deselected")
	end
	
	self.SelectedItem = comboBoxItem
	self:SetText (comboBoxItem and comboBoxItem:GetText () or "")
	
	if self.SelectedItem then
		self.SelectedItem:DispatchEvent ("Selected")
	end
	
	self:DispatchEvent ("SelectedItemChanged", lastSelectedItem, self.SelectedItem)
	
	return self
end

function PANEL:OnSelect (index, text, comboBoxItem)
	self:SetSelectedItem (comboBoxItem)
end

-- Hooks
function PANEL:HookComboBoxItem (comboBoxItem)
	if not comboBoxItem then return end
	
	comboBoxItem:AddEventListener ("TextChanged", self:GetHashCode (),
		function ()
			
		end
	)
end

function PANEL:UnhookComboBoxItem (comboBoxItem)
	if not comboBoxItem then return end
	
	comboBoxItem:RemoveEventListener ("TextChanged", self:GetHashCode ())
end

Gooey.Register ("GComboBox", PANEL, "DComboBox")