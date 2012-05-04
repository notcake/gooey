local PANEL = {}

function PANEL:Init ()
	self.Type = "Text"
end

function PANEL:GetType ()
	return self.Type
end

function PANEL:SetType (type)
	self.Type = type
end

vgui.Register ("GListViewColumn", PANEL, "DListView_Column")