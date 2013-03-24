local self = {}
Gooey.ScrollableViewController = Gooey.MakeConstructor (self)

--[[
	Events:
		ContentHeightChanged (contentHeight)
			Fired when the content height has changed.
		ContentWidthChanged (contentWidth)
			Fired when the content width has changed.
		ContentSizeChanged (contentWidth, contentHeight)
			Fired when the content size has changed.
		ViewHeightChanged (viewHeight)
			Fired when the view height has changed.
		ViewPositionChanged (viewX, viewY)
			Fired when the view position has changed.
		ViewSizeChanged (viewWidth, viewHeight)
			Fired when the view size has changed.
		ViewWidthChanged (viewWidth)
			Fired when the view width has changed.
		ViewXChanged (viewX)
			Fired when the view x-coordinate has changed.
		ViewYChanged (viewY)
			Fired when the view y-coordinate has changed.
]]

function self:ctor ()
	self.ContentWidth  = 0
	self.ContentHeight = 0
	
	self.ViewWidth  = 0
	self.ViewHeight = 0
	
	self.ViewX = 0
	self.ViewY = 0
	
	self.VerticalScrollBar   = nil
	self.HorizontalScrollBar = nil
	self.ScrollBarCorner     = nil
	
	Gooey.EventProvider (self)
end

function self:dtor ()
end

function self:GetContentHeight ()
	return self.ContentHeight
end

function self:GetContentWidth ()
	return self.ContentWidth
end

function self:GetHorizontalScrollBar ()
	return self.HorizontalScrollBar
end

function self:GetScrollBarCorner ()
	return self.ScrollBarCorner
end

function self:GetVerticalScrollBar ()
	return self.VerticalScrollBar
end

function self:GetViewHeight ()
	return self.ViewHeight
end

function self:GetViewWidth ()
	return self.ViewWidth
end

function self:GetViewX ()
	return self.ViewX
end

function self:GetViewY ()
	return self.ViewY
end

function self:SetContentHeight (contentHeight)
	if self.ContentHeight == contentHeight then return self end
	
	self.ContentHeight = contentHeight
	
	if self.VerticalScrollBar then
		self.VerticalScrollBar:SetContentSize (self.ContentHeight)
		self.VerticalScrollBar:SetVisible (self.VerticalScrollBar:IsEnabled ())
	end
	
	self:DispatchEvent ("ContentHeightChanged", self.ContentHeight)
	self:DispatchEvent ("ContentSizeChanged", self.ContentWidth, self.ContentHeight)
	return self
end

function self:SetContentSize (contentWidth, contentHeight)
	if self.ContentWidth  == contentWidth and
	   self.ContentHeight == contentHeight then
		return
	end
	
	self.ContentWidth  = contentWidth
	self.ContentHeight = contentHeight
	
	if self.HorizontalScrollBar then
		self.HorizontalScrollBar:SetContentSize (self.ContentWidth)
		self.HorizontalScrollBar:SetVisible (self.HorizontalScrollBar:IsEnabled ())
	end
	if self.VerticalScrollBar then
		self.VerticalScrollBar:SetContentSize (self.ContentHeight)
		self.VerticalScrollBar:SetVisible (self.VerticalScrollBar:IsEnabled ())
	end
	
	self:DispatchEvent ("ContentWidthChanged", self.ContentWidth)
	self:DispatchEvent ("ContentHeightChanged", self.ContentHeight)
	self:DispatchEvent ("ContentSizeChanged", self.ContentWidth, self.ContentHeight)
end

function self:SetContentWidth (contentWidth)
	if self.ContentWidth == contentWidth then return self end
	
	self.ContentWidth = contentWidth
	
	if self.HorizontalScrollBar then
		self.HorizontalScrollBar:SetContentSize (self.ContentWidth)
		self.HorizontalScrollBar:SetVisible (self.HorizontalScrollBar:IsEnabled ())
	end
	
	self:DispatchEvent ("ContentWidthChanged", self.ContentWidth)
	self:DispatchEvent ("ContentSizeChanged", self.ContentWidth, self.ContentHeight)
	return self
end

function self:SetViewHeight (viewHeight)
	if self.ViewHeight == viewHeight then return self end
	
	self.ViewHeight = viewHeight
	
	if self.VerticalScrollBar then
		self.VerticalScrollBar:SetViewSize (self.ViewHeight)
		self.VerticalScrollBar:SetVisible (self.VerticalScrollBar:IsEnabled ())
	end
	
	self:DispatchEvent ("ViewHeightChanged", self.ViewHeight)
	self:DispatchEvent ("ViewSizeChanged", self.ViewWidth, self.ViewHeight)
	return self
end

