local PANEL = {}

--[[
	Events:
		SelectedContentsChanged (Tab oldSelectedTab, Panel oldSelectedContents, Tab selectedTab, Panel selectedContents)
			Fired when the selected contents has changed.
		SelectedTabChanged (Tab oldSelectedTab, Tab selectedTab)
			Fired when the selected tab has changed.
		TabAdded (Tab tab)
			Fired when a tab has been added to this TabControl.
		TabCloseRequested (Tab tab)
			Fired when a tab's close button has been clicked.
		TabContentsChanged (Tab tab, Panel oldContents, Panel contents)
			Fired when a tab's contents has changed.
		TabRemoved (Tab tab)
			Fired when a tab has been removed from this TabControl.
		TabTextChanged (Tab tab, text)
			Fired when a tab's header text has changed.
]]

function PANEL:Init ()
	self.TabHeaderHeight = 24
	
	self.Tabs = {}
	self.TabSet = {}
	self.SelectedTab = nil
	
	self.CloseRequested = function (tab)
		self:DispatchEvent ("TabCloseRequested", tab)
	end
	self.ContentsChanged = function (tab, oldContents, contents)
		self:DispatchEvent ("TabContentsChanged", tab, oldContents, contents)
		
		if tab:IsSelected () then
			self:DispatchEvent ("SelectedContentsChanged", tab, oldContents, tab, contents)
		end
	end
	self.TextChanged = function (tab, text)
		self:DispatchEvent ("TabTextChanged", tab, text)
		self:InvalidateLayout ()
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
	tab:AddEventListener ("TextChanged",     tostring (self:GetTable ()), self.TextChanged)
	
	if not self:GetSelectedTab () then
		self:SetSelectedTab (tab)
	end
	
	self:InvalidateLayout ()
	
	self:DispatchEvent ("TabAdded", tab)
	
	return tab
end

function PANEL:Clear ()
	local tabs = {}
	for tab in self:GetEnumerator () do
		tabs [#tabs + 1] = tab
	end
	for _, tab in ipairs (tabs) do
		tab:Remove ()
	end
end

function PANEL:ContainsTab (tab)
	return self.TabSet [tab] or false
end

function PANEL:GetEnumerator ()
	local i = 0
	return function ()
		i = i + 1
		return self.Tabs [i]
	end
end

function PANEL:GetHeaderHeight ()
	return self.TabHeaderHeight
end

function PANEL:GetSelectedContents ()
	if not self.SelectedTab then return nil end
	if not self.SelectedTab:GetContents () then return nil end
	if not self.SelectedTab:GetContents ():IsValid () then return nil end
	return self.SelectedTab:GetContents ()
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
	tab:RemoveEventListener ("TextChanged",     tostring (self:GetTable ()))
	
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
	local oldSelectedContents = nil
	if self.SelectedTab then
		oldSelectedContents = self.SelectedTab:GetContents ()
		if oldSelectedContents then
			oldSelectedContents:SetVisible (false)
		end
	end
	
	self.SelectedTab = tab
	
	local selectedContents = nil
	if self.SelectedTab then
		selectedContents = self.SelectedTab:GetContents ()
		self.SelectedTab:LayoutContents ()
	end
	
	self:DispatchEvent ("SelectedTabChanged", oldSelectedTab, tab)
	if oldSelectedContents ~= selectedContents then
		self:DispatchEvent ("SelectedContentsChanged", oldSelectedTab, oldSelectedContents, tab, selectedContents)
	end
end

function PANEL:OnRemoved ()
	for _, tab in ipairs (self.Tabs) do
		tab:Remove ()
	end
end

-- Event handlers
PANEL.ContentsChanged = Gooey.NullCallback

Gooey.Register ("GTabControl", PANEL, "GPanel")