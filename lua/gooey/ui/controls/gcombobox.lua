local PANEL = {}

--[[
	GComboBox
	
	Events:
		SelectedItemChanged (text, data)
			Fired when the selected item has changed.
]]

function PANEL:Init ()
end

function PANEL:AddItem (text, data)
	self:AddChoice (text, data)
end

function PANEL:OnSelect (index, text, data)
	self:DispatchEvent ("SelectedItemChanged", text, data)
end

Gooey.Register ("GComboBox", PANEL, "DComboBox")