function self:SetViewSize (viewWidth, viewHeight)
	if self.ViewWidth  == viewWidth and
	   self.ViewHeight == viewHeight then
		return
	end
	
	self.ViewWidth  = viewWidth
	self.ViewHeight = viewHeight
	
	if self.HorizontalScrollBar then
		self.HorizontalScrollBar:SetViewSize (self.ViewWidth)
		self.HorizontalScrollBar:SetVisible (self.HorizontalScrollBar:IsEnabled ())
	end
	if self.VerticalScrollBar then
		self.VerticalScrollBar:SetViewSize (self.ViewHeight)
	end
	
	self:DispatchEvent ("ViewWidthChanged", self.ViewWidth)
	self:DispatchEvent ("ViewHeightChanged", self.ViewHeight)
	self:DispatchEvent ("ViewSizeChanged", self.ViewWidth, self.ViewHeight)
end

function self:SetViewWidth (viewWidth)
	if self.ViewWidth == viewWidth then return self end
	
	self.ViewWidth = viewWidth
	
	if self.HorizontalScrollBar then
		self.HorizontalScrollBar:SetViewSize (self.ViewWidth)
		self.HorizontalScrollBar:SetVisible (self.HorizontalScrollBar:IsEnabled ())
	end
	
	self:DispatchEvent ("ViewWidthChanged", self.ViewWidth)
	self:DispatchEvent ("ViewSizeChanged", self.ViewWidth, self.ViewHeight)
	return self
end

function self:SetHorizontalScrollBar (horizontalScrollBar)
	self:UnhookHorizontalScrollBar (self.HorizontalScrollBar)
	self.HorizontalScrollBar = horizontalScrollBar
	
	if self.HorizontalScrollBar then
		self.HorizontalScrollBar:SetContentSize (self:GetContentWidth ())
		self.HorizontalScrollBar:SetViewSize (self:GetViewWidth ())
		self.HorizontalScrollBar:SetViewOffset (self:GetViewX ())
		self.HorizontalScrollBar:SetVisible (self.HorizontalScrollBar:IsEnabled ())
		self:HookHorizontalScrollBar (self.HorizontalScrollBar)
	end
	
	return self
end

function self:SetScrollBarCorner (scrollBarCorner)
	self.ScrollBarCorner = scrollBarCorner
	return self
end

function self:SetVerticalScrollBar (verticalScrollBar)
	self:UnhookVerticalScrollBar (self.VerticalScrollBar)
	self.VerticalScrollBar = verticalScrollBar
	
	if self.VerticalScrollBar then
		self.VerticalScrollBar:SetContentSize (self:GetContentHeight ())
		self.VerticalScrollBar:SetViewSize (self:GetViewHeight ())
		self.VerticalScrollBar:SetViewOffset (self:GetViewY ())
		self.VerticalScrollBar:SetVisible (self.VerticalScrollBar:IsEnabled ())
		self:HookVerticalScrollBar (self.VerticalScrollBar)
	end
	
	return self
end

function self:SetViewX (viewX)
	if self.ViewX == viewX then return self end
	self.ViewX = viewX
	
	if self.HorizontalScrollBar then
		self.HorizontalScrollBar:SetViewOffset (self.ViewX)
	end
	
	self:DispatchEvent ("ViewXChanged", self.ViewX)
	self:DispatchEvent ("ViewPositionChanged", self.ViewX, self.ViewY)
	return self
end

function self:SetViewY (viewY)
	if self.ViewY == viewY then return self end
	self.ViewY = viewY
	
	if self.VerticalScrollBar then
		self.VerticalScrollBar:SetViewOffset (self.ViewY)
	end
	
	self:DispatchEvent ("ViewYChanged", self.ViewY)
	self:DispatchEvent ("ViewPositionChanged", self.ViewX, self.ViewY)
	return self
end

-- Internal, do not call
function self:HookHorizontalScrollBar (horizontalScrollBar)
	if not horizontalScrollBar then return end
	
	horizontalScrollBar:AddEventListener ("Scroll", tostring (self),
		function (_, viewX)
			self:SetViewX (viewX)
		end
	)
end

function self:UnhookHorizontalScrollBar (horizontalScrollBar)
	if not horizontalScrollBar then return end
	
	horizontalScrollBar:RemoveEventListener ("Scroll", tostring (self))
end

function self:HookVerticalScrollBar (verticalScrollBar)
	if not verticalScrollBar then return end
	
	verticalScrollBar:AddEventListener ("Scroll", tostring (self),
		function (_, viewY)
			self:SetViewY (viewY)
		end
	)
end

function self:UnhookVerticalScrollBar (verticalScrollBar)
	if not verticalScrollBar then return end
	
	verticalScrollBar:RemoveEventListener ("Scroll", tostring (self))
end