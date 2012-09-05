local PANEL = {}

function PANEL:Init ()
end

function PANEL:OnSelect (index, value, data)
	self:DispatchEvent ("ItemSelected", value, data)
end

Gooey.Register ("GMultiChoice", PANEL, "DMultiChoice")