local PANEL = {}
Gooey.CloseButton = Gooey.MakeConstructor (PANEL, Gooey.VPanel)

function PANEL:ctor (text)
	self:Init ()
end

function PANEL:Init ()
	self.Icon = nil
	self.Text = text
	self:SetWidth (14)
	self:SetHeight (14)
	
	self:SetShouldCaptureMouse (false)
	
	self.Gray707070 = Color (0x70, 0x70, 0x70, 0xFF)
end

local crossPoly1 =
{
	{ x = 0, y = 0 },
	{ x = 2, y = 0 },
	{ x = 8, y = 7 },
	{ x = 8, y = 8 },
	{ x = 7, y = 8 },
	{ x = 0, y = 2 }
}

local crossPoly2 =
{
	{ x = 8, y = 0 },
	{ x = 7, y = 0 },
	{ x = 0, y = 7 },
	{ x = 0, y = 8 },
	{ x = 2, y = 8 },
	{ x = 8, y = 2 }
}

function PANEL:DrawCross (renderContext, x, y, color)
	renderContext:PushRelativeViewPort (x, y)
	
	surface.SetDrawColor (color)
	surface.SetTexture ()
	surface.DrawPoly (crossPoly1)
	surface.DrawPoly (crossPoly2)
	
	renderContext:PopViewPort ()
end

function PANEL:Paint (renderContext)
	if self:IsEnabled () and self:IsHovered () then
		-- Enabled and hovered
		if self:IsPressed () then
			draw.RoundedBox (4, 0, 0, self.Width, self.Height, GLib.Colors.Gray)
			draw.RoundedBox (4, 1, 1, self.Width - 2, self.Height - 2, GLib.Colors.DarkGray)
		else
			draw.RoundedBox (4, 0, 0, self.Width, self.Height, GLib.Colors.Gray)
			draw.RoundedBox (4, 1, 1, self.Width - 2, self.Height - 2, GLib.Colors.LightGray)
		end
	end
	
	if self:IsEnabled () then
		-- Enabled
		if self:IsPressed () then
			self:DrawCross (renderContext, 4, 4, GLib.Colors.Gray)
		elseif self:IsHovered () then
			self:DrawCross (renderContext, 3, 3, GLib.Colors.Gray)
		else
			if self:GetParent () and not self:GetParent ():IsSelected () then
				-- Rendering on an inactive tab header
				self:DrawCross (renderContext, 3, 3, self.Gray707070)
			else
				self:DrawCross (renderContext, 3, 3, GLib.Colors.DarkGray)
			end
		end
	else
		-- Disabled
		self:DrawCross (renderContext, 3, 3, GLib.Colors.Gray)
	end
end