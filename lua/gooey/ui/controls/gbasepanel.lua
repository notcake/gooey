local self = {}
Gooey.BasePanel = self

--[[
	Events:
		EnabledChanged (enabled)
			Fired when this panel has been enabled or disabled.
]]

function self:_ctor ()
	if self.BasePanelInitialized then return end
	self.BasePanelInitialized = true

	self.Enabled = true
	
	self.BackgroundColor = nil
	self.TextColor = nil
	
	Gooey.EventProvider (self)
end

function self:Create (class)
	return vgui.Create (class, self)
end

function self:CreateLabel (text)
	local label = vgui.Create ("DLabel", self)
	label:SetText (text)
	return label
end

function self:GetBackgroundColor ()
	if not self.BackgroundColor then
		self.BackgroundColor = self.m_Skin.control_color or GLib.Colors.DarkGray
	end
	return self.BackgroundColor
end

function self:GetTextColor ()
	return self.TextColor or GLib.Colors.Black
end

function self:IsEnabled ()
	return self.Enabled
end

function self:SetBackgroundColor (color)
	self.BackgroundColor = color
	return self
end

function self:SetEnabled (enabled)
	if self.Enabled == enabled then return self end
	
	self.Enabled = enabled
	self.m_bDisabled = not enabled -- for DPanel compatibility
	
	self:DispatchEvent ("EnabledChanged", enabled)
	return self
end

function self:SetTextColor (color)
	self.TextColor = color
	
	if type (color) == "number" then
		GCompute.PrintStackTrace ()
	end
	_R.Panel.SetFGColor (self, color)
	self.m_cTextColor = color -- for DTree_Node compatibility
	self.m_colText    = color -- for DLabel compatibility
	
	DLabel.ApplySchemeSettings (self)
	
	return self
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