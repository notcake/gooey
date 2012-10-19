local self = {}
Gooey.Clipboard = Gooey.MakeConstructor (self)

function self:ctor ()
	self.ClipboardText = ""
	
	self.ObtainedClipboardText = false
	self.IgnoreTextChange = true
	
	self.ClipboardControllers = Gooey.WeakKeyTable ()
	
	--[[
	timer.Create ("Gooey.Clipboard", 0.5, 0,
		function ()
			if not self or not self.TextEntry or not self.TextEntry:IsValid () then return end
			
			self.ObtainedClipboardText = false
			
			self.IgnoreTextChange = true
			self.TextEntry:SetText ("")
			self.IgnoreTextChange = false
			self.TextEntry:PostMessage ("DoPaste", "", "")
			
			timer.Simple (0.2,
				function ()
					if not self or not self.TextEntry or not self.TextEntry:IsValid () then return end
					
					if not self.ObtainedClipboardText then
						self.TextEntry:OnTextChanged ()
					end
				end
			)
		end
	)
	]]
	
	self:CreateTextEntry ()
	
	Gooey:AddEventListener ("Unloaded", tostring (self),
		function ()
			self:dtor ()
		end
	)
end

function self:dtor ()
	if self.TextEntry and self.TextEntry:IsValid () then
		self.TextEntry:Remove ()
	end
	
	timer.Destroy ("Gooey.Clipboard")
	timer.Destroy ("Gooey.Clipboard.CreateTextEntry")
end

function self:CreateTextEntry ()
	if DTextEntry then
		self.TextEntry = vgui.Create ("DTextEntry")
	end
	
	if not self.TextEntry then
		return timer.Create ("Gooey.Clipboard.CreateTextEntry", 0.5, 1,
			function ()
				self:CreateTextEntry ()
			end
		)
	end
	
	self.TextEntry:SetText ("")
	self.TextEntry:SetVisible (false)
	self.TextEntry.OnTextChanged = function ()
		if self.IgnoreTextChange then return false end
		
		local newClipboardText = self.TextEntry:GetText ()
		if newClipboardText == self.ClipboardText then return end
		
		self.ClipboardText = newClipboardText
		for clipboardController, _ in pairs (self.ClipboardControllers) do
			clipboardController:DispatchEvent ("ClipboardTextChanged", self.ClipboardText)
		end
		
		self.ObtainedClipboardText = true
	end
end

function self:GetText ()
	return self.ClipboardText
end

function self:IsClipboardControllerRegistered (clipboardController)
	return self.ClipboardControllers [clipboardController] or false
end

function self:IsEmpty ()
	return false
	-- return self.ClipboardText == ""
end

function self:RegisterClipboardController (clipboardController)
	self.ClipboardControllers [clipboardController] = true
end

function self:SetText (newClipboardText)
	SetClipboardText (GLib.UTF8.ToLatin1 (newClipboardText))
	
	if self.ClipboardText == newClipboardText then return end
	
	self.ClipboardText = newClipboardText
	for clipboardController, _ in pairs (self.ClipboardControllers) do
		clipboardController:DispatchEvent ("ClipboardTextChanged", self.ClipboardText)
	end
	
	self.ObtainedClipboardText = true
end

function self:UnregisterClipboardController (clipboardController)
	self.ClipboardControllers [clipboardController] = nil
end

Gooey.Clipboard = Gooey.Clipboard ()