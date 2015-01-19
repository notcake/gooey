local self = {}

function self:Init ()
	self:SetTitle ("Dialog")
	
	self:SetSize (300, 128)
	self:Center ()
	self:SetDeleteOnClose (true)
	self:SetKeyboardInputEnabled (true)
	self:MakePopup ()
	
	self:SetMaximizable (false)
	self:SetSizable (false)
	
	self.Buttons = {}
	self.TextLabel = vgui.Create ("DLabel", self)
	self.TextLabel:SetContentAlignment ("7")
	
	self.Callback = Gooey.NullCallback
	
	self:SetKeyboardMap (Gooey.DialogKeyboardMap)
	
	self:AddEventListener ("TextChanged",
		function (_, text)
			self.TextLabel:SetText (text)
		end
	)
	
	self:AddEventListener ("TextColorChanged",
		function (_, textColor)
			self.TextLabel:SetTextColor (textColor)
		end
	)
	
	Gooey:AddEventListener ("Unloaded", "Gooey.SimpleButtonDialog." .. self:GetHashCode (),
		function ()
			self:Remove ()
		end
	)
end

function self:Close ()
	self:Remove ()
end

function self:AddButton (text)
	local button = vgui.Create ("GButton", self)
	self.Buttons [#self.Buttons + 1] = button
	
	button:SetSize (80, 24)
	button:SetText (text)
	button:AddEventListener ("Click",
		function ()
			self.Callback (text)
			self.Callback = Gooey.NullCallback -- Don't call callback again in PANEL:Remove ()
			self:Remove ()
		end
	)
	
	self:InvalidateLayout ()
end

function self:PerformLayout ()
	DFrame.PerformLayout (self)
	
	if self.Buttons then
		self.TextLabel:SetPos (8, 28)
		self.TextLabel:SetSize (self:GetWide () - 16, self:GetTall ())
	
		local x = self:GetWide ()
		for i = #self.Buttons, 1, -1 do
			x = x - 8 - self.Buttons [i]:GetWide ()
			self.Buttons [i]:SetPos (x, self:GetTall () - self.Buttons [i]:GetTall () - 8)
		end
	end
end

function self:SetCallback (callback)
	self.Callback = callback or Gooey.NullCallback
	return self
end

function self:SetTitle (title)
	DFrame.SetTitle (self, title)
	return self
end

function self:OnRemoved ()
	self.Callback (nil)

	Gooey:RemoveEventListener ("Unloaded", "Gooey.SimpleButtonDialog." .. self:GetHashCode ())
end

Gooey.Register ("GSimpleButtonDialog", self, "GFrame")

local dialogs =
{
	["Empty"           ] = {                            },
	["Ok"              ] = { "OK"                       },
	["OkCancel"        ] = { "OK",             "Cancel" },
	["YesNo"           ] = { "Yes",   "No"              },
	["YesNoCancel"     ] = { "Yes",   "No",    "Cancel" },
	["AbortRetryIgnore"] = { "Abort", "Retry", "Ignore" }
}

for dialogName, dialogButtons in pairs (dialogs) do
	Gooey [dialogName .. "Dialog"] = function (callback)
		if callback ~= nil and
		   not isfunction (callback) then
			Gooey.Error ("Gooey." .. dialogName .. "Dialog: This function takes a callback, not whatever you've given it!")
			callback = nil
		end
		
		callback = callback or Gooey.NullCallback
		
		local dialog = vgui.Create ("GSimpleButtonDialog")
		dialog:SetCallback (callback)
		
		for _, buttonText in ipairs (dialogButtons) do
			dialog:AddButton (buttonText)
		end
		
		return dialog
	end
end