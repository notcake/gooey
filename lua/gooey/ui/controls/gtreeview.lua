local PANEL = {}

--[[
	Events:
		ItemSelected (treeViewNode)
			Fired when the selected tree view node changes.
]]

function PANEL:Init ()
	self.LastClickTime = 0
	
	self.Menu = nil
	self.ChildNodeCount = 0

	self.PopulationMode = "Static"
	self.Populator = nil
	
	self.ShouldSuppressLayout = false
end

function PANEL:AddNode (name)
	local node = vgui.Create ("GTreeViewNode", self)
	
	node:SetId (name)
	node:SetText (name)
	node:SetParentNode (self)
	node:SetRoot (self)
	
	self:AddItem (node)
	self.ChildNodeCount = self.ChildNodeCount + 1
	return node
end

function PANEL.DefaultComparator (a, b)
	return a:GetText () < b:GetText ()
end

function PANEL:FindChild (id)
	for _, item in pairs (self:GetItems ()) do
		if item:GetId () == id then
			return item
		end
	end
	return nil
end

function PANEL:GetChildCount ()
	return self.ChildNodeCount
end

function PANEL:GetComparator ()
	return self.Comparator or self.DefaultComparator
end

function PANEL:GetMenu ()
	return self.Menu
end

function PANEL:GetParentNode ()
	return nil
end

function PANEL:GetPopulator ()
	return self.Populator
end

function PANEL:InvalidateLayout ()
	if not self.ShouldSuppressLayout then _R.Panel.InvalidateLayout (self) end
end

function PANEL:LayoutRecursive ()
	if not self.ShouldSuppressLayout then self:InvalidateLayout () end
end

function PANEL:PerformLayout ()
	if not self.ShouldSuppressLayout then DPanelList.PerformLayout (self) end
end

function PANEL:Remove ()
	if self.Menu and self.Menu:IsValid () then self.Menu:Remove () end
	_R.Panel.Remove (self)
end

function PANEL:RemoveNode (node)
	if not node or not node:IsValid () then return end
	if node:GetParent () ~= self:GetCanvas () then return end

	self:RemoveItem (node)
	self.ChildNodeCount = self.ChildNodeCount - 1
	self:InvalidateLayout ()
end

function PANEL:SetMenu (menu)
	self.Menu = menu
end

function PANEL:SetPopulator (populator)
	self.Populator = populator
end

--[[
	GTreeView:SetSelected (selected)
	
		Do not call this, it's used to simulate the behavious of a GTreeViewNode.
]]
function PANEL:SetSelected (selected)
	if selected then
		self:SetSelectedItem (nil)
	end
end

function PANEL:SetSelectedItem (node)
	if self.m_pSelectedItem == node then return end
	DTree.SetSelectedItem (self, node)
	self:DispatchEvent ("ItemSelected", node)
end

function PANEL:SortChildren (comparator)
	comparator = comparator or self.Comparator or self.DefaultComparator
	table.sort (self:GetItems (),
		function (a, b)
			if a == nil then return false end
			if b == nil then return true end
			return comparator (a, b)
		end
	)
	self:InvalidateLayout ()
end

function PANEL:SuppressLayout (suppress)
	self.ShouldSuppressLayout = suppress
end

-- Event handlers
function PANEL:DoClick (node)
	if SysTime () - self.LastClickTime < 0.3 then
		self:DoDoubleClick (node)
		self.LastClickTime = 0
	else
		self:DispatchEvent ("Click", node)
		self.LastClickTime = SysTime ()
	end
end

function PANEL:DoDoubleClick (node)
	self:DispatchEvent ("DoubleClick", node)
end

function PANEL:DoRightClick (node)
	if self.Menu then
		self.Menu:Open (node)
	end
	self:DispatchEvent ("RightClick", node)
end

function PANEL:OnMouseReleased (mouseCode)
	self:SetSelectedItem (nil)
	if mouseCode == MOUSE_RIGHT then
		self:DoRightClick ()
	end
end

Gooey.Register ("GTreeView", PANEL, "DTree") 