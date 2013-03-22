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
		ViewWidthChanged (viewWidth)
			Fired when the view width has changed.
		ViewSizeChanged (viewWidth, viewHeight)
			Fired when the view size has changed.
]]

function self:ctor ()
	self.ContentWidth  = 0
	self.ContentHeight = 0
	
	self.ViewWidth  = 0
	self.ViewHeight = 0
	
	self.ViewX = 0
	self.ViewY = 0
	
	self.VerticalScrollBar   = nil
	self.HorizontalScrollbar = nil
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

function self:GetVerticalScrollBar ()
	return self.VerticalScrollBar
end

function self:GetViewHeight ()
	return self.ViewHeight
end

function self:GetViewWidth ()
	return self.ViewWidth
end

function self:SetContentHeight (contentHeight)
	if self.ContentHeight == contentHeight then return self end
	
	self.ContentHeight = contentHeight
	self:DispatchEvent ("ContentHeightChanged", self.ContentHeight)
	self:DispatchEvent ("ContentSizeChanged", self.ContentWidth, self.ContentHeight)
	return self
end

function self:SetContentWidth (contentWidth)
	if self.ContentWidth == contentWidth then return self end
	
	self.ContentWidth = contentWidth
	self:DispatchEvent ("ContentWidthChanged", self.ContentWidth)
	self:DispatchEvent ("ContentSizeChanged", self.ContentWidth, self.ContentHeight)
	return self
end

function self:SetViewHeight (viewHeight)
	if self.ViewHeight == viewHeight then return self end
	
	self.ViewHeight = viewHeight
	self:DispatchEvent ("ViewHeightChanged", self.ViewHeight)
	self:DispatchEvent ("ViewSizeChanged", self.ViewWidth, self.ViewHeight)
	return self
end

function self:SetViewWidth (viewWidth)
	if self.ViewWidth == viewWidth then return self end
	
	self.ViewWidth = viewWidth
	self:DispatchEvent ("ViewWidthChanged", self.ViewWidth)
	self:DispatchEvent ("ViewSizeChanged", self.ViewWidth, self.ViewHeight)
	return self
end

function self:SetHorizontalScrollBar (horizontalScrollBar)
	self:UnhookHorizontalScrollBar (self.HorizontalScrollBar)
	self.HorizontalScrollBar = horizontalScrollBar
	self:HookHorizontalScrollBar (self.HorizontalScrollBar)
end

function self:SetVerticalScrollBar (verticalScrollBar)
	self:UnhookVerticalScrollBar (self.VerticalScrollBar)
	self.VerticalScrollBar = verticalScrollBar
	self:HookVerticalScrollBar (self.VerticalScrollBar)
end

-- Internal, do not call
function self:HookHorizontalScrollBar (horizontalScrollBar)
	if not horizontalScrollBar then return end
	
	horizontalScrollBar:AddEventListener ("Scroll", tostring (self),
		function (_)
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
		function (_)
		end
	)
end

function self:UnhookVerticalScrollBar (verticalScrollBar)
	if not verticalScrollBar then return end
	
	verticalScrollBar:RemoveEventListener ("Scroll", tostring (self))
end