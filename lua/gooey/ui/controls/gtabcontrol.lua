local PANEL = {}

--[[
	Events:
		SelectedTabChanged (Tab oldSelectedTab, Tab selectedTab)
			Fired when the selected tab has been changed.
		TabAdded (Tab tab)
			Fired when a tab has been added to this TabControl.
		TabCloseRequested (Tab tab)
			Fired when a tab's close button has been clicked.
		TabContentsChanged (Tab tab, Panel contents)
			Fired when a tab's contents have been changed.
		TabRemoved (Tab tab)
			Fired when a tab has been removed from this TabControl.
]]

function PANEL:Init ()
	self.TabHeaderHeight = 24
	
	self.Tabs = {}
	self.TabSet = {}
	self.SelectedTab = nil
	
	self.CloseRequested = function (tab)
		self:DispatchEvent ("TabCloseRequested", tab)
	end
	self.ContentsChanged = function (tab, contents)
		self:DispatchEvent ("TabContentsChanged", tab, contents)
	end
end

function PANEL:AddTab (...)
	local tab = nil
	local text = nil
	local contents = nil
	
	for _, v in ipairs ({...}) do
		if type (v) == "Panel" then
			contents = v
		elseif type (v) == "table" then
			tab = v
		elseif type (v) == "string" then
			text = v
		end
	end
	
	tab = tab or Gooey.Tab ()
	if self.TabSet [tab] then return end
	
	self.Tabs [#self.Tabs + 1] = tab
	self.TabSet [tab] = true
	
	tab:SetTabControl (self)
	if text     then tab:SetText (text)         end
	if contents then tab:SetContents (contents) end
	
	tab:AddEventListener ("CloseRequested",  tostring (self:GetTable ()), self.CloseRequested)
	tab:AddEventListener ("ContentsChanged", tostring (self:GetTable ()), self.ContentsChanged)
	
	if not self:GetSelectedTab () then
		self:SetSelectedTab (tab)
	end
	
	self:InvalidateLayout ()
	
	self:DispatchEvent ("TabAdded", tab)
	
	return tab
end

function PANEL:ContainsTab (tab)
	return self.TabSet [tab] or false
end

function PANEL:GetHeaderHeight ()
	return self.TabHeaderHeight
end

function PANEL:GetSelectedTab ()
	return self.SelectedTab
end

function PANEL:GetTab (index)
	return self.Tabs [index]
end

function PANEL:GetTabCount ()
	return #self.Tabs
end

function PANEL:Paint ()
	local w, h = self:GetSize ()
	draw.RoundedBoxEx (4, 0, self.TabHeaderHeight, w, h - self.TabHeaderHeight, GLib.Colors.Silver, self:GetTabCount () == 0, true, true, true)
end

function PANEL:PerformLayout ()
	local x = 0
	for _, tab in ipairs (self.Tabs) do
		tab:LayoutContents ()
		tab:GetHeader ():SetPos (x, 0)
		tab:GetHeader ():PerformLayout ()
		x = x + tab:GetHeader ():GetWide ()
	end
end

function PANEL:Remove ()
	for _, tab in ipairs (self.Tabs) do
		tab:Remove ()
	end
	
	_R.Panel.Remove (self)
end

function PANEL:RemoveTab (tab, delete)
	if delete == nil then delete = true end
	if not self.TabSet [tab] then return end
	
	local index = 1
	for k, v in ipairs (self.Tabs) do
		if v == tab then
			index = k
			table.remove (self.Tabs, k)
			break
		end
	end
	self.TabSet [tab] = nil
	
	tab:RemoveEventListener ("CloseRequested",  tostring (self:GetTable ()))
	tab:RemoveEventListener ("ContentsChanged", tostring (self:GetTable ()))
	
	if self:GetSelectedTab () == tab then
		self:SetSelectedTab (self.Tabs [index] or self.Tabs [index - 1])
	end
	
	tab:SetTabControl (nil)
	
	self:DispatchEvent ("TabRemoved", tab)
	
	if delete then
		tab:Remove ()
	end
	
	self:InvalidateLayout ()
end

function PANEL:SetSelectedTab (tab)
	if tab and tab:GetTabControl () ~= self then return end
	if self.SelectedTab == tab then return end
	
	local oldSelectedTab = self.SelectedTab
	if self.SelectedTab then
		if self.SelectedTab:GetContents () then
			self.SelectedTab:GetContents ():SetVisible (false)
		end
	end
	self.SelectedTab = tab
	if self.SelectedTab then
		self.SelectedTab:LayoutContents ()
	end
	
	self:DispatchEvent ("SelectedTabChanged", oldSelectedTab, tab)
end

-- Event handlers
PANEL.ContentsChanged = Gooey.NullCallback

Gooey.Register ("GTabControl", PANEL, "GPanel")