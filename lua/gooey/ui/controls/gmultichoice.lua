local PANEL = {}

function PANEL:Init ()
	Gooey.EventProvider (self)
end

function PANEL:OnSelect (index, value, data)
	self:DispatchEvent ("ItemSelected", value, data)
end

vgui.Register ("GMultiChoice", PANEL, "DMultiChoice")