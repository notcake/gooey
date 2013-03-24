local PANEL = {}

--[[
	Events:
		HeaderWidthChanged (headerWidth)
			Fired when the header width has changed.
]]

function PANEL:Init ()
	self.Canvas = vgui.Create ("GContainer", self)
	
	self.HeaderWidth = 0
	self.HeaderLayoutValid = true
	self.ScrollableViewController = nil
	
	self.ColumnCollection = nil
	self.SizeGrips = {}
end

function PANEL:GetHeaderWidth ()
	return self.HeaderWidth
end

function PANEL:Paint (w, h)
	surface.SetDrawColor (GLib.Colors.LightGray)
	surface.DrawRect (0, 1, w, h - 1)
	surface.SetDrawColor (GLib.Colors.Gray)
	surface.DrawLine (0, h - 1, w, h - 1)
end

function PANEL:PerformLayout ()
	if not self.HeaderLayoutValid then
		self:LayoutHeaders ()
	end
	self.Canvas:SetPos (-self.ScrollableViewController:GetViewX (), 0)
end

function PANEL:SetColumnCollection (columnCollection)
	if self.ColumnCollection then
		self:UnhookColumnCollection (self.ColumnCollection)
		
		for column in self.ColumnCollection:GetEnumerator () do
			self:OnColumnRemoved (column)
		end
	end
	
	self.ColumnCollection = columnCollection
	
	if self.ColumnCollection then
		self:HookColumnCollection (self.ColumnCollection)
		
		for column in self.ColumnCollection:GetEnumerator () do
			self:OnColumnAdded (column)
		end
	end
end

function PANEL:SetScrollableViewController (scrollableViewController)
	self:UnhookScrollableViewController (self.ScrollableViewController)
	self.ScrollableViewController = scrollableViewController
	self:HookScrollableViewController (self.ScrollableViewController)
end

-- Event handlers
function PANEL:OnRemoved ()
	self:SetColumnCollection (nil)
end

-- Internal, do not call
function PANEL:CreateColumnSizeGrip (column)
	if not self.SizeGrips [column] then
		self.SizeGrips [column] = vgui.Create ("GListViewColumnSizeGrip", self.Canvas)
		self.SizeGrips [column]:SetColumn (column)
	end
	return self.SizeGrips [column]
end

function PANEL:GetColumnSizeGrip (column, create)
	if not self.SizeGrips [column] and create then
		return self:CreateColumnSizeGrip (column)
	end
	return self.SizeGrips [column]
end

function PANEL:InvalidateHeaderLayout ()
	self.HeaderLayoutValid = false
end

function PANEL:LayoutHeaders ()
	local x = 0
	for column in self.ColumnCollection:GetEnumerator () do
		column:GetHeader ():SetPos (x, 0)
		column:GetHeader ():SetTall (self:GetTall ())
		
		local sizeGrip = self:GetColumnSizeGrip (column, column:IsVisible ())
		if sizeGrip then
			sizeGrip:SetVisible (column:IsVisible ())
		end
		if column:IsVisible () then
			x = x + column:GetHeader ():GetWide ()
			sizeGrip:SetPos (x - sizeGrip:GetWide () / 2, 0)
			sizeGrip:SetTall (self:GetTall ())
			x = x - 1
		end
	end
	x = x + 1
	
	self.Canvas:SetPos (-self.ScrollableViewController:GetViewX (), 0)
	self.Canvas:SetSize (math.max (self:GetWide (), x), self:GetTall ())
	
	if self.HeaderWidth ~= x then
		self.HeaderWidth = x
		self:DispatchEvent ("HeaderWidthChanged", self.HeaderWidth)
	end
end

function PANEL:OnColumnAdded (column)
	if not column then return end
	
	column:GetHeader ():SetParent (self.Canvas)
	self:InvalidateHeaderLayout ()
	
	self:HookColumn (column)
end

function PANEL:OnColumnRemoved (column)
	if not column then return end
	
	if self.SizeGrips [column] then
		self.SizeGrips [column]:Remove ()
	end
	self:InvalidateHeaderLayout ()
	
	self:UnhookColumn (column)
end

function PANEL:HookColumnCollection (columnCollection)
	if not columnCollection then return end
	
	columnCollection:AddEventListener ("ColumnAdded", tostring (self:GetTable ()),
		function (_, column)
			self:OnColumnAdded (column)
		end
	)
	
	columnCollection:AddEventListener ("ColumnRemoved", tostring (self:GetTable ()),
		function (_, column)
			self:OnColumnRemoved (column)
		end
	)
end

function PANEL:UnhookColumnCollection (columnCollection)
	if not columnCollection then return end
	
	columnCollection:AddEventListener ("ColumnAdded",   tostring (self:GetTable ()))
	columnCollection:AddEventListener ("ColumnRemoved", tostring (self:GetTable ()))
end

function PANEL:HookColumn (column)
	if not column then return end
	
	column:GetHeader ():AddEventListener ("SizeChanged", tostring (self:GetTable ()),
		function (_)
			self:LayoutHeaders ()
		end
	)
	
	column:GetHeader ():AddEventListener ("VisibleChanged", tostring (self:GetTable ()),
		function (_)
			self:LayoutHeaders ()
		end
	)
end

function PANEL:UnhookColumn (column)
	if not column then return end
	
	column:GetHeader ():RemoveEventListener ("SizeChanged",    tostring (self:GetTable ()))
	column:GetHeader ():RemoveEventListener ("VisibleChanged", tostring (self:GetTable ()))
end

function PANEL:HookScrollableViewController (scrollableViewController)
	if not scrollableViewController then return end
	
	scrollableViewController:AddEventListener ("ViewXChanged", tostring (self:GetTable ()),
		function (_, viewX)
			self:PerformLayout ()
		end
	)
end

function PANEL:UnhookScrollableViewController (scrollableViewController)
	if not scrollableViewController then return end
	
	scrollableViewController:RemoveEventListener ("ViewXChanged", tostring (self:GetTable ()))
end

Gooey.Register ("GListViewHeader", PANEL, "GPanel")