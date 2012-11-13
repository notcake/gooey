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
			else
				Gooey.RemoveRenderHook (Gooey.RenderType.ToolTip, "Gooey.ToolTip." .. tostring (self:GetTable ()))
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

function PANEL:Paint (w, h)
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

local borderColor = Color (32, 32, 32, 255)
function PANEL:Show ()
	self:SetVisible (true)
	self:MakePopup ()
	self:MoveToFront ()
	self:SetKeyboardInputEnabled (false)
	self:SetMouseInputEnabled (false)
	
	Gooey.AddRenderHook (Gooey.RenderType.ToolTip, "Gooey.ToolTip." .. tostring (self:GetTable ()),
		function ()
			local x, y = self:GetPos ()
			local w, h = self:GetSize ()
			draw.RoundedBox (4, x,     y,     w,     h,     borderColor)
			draw.RoundedBox (4, x + 1, y + 1, w - 2, h - 2, self:GetBackgroundColor ())
			self:PaintAt (x, y)
		end
	)
end

-- Event handlers
function PANEL:OnRemoved ()
	Gooey.RemoveRenderHook (Gooey.RenderType.ToolTip, "Gooey.ToolTip." .. tostring (self:GetTable ()))
	Gooey:RemoveEventListener ("Unloaded", tostring (self:GetTable ()))
end

Gooey.Register ("GToolTip", PANEL, "GPanel")