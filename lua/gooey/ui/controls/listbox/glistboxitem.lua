local PANEL = {}

--[[
	Events:
		ListBoxItemChanged (ListBoxItem lastListBoxItem, ListBoxItem listBoxItem)
			Fired when this GListBoxItem's underlying ListBoxItem has changed.
]]

function PANEL:Init ()
	-- ListBox
	self.ListBox     = nil
	self.ListBoxItem = nil
	
	self.TextLabel   = self:Create ("GLabel")
	
	self:AddEventListener ("Click", "GListBoxItem." .. self:GetHashCode (),
		function (_)
			if not self.ListBoxItem then return self end
			
			self.ListBoxItem:DispatchEvent ("Click")
		end
	)
	self:AddEventListener ("PositionChanged", "GListBoxItem." .. self:GetHashCode (),
		function (_, x, y)
			if not self.ListBoxItem then return self end
			
			self.ListBoxItem:DispatchEvent ("PositionChanged", x, y)
		end
	)
	self:AddEventListener ("SizeChanged", "GListBoxItem." .. self:GetHashCode (),
		function (_, x, y)
			if not self.ListBoxItem then return self end
			
			self.ListBoxItem:DispatchEvent ("SizeChanged", x, y)
		end
	)
end

-- ListBox
function PANEL:GetListBox ()
	return self.ListBox
end

function PANEL:SetListBox (listBox)
	self.ListBox = listBox
end

-- ListBoxItem
function PANEL:GetListBoxItem ()
	return self.ListBoxItem
end

function PANEL:SetListBoxItem (listBoxItem)
	if self.ListBoxItem == listBoxItem then return self end
	
	if self.ListBoxItem then
		GLib.UnbindProperty (self,           self.ListBoxItem, "BackgroundColor", self:GetHashCode ())
		GLib.UnbindProperty (self,           self.ListBoxItem, "Height",          self:GetHashCode ())
		GLib.UnbindProperty (self,           self.ListBoxItem, "Visible",         self:GetHashCode ())
		GLib.UnbindProperty (self.TextLabel, self.ListBoxItem, "Font",            self:GetHashCode ())
		GLib.UnbindProperty (self.TextLabel, self.ListBoxItem, "Text",            self:GetHashCode ())
		GLib.UnbindProperty (self.TextLabel, self.ListBoxItem, "TextColor",       self:GetHashCode ())
		
		self.ListBoxItem:RemoveEventListener ("IconChanged", self:GetHashCode ())
		self.ListBoxItem:RemoveEventListener ("IndentChanged", self:GetHashCode ())
	end
	
	local lastListBoxItem = self.ListBoxItem
	self.ListBoxItem = listBoxItem
	
	if self.ListBoxItem then
		GLib.BindProperty (self,           self.ListBoxItem, "BackgroundColor", self:GetHashCode ())
		GLib.BindProperty (self,           self.ListBoxItem, "Height",          self:GetHashCode ())
		GLib.BindProperty (self,           self.ListBoxItem, "Visible",         self:GetHashCode ())
		GLib.BindProperty (self.TextLabel, self.ListBoxItem, "Font",            self:GetHashCode ())
		GLib.BindProperty (self.TextLabel, self.ListBoxItem, "Text",            self:GetHashCode ())
		GLib.BindProperty (self.TextLabel, self.ListBoxItem, "TextColor",       self:GetHashCode ())
		
		self.ListBoxItem:AddEventListener ("IconChanged", self:GetHashCode (),
			function (_)
				self:InvalidateLayout ()
			end
		)
		self.ListBoxItem:AddEventListener ("IndentChanged", self:GetHashCode (),
			function (_)
				self:InvalidateLayout ()
			end
		)
	end
	
	self:OnListBoxItemChanged (lastListBoxItem, listBoxItem)
	self:DispatchEvent ("ListBoxItemChanged", lastListBoxItem, listBoxItem)
	
	return self
end

-- Control
function PANEL:Paint (w, h)
	if not self.ListBoxItem then return end
	
	-- Background
	if self.BackgroundColor then
		surface.SetDrawColor (self.BackgroundColor)
		self:DrawFilledRect ()
	end
	
	local col = self:GetSkin ().combobox_selected
	if self:IsSelected () then
		if not self:GetListBox ():IsFocused () then
			col = GLib.Colors.Silver
		end
		surface.SetDrawColor (col)
		self:DrawFilledRect ()
	elseif self:IsHovered () then
		surface.SetDrawColor (col.r, col.g, col.b, col.a * 0.25)
		self:DrawFilledRect ()
	end
	
	-- Icon
	if self.ListBoxItem:GetIcon () then
		local image = Gooey.ImageCache:GetImage (self.ListBoxItem:GetIcon ())
		local spacing = (self:GetHeight () - image:GetHeight ()) * 0.5
		image:Draw (Gooey.RenderContext, self.ListBoxItem:GetIndent () + 1 + spacing, spacing)
	end
end

function PANEL:PerformLayout (w, h)
	if not self.ListBoxItem then return end
	
	local x = self.ListBoxItem:GetIndent () + 5
	if self.ListBoxItem:GetIcon () then
		x = x + 19
	end
	
	self.TextLabel:SetPos (x, 0)
	self.TextLabel:SetSize (w - x, h)
end

function PANEL:IsSelected ()
	return self.ListBox.SelectionController:IsSelected (self.ListBoxItem)
end

-- Event handlers
function PANEL:DoClick ()
	self.ListBox:DoClick (self)
end

function PANEL:DoRightClick ()
	self.ListBox:DoRightClick (self)
end

function PANEL:OnMousePressed (mouseCode)
	self.ListBox:OnMousePressed (mouseCode)
end

function PANEL:OnMouseReleased (mouseCode)
	self.ListBox:OnMouseReleased (mouseCode)
end

function PANEL:OnRemoved ()
	self:SetListBox (nil)
	self:SetListBoxItem (nil)
end

function PANEL:OnListBoxItemChanged (lastListBoxItem, listBoxItem)
end

-- Internal, do not call

Gooey.Register ("GListBoxItem", PANEL, "GPanel")