local PANEL = {}

function PANEL:Init ()
	self.Label = vgui.Create ("DLabel", self)
	self.Label:SetTextColor (GLib.Colors.Black)
	
	self.Locked = false
	
	self:SetBackgroundColor (GLib.Colors.Snow)
	
	self:AddEventListener ("VisibleChanged",
		function (_, visible)
			if visible then
				self:Show ()
			end
		end
	)
	
	Gooey:AddEventListener ("Unloaded", tostring (self:GetTable ()),
		function ()
			self:Remove ()
		end
	)
	
	self:SetText ("ToolTip")
end

function PANEL:Free ()
	self.Locked = false
end

function PANEL:GetText ()
	return self.Label:GetText ()
end

function PANEL:IsFree ()
	return not self.Locked
end

function PANEL:IsLocked ()
	return self.Locked
end

function PANEL:Lock ()
	self.Locked = true
end

local borderColor = Color (32, 32, 32, 255)
function PANEL:Paint (w, h)
	draw.RoundedBox (4, 0, 0, w,     h,     borderColor)
	draw.RoundedBox (4, 1, 1, w - 2, h - 2, self:GetBackgroundColor ())
end

function PANEL:PerformLayout ()
	self.Label:SetPos (6, 2)
	
	local w, h = self.Label:GetSize ()
	self:SetSize (w + 12, h + 4)
end

function PANEL:SetText (text)
	self.Label:SetText (text)
	self.Label:SizeToContents ()
	self:InvalidateLayout ()
end

function PANEL:Show ()
	self:SetVisible (true)
	self:MakePopup ()
	self:MoveToFront ()
	self:SetKeyboardInputEnabled (false)
	self:SetMouseInputEnabled (false)
end

-- Event handlers
function PANEL:OnRemoved ()
	Gooey:RemoveEventListener ("Unloaded", tostring (self:GetTable ()))
end

Gooey.Register ("GToolTip", PANEL, "GPanel")