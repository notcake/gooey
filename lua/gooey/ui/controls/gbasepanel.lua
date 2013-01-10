local self = {}
Gooey.BasePanel = self

--[[
	Events:
		BackgroundColorChanged (backgroundColor)
			Fired when this panel's background color has changed.
		EnabledChanged (enabled)
			Fired when this panel has been enabled or disabled.
		FontChanged (font)
			Fired when this panel's font has changed.
		ParentChanged (oldParent, parent)
			Fired when this panel's parent has changed.
		PositionChanged (x, y)
			Fired when this panel's position has changed.
		Removed ()
			Fired when this panel has been removed.
		SizeChanged (width, height)
			Fired when this panel's size has changed.
		VisibleChanged (visible)
			Fired when this panel's visibility has changed.
]]

function self:_ctor ()
	if self.BasePanelInitialized then return end
	self.BasePanelInitialized = true

	self.Enabled = true
	self.Pressed = false
	
	self.BackgroundColor = nil
	self.TextColor = nil
	
	self.Font = nil
	
	-- Fade effects
	self.FadingOut = false
	self.FadeEndTime = SysTime ()
	self.FadeDuration = 1
	
	-- ToolTip
	self.ToolTipText = nil
	self.ToolTipController = nil
	
	Gooey.EventProvider (self)
end

function self:CancelFade ()
	self.FadingOut = false
end

function self:Create (class)
	return vgui.Create (class, self)
end

function self:CreateLabel (text)
	local label = vgui.Create ("DLabel", self)
	label:SetText (text)
	return label
end

function self:FadeOut ()
	if not self:IsVisible () then return end
	
	self.FadingOut = true
	self.FadeEndTime = SysTime () + self:GetAlpha () / 255 * self.FadeDuration
	self:FadeThink ()
end

function self:GetBackgroundColor ()
	if not self.BackgroundColor then
		self.BackgroundColor = self.m_Skin.control_color or GLib.Colors.DarkGray
	end
	return self.BackgroundColor
end

function self:GetFont ()
	return self.Font or debug.getregistry ().Panel.GetFont (self)
end

function self:GetTextColor ()
	return self.TextColor or GLib.Colors.Black
end

function self:GetToolTipController ()
	if not self.ToolTipController then
		self.ToolTipController = Gooey.ToolTipController (self)
		self.ToolTipController:SetEnabled (false)
	end
	return self.ToolTipController
end

function self:GetToolTipText ()
	return self.ToolTipText or ""
end

function self:IsEnabled ()
	return self.Enabled
end

function self:IsHovered ()
	return self.Hovered
end

function self:IsPressed ()
	return self.Pressed
end

function self:LocalToParent (x, y)
	return x + self.X, y + self.Y
end

function self:LocalToScreen (x, y)
	local parentX, parentY = self:LocalToParent (x, y)
	if not self:GetParent () then return parentX, parentY end
	return self:GetParent ():LocalToScreen (parentX, parentY)
end

function self:Remove ()
	if self:IsMarkedForDeletion () then return end
	
	if self.OnRemoved then self:OnRemoved () end
	self:DispatchEvent ("Removed")
	
	for _, v in ipairs (self:GetChildren ()) do
		if not v:IsMarkedForDeletion () then
			v:Remove ()
		end
	end
	
	debug.getregistry ().Panel.Remove (self)
end

function self:SetBackgroundColor (color)
	self.BackgroundColor = color
	self:DispatchEvent ("BackgroundColorChanged", self.BackgroundColor)
	return self
end

function self:SetEnabled (enabled)
	if self.Enabled == enabled then return self end
	
	self.Enabled = enabled
	self.m_bDisabled = not enabled -- for DPanel compatibility
	
	self:DispatchEvent ("EnabledChanged", enabled)
	return self
end

function self:SetFont (font)
	if self:GetFont () == font then return end
	
	self.Font = font
	self.m_FontName = font
	debug.getregistry ().Panel.SetFontInternal (self, font)
	self:DispatchEvent ("FontChanged", font)
	return self
end

function self:SetHeight (height)
	if self:GetTall () == height then return end
	
	debug.getregistry ().Panel.SetTall (self, height)
	self:DispatchEvent ("SizeChanged", self:GetWide (), self:GetTall ())
end

function self:SetParent (parent)
	if self:GetParent () == parent then return end
	
	local oldParent = self:GetParent ()
	
	debug.getregistry ().Panel.SetParent (self, parent)
	self:DispatchEvent ("ParentChanged", oldParent, self:GetParent ())
end

function self:SetPos (x, y, ...)
	local currentX, currentY = self:GetPos ()
	if currentX == x and currentY == y then return end
	
	debug.getregistry ().Panel.SetPos (self, x, y)
	self:DispatchEvent ("PositionChanged", x, y)
end

function self:SetSize (width, height, ...)
	if self:GetWide () == width and self:GetTall () == height then return end
	
	debug.getregistry ().Panel.SetSize (self, width, height)
	self:DispatchEvent ("SizeChanged", self:GetWide (), self:GetTall ())
end

self.SetTall = self.SetHeight

function self:SetTextColor (color)
	if self.TextColor == color then return end
	if self.TextColor and
	   self.TextColor.r == color.r and 
	   self.TextColor.g == color.g and 
	   self.TextColor.b == color.b and 
	   self.TextColor.a == color.a then
		return
	end
	self.TextColor = color
	
	if type (color) == "number" then
		Gooey.PrintStackTrace ()
	end
	debug.getregistry ().Panel.SetFGColor (self, color)
	self.m_cTextColor = color -- for DTree_Node compatibility
	self.m_colText    = color -- for DLabel compatibility
	
	DLabel.ApplySchemeSettings (self)
	
	return self
end

function self:SetToolTipText (text)
	if self.ToolTipText == text then return end
	
	self.ToolTipText = text
	if not self.ToolTipController then
		self.ToolTipController = Gooey.ToolTipController (self)
	end
	self.ToolTipController:SetEnabled (self.ToolTipText ~= nil)
end

function self:SetVisible (visible)
	if self:IsVisible () == visible then return end
	
	debug.getregistry ().Panel.SetVisible (self, visible)
	self:DispatchEvent ("VisibleChanged", visible)
end

function self:SetWide (width)
	if self:GetWide () == width then return end
	
	debug.getregistry ().Panel.SetWide (self, width)
	self:DispatchEvent ("SizeChanged", self:GetWide (), self:GetTall ())
end

self.SetWidth = self.SetWide

-- Internal
function self:FadeThink ()
	if not self.FadingOut then return end
	
	local alpha = self:GetFadeAlpha ()
	self:SetAlpha (alpha)
	if alpha == 0 then
		self.FadingOut = false
		self:SetVisible (false)
		self:SetAlpha (255)
		return
	end
	
	timer.Simple (0.001,
		function ()
			if not self or not self:IsValid () then return end
			self:FadeThink ()
		end
	)
end

function self:GetFadeAlpha ()
	local t = (self.FadeEndTime - SysTime ()) / self.FadeDuration
	local alpha = t * 255
	if alpha < 0 then alpha = 0 end
	if alpha > 255 then alpha = 255 end
	return alpha
end

-- Deprecated functions
function self:GetDisabled ()
	return not self:IsEnabled ()
end

function self:IsDisabled ()
	return not self:IsEnabled ()
end

self.GetColor = Gooey.DeprecatedFunction
self.SetColor = Gooey.DeprecatedFunction
self.SetDisabled = Gooey.DeprecatedFunction