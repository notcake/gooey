local self = {}
Gooey.ComboBoxItem = Gooey.MakeConstructor (self)

--[[
	Events:
		Deselected ()
			Fired when this item has been deselected.
		Selected ()
			Fired when this item has been selected.
		TextChanged (string text)
			Fired when this item's text has changed.
]]

function self:ctor (comboBox, id, text)
	self.ComboBox = comboBox
	self.Id = id
	self.Text = text
	
	Gooey.EventProvider (self)
end

function self:GetComboBox ()
	return self.ComboBox
end

function self:GetId ()
	return self.Id or self:GetHashCode ()
end

function self:GetText ()
	return self.Text
end

function self:Select ()
	self.ComboBox:SetSelectedItem (self)
end

function self:SetId (id)
	self.Id = id
end

function self:SetText (text)
	if self.Text == text then return self end
	
	self.Text = text
	
	self:DispatchEvent ("TextChanged", text)
	
	return self
end