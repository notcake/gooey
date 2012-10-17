local self = {}
Gooey.ImageCache = Gooey.MakeConstructor (self)

function self:ctor ()
	self.Images = {}
	
	self.LoadInterval = 0.1
	self.LastLoadTime = 0
	
	self.FallbackImage    = self:LoadImage ("gui/silkicons/cross")
	self.PlaceholderImage = self:LoadImage ("gui/g_silkicons/hourglass")
end

function self:GetFallbackImage ()
	return self.FallbackImage
end

function self:GetPlaceholderImage ()
	return self.PlaceholderImage
end

function self:GetImage (image)
	image = image:lower ()
	if self.Images [image] then
		return self.Images [image]
	end
	if SysTime () - self.LastLoadTime < self.LoadInterval then
		return self:GetPlaceholderImage ()
	end
	self.LastLoadTime = SysTime ()
	
	local imageCacheEntry = Gooey.ImageCacheEntry (self, image)
	self.Images [image] = imageCacheEntry
	return imageCacheEntry
end

function self:LoadImage (image)
	image = image:lower ()
	if self.Images [image] then
		return self.Images [image]
	end
	
	local imageCacheEntry = Gooey.ImageCacheEntry (self, image)
	self.Images [image] = imageCacheEntry
	return imageCacheEntry
end

Gooey.ImageCache = Gooey.ImageCache ()