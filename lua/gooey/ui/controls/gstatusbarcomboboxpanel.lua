local PANEL = {}

function PANEL:Init ()
	self:AddEventListener ("ContentsChanged",
		function (_, oldContents, contents)
			self:UnhookContents (oldContents)
			self:HookContents (contents)
		end
	)
end

-- Internal, do not call
function PANEL:HookContents (contents)
	if not contents then return end
	
	contents:AddEventListener ("MenuOpening", tostring (self:GetTable ()),
		function (_, ...)
			self:DispatchEvent ("MenuOpening", ...)
		end
	)
end

function PANEL:UnhookContents (contents)
	if not contents then return end
	
	contents:RemoveEventListener ("MenuOpening", tostring (self:GetTable ()))
end

Gooey.Register ("GStatusBarComboBoxPanel", PANEL, "GStatusBarPanel")