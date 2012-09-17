local self = {}
Gooey.UndoRedoController = Gooey.MakeConstructor (self, Gooey.ButtonController)

--[[
	Events:
		CanRedoChanged (canRedo)
			Fired when the redo command has been enabled or disabled.
		CanSaveChanged (canSave)
			Fired when the save command has been enabled or disabled.
		CanUndoChanged (canUndo)
			Fired when the undo command has been enabled or disabled.
]]

function self:ctor (undoRedoStack)
	self.UndoRedoStack = nil
	
	self:RegisterAction ("Redo", "CanRedoChanged")
	self:RegisterAction ("Save", "CanSaveChanged")
	self:RegisterAction ("Undo", "CanUndoChanged")
	
	-- Event handlers
	self.CanSaveChanged = function ()
		self:UpdateSaveState ()
	end
	self.ItemPushed = function ()
		self:UpdateButtonState ()
	end
	self.ItemRedone   = self.ItemPushed
	self.ItemUndone   = self.ItemPushed
	self.Saved        = self.CanSaveChanged
	self.StackCleared = self.ItemPushed
	
	self:SetUndoRedoStack (undoRedoStack)
end

function self:AddRedoButton (button)
	self:AddButton ("Redo", button)
	
	button:AddEventListener ("Click",
		function ()
			if not self.UndoRedoStack then return end
			self.UndoRedoStack:Redo ()
		end
	)
end

function self:AddSaveButton (button)
	self:AddButton ("Save", button)
end

function self:AddUndoButton (button)
	self:AddButton ("Undo", button)
	
	button:AddEventListener ("Click",
		function ()
			if not self.UndoRedoStack then return end
			self.UndoRedoStack:Undo ()
		end
	)
end

function self:CanRedo ()
	return self:CanPerformAction ("Redo")
end

function self:CanSave ()
	return self:CanPerformAction ("Save")
end

function self:CanUndo ()
	return self:CanPerformAction ("Undo")
end

function self:GetUndoRedoStack ()
	return self.UndoRedoStack
end

function self:SetUndoRedoStack (undoRedoStack)
	if self.UndoRedoStack then
		self.UndoRedoStack:RemoveEventListener ("CanSaveChanged", tostring (self))
		self.UndoRedoStack:RemoveEventListener ("ItemPushed",     tostring (self))
		self.UndoRedoStack:RemoveEventListener ("ItemRedone",     tostring (self))
		self.UndoRedoStack:RemoveEventListener ("ItemUndone",     tostring (self))
		self.UndoRedoStack:RemoveEventListener ("Saved",          tostring (self))
		self.UndoRedoStack:RemoveEventListener ("StackCleared",   tostring (self))
	end
	
	self.UndoRedoStack = undoRedoStack
	
	if self.UndoRedoStack then
		self.UndoRedoStack:AddEventListener ("CanSaveChanged", tostring (self), self.CanSaveChanged)
		self.UndoRedoStack:AddEventListener ("ItemPushed",     tostring (self), self.ItemPushed)
		self.UndoRedoStack:AddEventListener ("ItemRedone",     tostring (self), self.ItemRedone)
		self.UndoRedoStack:AddEventListener ("ItemUndone",     tostring (self), self.ItemUndone)
		self.UndoRedoStack:AddEventListener ("Saved",          tostring (self), self.Saved)
		self.UndoRedoStack:AddEventListener ("StackCleared",   tostring (self), self.StackCleared)
	end
	
	self:UpdateButtonState ()
end

-- Internal, do not call
function self:UpdateButtonState ()
	self:UpdateRedoState ()
	self:UpdateSaveState ()
	self:UpdateUndoState ()
end

function self:UpdateRedoState ()
	self:UpdateActionState ("Redo", self.UndoRedoStack and self.UndoRedoStack:CanRedo () or false)
end

function self:UpdateSaveState ()
	self:UpdateActionState ("Save", self.UndoRedoStack and self.UndoRedoStack:CanSave () or false)
end

function self:UpdateUndoState ()
	self:UpdateActionState ("Undo", self.UndoRedoStack and self.UndoRedoStack:CanUndo () or false)
end

-- Event handlers
self.ItemPushed   = Gooey.NullCallback
self.ItemRedone   = Gooey.NullCallback
self.ItemUndone   = Gooey.NullCallback
self.Saved        = Gooey.NullCallback
self.StackCleared = Gooey.NullCallback