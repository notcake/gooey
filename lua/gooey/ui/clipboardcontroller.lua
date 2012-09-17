local self = {}
Gooey.ClipboardController = Gooey.MakeConstructor (self, Gooey.ButtonController)

--[[
	Events:
		ClipboardTextChanged (clipboardText)
			Fired when the clipboard text has changed.
		CanCopyChanged (canCopy)
			Fired when the copy command has been enabled or disabled.
		CanCutChanged (canCut)
			Fired when the cut command has been enabled or disabled.
		CanPasteChanged (canPaste)
			Fired when the paste command has been enabled or disabled.
]]

function self:ctor (control)
	self.Control = nil
	
	self:RegisterAction ("Copy",  "CanCopyChanged")
	self:RegisterAction ("Cut",   "CanCutChanged")
	self:RegisterAction ("Paste", "CanPasteChanged")
	
	Gooey.Clipboard:RegisterClipboardController (self)
	self:UpdateButtonState ()
	
	-- Event handlers
	self.SelectionChanged = function ()
		self:UpdateCopyState ()
		self:UpdateCutState ()
	end
	
	self:AddEventListener ("ClipboardTextChanged", tostring (self),
		function ()
			self:UpdateButtonState ()
		end
	)
	
	self:SetControl (control)
end

function self:AddCopyButton (button)
	self:AddButton ("Copy", button)
end

function self:AddCutButton (button)
	self:AddButton ("Cut", button)
end

function self:AddPasteButton (button)
	self:AddButton ("Paste", button)
end

function self:CanCopy ()
	return self:CanPerformAction ("Copy")
end

function self:CanCut ()
	return self:CanPerformAction ("Cut")
end

function self:CanPaste ()
	return self:CanPerformAction ("Paste")
end

function self:GetControl ()
	return self.Control
end

function self:SetControl (control)
	if self.Control then
		self.Control:RemoveEventListener ("SelectionChanged", tostring (self))
	end
	
	self.Control = control
	
	if self.Control then
		self.Control:AddEventListener ("SelectionChanged", tostring (self), self.SelectionChanged)
	end
	
	self:UpdateButtonState ()
end

-- Internal, do not call
function self:UpdateButtonState ()
	self:UpdateCopyState ()
	self:UpdateCutState ()
	self:UpdatePasteState ()
end

function self:UpdateCopyState ()
	self:UpdateActionState ("Copy", self.Control and not self.Control:IsSelectionEmpty () or false)
end

function self:UpdateCutState ()
	self:UpdateActionState ("Cut", self.Control and not self.Control:IsSelectionEmpty () or false)
end

function self:UpdatePasteState ()
	self:UpdateActionState ("Paste", not Gooey.Clipboard:IsEmpty () and self.Control ~= nil)
end

-- Event handlers
self.SelectionChanged = Gooey.NullCallback