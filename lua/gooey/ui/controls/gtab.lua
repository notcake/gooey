local self = {}
Gooey.Tab = Gooey.MakeConstructor (self)

--[[
	Events:
		CloseRequested ()
			Fired when the close button of this tab has been clicked.
		ContentsChanged (Panel oldContents, Panel contents)
			Fired when the content panel of this tab has changed.
		Removed ()
			Fired when this tab has been removed and destroyed.
		TextChanged (text)
			Fired when this tab's header text has changed.
]]

function self:ctor ()
	self.TabControl = nil
	self.Header = vgui.Create ("GTabHeader")
	self.Header:SetTab (self)
	self.Header:SetVisible (false)
	self.Contents = nil
	
	self.ContextMenu = nil
	self.OwnsContextMenu = false
	
	self:SetText ("Tab")
	
	Gooey.EventProvider (self)
end

function self:GetContents ()
	return self.Contents
end

function self:GetContextMenu ()
	return self.ContextMenu
end

function self:GetHeader ()
	return self.Header
end

function self:GetIcon ()
	return self.Header:GetIcon ()
end

function self:GetIndex ()
	return self.Index
end

function self:GetTabControl ()
	return self.TabControl
end

function self:GetText ()
	return self.Header:GetText ()
end

function self:GetToolTipText ()
	return self.Header:GetToolTipText ()
end

function self:IsCloseButtonVisible ()
	return self.Header:IsCloseButtonVisible ()
end

function self:IsSelected ()
	if not self.TabControl then return false end
	return self.TabControl:GetSelectedTab () == self
end

function self:IsVisible ()
	if not self.TabControl then return false end
	return self.TabControl:GetSelectedTab () == self
end

function self:LayoutContents ()
	if not self.Contents then return end
	if self.TabControl then
		self.Contents:SetParent (self.TabControl)
		self.Contents:SetPos (4, self.TabControl:GetHeaderHeight () + 4)
		self.Contents:SetSize (self.TabControl:GetWide () - 8, self.TabControl:GetTall () - self.TabControl:GetHeaderHeight () - 8)
		self.Contents:SetVisible (self:IsSelected ())
	else
		self.Contents:SetVisible (false)
	end
end

function self:Remove ()
	self:SetTabControl (nil)
	if self.Contents then
		self.Contents:Remove ()
	end
	self.Header:Remove ()
	
	if self.ContextMenu then
		if self.OwnsContextMenu then
			self.ContextMenu:Remove ()
		end
		self.ContextMenu = nil
	end
	
	self:DispatchEvent ("Removed")
end

function self:Select ()
	if not self.TabControl then return end
	self.TabControl:SetSelectedTab (self)
end

function self:SetCloseButtonVisible (closeButtonVisible)
	self.Header:SetCloseButtonVisible (closeButtonVisible)
end

function self:SetContents (contents)
	if self.Contents == contents then return end
	
	local oldContents = self.Contents
	self.Contents = contents
	
	self:LayoutContents ()
	
	self:DispatchEvent ("ContentsChanged", oldContents, self.Contents)
end

function self:SetContextMenu (contextMenu, giveOwnership)
	if self.ContextMenu then
		if self.OwnsContextMenu then
			self.ContextMenu:Remove ()
		end
		self.ContextMenu = nil
	end
	self.ContextMenu = contextMenu
	self.OwnsContextMenu = giveOwnership
end

function self:SetIcon (icon)
	self.Header:SetIcon (icon)
end

function self:SetTabControl (tabControl)
	if self.TabControl == tabControl then return end

	local lastTabControl = self.TabControl
	self.TabControl = tabControl
	
	if lastTabControl then
		self.Header:SetVisible (false)
		lastTabControl:RemoveTab (self, false)
	end
	
	if not self.TabControl then return end
	
	self.Header:SetParent (self.TabControl)
	self.Header:SetVisible (true)
	self.Header:SetHeight (self.TabControl:GetHeaderHeight ())
	self:LayoutContents ()
end

function self:SetText (text)
	self.Header:SetText (text)
end

function self:SetToolTipText (text)
	self.Header:SetToolTipText (text)
end