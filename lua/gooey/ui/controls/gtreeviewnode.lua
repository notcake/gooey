local PANEL = {}

function PANEL:Init ()
	self.Id = "Unknown"

	-- Code copied from DTree_Node
	self.Label = vgui.Create ("DTree_Node_Button", self)
	self.Label.DoClick = function () self:InternalDoClick () end
	self.Label.DoRightClick = function () self:InternalDoRightClick () end

	self.Expander = vgui.Create ("DTinyButton", self)
	self.Expander:SetText ("+")
	self.Expander.DoClick = function () self:SetExpanded (not self.m_bExpanded) end
	self.Expander:SetVisible (false)
	
	self.Icon = vgui.Create ("GImage", self)
	
	self:SetTextColor( Color( 0, 0, 0, 255 ) )
	
	self.animSlide = Derma_Anim( "Anim", self, self.AnimSlide )

	self.ChildNodes = nil
	self.ChildNodeCount = 0

	self.Populated = false
	self.ExpandOnPopulate = false
	
	self.ShouldSuppressLayout = false
	self:SetIcon ("gui/g_silkicons/folder")
end

function PANEL:AddNode (name)
	self:CreateChildNodes()
	
	local node = vgui.Create ("GTreeViewNode", self)
	node:SetId (name)
	node:SetText (name)
	node:SetParentNode (self)
	node:SetRoot (self:GetRoot ())
	
	self.ChildNodes:AddItem (node)
	self.ChildNodeCount = self.ChildNodeCount + 1
	self:InvalidateLayout ()
	
	if self.ExpandOnPopulate then
		self.ExpandOnPopulate = false
		self:SetExpanded (true)
	end
	
	self:LayoutRecursive ()
	
	return node
end

function PANEL:Clear ()
	if not self.ChildNodes then return end
	self.ChildNodes:Clear ()
	self.ChildNodeCount = 0
	self:SetExpanded (false)
	self:SetExpandable (false)
	self:MarkUnpopulated ()
	
	self:LayoutRecursive ()
end

function PANEL:ExpandTo (expanded)
	self:SetExpanded (expanded)
	self:GetParentNode():ExpandTo (expanded)
end

function PANEL:FindChild (id)
	if not self.ChildNodes then
		return nil
	end
	for _, item in pairs (self.ChildNodes:GetItems ()) do
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
	return self.Comparator or self.DefaultComparator or self:GetParentNode ():GetComparator ()
end

function PANEL:GetIcon ()
	return self.Icon and self.Icon.ImageName or nil
end

function PANEL:GetId ()
	return self.Id
end

function PANEL:GetText ()
	return self.Label:GetValue ()
end

function PANEL:IsExpandable ()
	return self:HasChildren () or self:GetForceShowExpander ()
end

function PANEL:IsExpanded ()
	return self.m_bExpanded
end

function PANEL:IsPopulated ()
	return self.Populated
end

function PANEL:LayoutRecursive ()
	if not self.ShouldSuppressLayout then
		if self.ChildNodes then
			self.ChildNodes:InvalidateLayout (true)
		end
		self:InvalidateLayout (true)
		self:GetParentNode ():LayoutRecursive ()
	end
end

function PANEL:MarkUnpopulated ()
	self.Populated = false
end

function PANEL:Populate ()
	self.Populated = true
	if self:GetRoot ():GetPopulator () then
		self:GetRoot ():GetPopulator () (self)
	end
end

function PANEL:RemoveNode (node)
	if not self.ChildNodes then return end
	if not node or not node:IsValid () then return end
	if node:GetParent () ~= self.ChildNodes:GetCanvas () then return end
	self.ChildNodes:RemoveItem (node)
	self.ChildNodeCount = self.ChildNodeCount - 1
	if self.ChildNodeCount == 0 then
		self:SetExpandable (false)
	end
	
	self:LayoutRecursive ()
end

function PANEL:Select ()
	self:GetRoot ():SetSelectedItem (self)
	self:SetSelected (true)
end

function PANEL:SetExpandable (expandable)
	self:SetForceShowExpander (expandable)
	self.Expander:SetVisible (self:HasChildren () or expandable)
end

function PANEL:SetExpanded (expanded, suppressAnimation)
	if self:IsExpanded () == expanded then return end
	if expanded and
		not self.Populated and
		self:IsExpandable () then
		self:SetExpandOnPopulate (true)
		self:Populate ()
	end
	if self:IsExpanded () == expanded then return end
	DTree_Node.SetExpanded (self, expanded, suppressAnimation)
end

function PANEL:SetExpandOnPopulate (expand)
	self.ExpandOnPopulate = expand
end

function PANEL:SetIcon (icon)
	self.Icon:SetImage (icon)
end

function PANEL:SetId (id)
	self.Id = id
end

function PANEL:SortChildren (comparator)
	if not self.ChildNodes then return end
	
	comparator = comparator or self:GetComparator ()
	table.sort (self.ChildNodes:GetItems (),
		function (a, b)
			if a == nil then return false end
			if b == nil then return true end
			return comparator (a, b)
		end
	)
	self.ChildNodes:InvalidateLayout ()
end

function PANEL:SuppressLayout (suppress)
	self.ShouldSuppressLayout = suppress
end

-- Event handlers
function PANEL:DoRightClick ()
	self:GetRoot ():SetSelectedItem (self)
end

function PANEL:InternalDoClick ()
	local expanded = self:IsExpanded ()
	self:GetRoot ():SetSelectedItem (self)

	if self:DoClick () then return end
	if self:GetRoot ():DoClick (self) then return end
	
	self:SetExpanded (not expanded)
end

function PANEL:OnRemoved ()	
	-- Remove children first, so selection can bubble up to us.
	if self.ChildNodes then
		for _, item in pairs (self.ChildNodes:GetItems ()) do
			item:Remove ()
		end
	end
	
	-- Now bubble selection upwards.
	if self.Label:GetSelected () then
		self:GetRoot ():SetSelectedItem (self:GetParentNode ())
	end
	self:GetParentNode ():RemoveNode (self)
end

-- Import other functions from DTree_Node
local startTime = SysTime ()
local function TryImport ()
	if not DTree_Node then
		if SysTime () - startTime > 60 then
			Gooey.Register ("GTreeViewNode", PANEL, "GPanel")
			return
		end
		timer.Simple (0.001, TryImport)
		return
	end
	
	for k, v in pairs (DTree_Node) do
		if not PANEL [k] then PANEL [k] = v end
	end
	Gooey.Register ("GTreeViewNode", PANEL, "GPanel")
end
TryImport ()