local self = {}

--[[
	Events:
		BorderColorChanged (borderColor)
			Fired when this panel's border color has changed.
]]

function self:Init ()
	self:SetAllowNonAsciiCharacters (true)
	
	self.BorderColor = nil
end

-- Colors
function self:GetBorderColor ()
	return self.BorderColor or GLib.Colors.Black
end

function self:GetDefaultBackgroundColor ()
	return GLib.Colors.White
end

function self:SetBorderColor (borderColor)
	self.BorderColor = borderColor
	self:DispatchEvent ("BorderColorChanged", self.BorderColor)
	return self
end

-- Text
function self:GetText ()
	return debug.getregistry ().Panel.GetText (self)
end

function self:SetText (text)
	if self:GetText () == text then return self end
	
	self.Text = text
	debug.getregistry ().Panel.SetText (self, text)
	
	self:DispatchEvent ("TextChanged", self.Text)
	
	return self
end

function self:Paint (w, h)
	if self.m_bBackground then
		if not self:IsEnabled () then
			self:GetSkin ().tex.TextBox_Disabled (0, 0, w, h, self:GetBackgroundColor ())
		elseif self:IsFocused () then
			self:GetSkin ().tex.TextBox_Focus (0, 0, w, h, self:GetBackgroundColor ())
		else
			self:GetSkin ().tex.TextBox (0, 0, w, h, self:GetBackgroundColor ())
		end
	end
	
	if self.BorderColor then
		surface.SetDrawColor (self.BorderColor)
		surface.DrawOutlinedRect (0, 0, w, h)
	end
	
	self:DrawTextEntryText (self:GetTextColor (), self.m_colHighlight, self.m_colCursor)
end

-- Compatibility with Derma skin's PaintTextEntry
function self:HasFocus ()
	return self:IsFocused ()
end

-- Compatibility with spawn menu hooks
function self:HasParent (control)
	return debug.getregistry ().Panel.HasParent (self, control)
end

-- Event handlers
Gooey.CreateMouseEvents (self)

function self:OnKeyCodePressed (keyCode)
	return self:DispatchKeyboardAction (keyCode) or DTextEntry.OnKeyCodeTyped (self, keyCode)
end
self.OnKeyCodeTyped = self.OnKeyCodePressed

function self:OnTextChanged ()
	self.Text = self:GetText ()
	self:DispatchEvent ("TextChanged", self:GetText ())
end

Gooey.Register ("GTextEntry", self, "DTextEntry") 