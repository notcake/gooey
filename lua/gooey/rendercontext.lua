local self = {}
Gooey.RenderContext = Gooey.MakeConstructor (self)

function self:ctor ()
	self.PreviousRenderTargets = {}
	self.ViewPortStack = {}
	
	self.ScreenWidth = 0
	self.ScreenHeight = 0
end

function self:ClearColor (color, a)
	render.Clear (color.r, color.g, color.b, a or color.a)
end

function self:ClearDepth ()
	render.ClearDepth ()
end

function self:PopRenderTarget ()
	render.SetRenderTarget (self.PreviousRenderTargets [#self.PreviousRenderTargets])
	self.PreviousRenderTargets [#self.PreviousRenderTargets] = nil
end

function self:PushRelativeViewPort (x, y, w, h)
	local previousViewPort = self.ViewPortStack [#self.ViewPortStack]
	if previousViewPort then
		x = x + previousViewPort.x
		y = y + previousViewPort.y
	else
		self.ScreenWidth = ScrW ()
		self.ScreenHeight = ScrH ()
	end
	w = w or self.ScreenWidth
	h = h or self.ScreenHeight
	self.ViewPortStack [#self.ViewPortStack + 1] = { x = x, y = y, w = w, h = h }
	render.SetViewPort (x, y, w, h)
end

function self:PushRenderTarget (renderTarget)
	self.PreviousRenderTargets [#self.PreviousRenderTargets + 1] = render.GetRenderTarget ()
	render.SetRenderTarget (renderTarget)
end

function self:PushScreenViewPort ()
	if #self.ViewPortStack == 0 then
		self.ScreenWidth = ScrW ()
		self.ScreenHeight = ScrH ()
	end
	self:PushViewPort (0, 0, self.ScreenWidth, self.ScreenHeight)
end

function self:PushViewPort (x, y, w, h)
	if #self.ViewPortStack == 0 then
		self.ScreenWidth = ScrW ()
		self.ScreenHeight = ScrH ()
	end
	w = w or self.ScreenWidth
	h = h or self.ScreenHeight
	self.ViewPortStack [#self.ViewPortStack + 1] = { x = x, y = y, w = w, h = h }
	render.SetViewPort (x, y, w, h)
end

function self:PopViewPort ()
	self.ViewPortStack [#self.ViewPortStack] = nil
	
	local viewPort = self.ViewPortStack [#self.ViewPortStack] or { x = 0, y = 0, w = self.ScreenWidth, h = self.ScreenHeight }
	render.SetViewPort (viewPort.x, viewPort.y, viewPort.w, viewPort.h)
end

function self:SetRelativeViewPort (x, y, w, h)
	if #self.ViewPortStack == 0 then
		self:PushViewPort (x, y, w, h)
		return
	end
	local previousViewPort = self.ViewPortStack [#self.ViewPortStack - 1]
	if previousViewPort then
		x = x + previousViewPort.x
		y = y + previousViewPort.y
	end
	w = w or self.ScreenWidth
	h = h or self.ScreenHeight
	
	local viewPort = self.ViewPortStack [#self.ViewPortStack]
	viewPort.x = x
	viewPort.y = y
	viewPort.w = w
	viewPort.h = h
	render.SetViewPort (x, y, w, h)
end

function self:SetViewPort (x, y, w, h)
	if #self.ViewPortStack == 0 then
		self:PushViewPort (x, y, w, h)
		return
	end
	w = w or self.ScreenWidth
	h = h or self.ScreenHeight
	
	local viewPort = self.ViewPortStack [#self.ViewPortStack]
	viewPort.x = x
	viewPort.y = y
	viewPort.w = w
	viewPort.h = h
	render.SetViewPort (x, y, w, h)
end

Gooey.RenderContext = Gooey.RenderContext ()