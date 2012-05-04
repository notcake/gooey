Gooey.ImageCache = Gooey.ImageCache or {}

local self = Gooey.ImageCache
Gooey.MakeConstructor (self)

function self:ctor ()
	self.Images = {}
	
	self.LoadInterval = 0.1
	self.LastLoadTime = 0
	self:GetImage ("gui/g_silkicons/hourglass")
end

function self:GetImage (image)
	image = image:lower ()
	if self.Images [image] then
		return self.Images [image]
	end	
	if SysTime () - self.LastLoadTime < self.LoadInterval then
		return self:GetImage ("gui/g_silkicons/hourglass")
	end
	self.LastLoadTime = SysTime ()
	
	Gooey.AddResource ("materials/" .. image .. ".vmt")
	local ImageCacheEntry = Gooey.ImageCacheEntry (image)
	self.Images [image] = ImageCacheEntry
	return ImageCacheEntry
end

self:ctor ()