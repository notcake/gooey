local self = {}
Gooey.ImageCacheEntry = Gooey.MakeConstructor (self)

function self:ctor (image)
	self.Image = image
	self.Material = Material (image)
	if self.Material:IsError () then
		local fallbackImage = Gooey.ImageCache:GetFallbackImage ()
		if fallbackImage then
			self.Material = Gooey.ImageCache:GetFallbackImage ():GetMaterial ()
		end
	end
	
	if string.find (self.Material:GetShader (), "VertexLitGeneric") or
		string.find (self.Material:GetShader (), "Cable") then
		local baseTexture = self.Material:GetMaterialString ("$basetexture")
		if baseTexture then
			self.Material = CreateMaterial (image .. "_DImage", "UnlitGeneric",
				{
					["$basetexture"] = baseTexture,
					["$vertexcolor"] = 1,
					["$vertexalpha"] = 1
				}
			)
		end
	end
	
	local texture = self.Material:GetMaterialTexture ("$basetexture")
	if texture then
		self.Width  = texture:GetActualWidth ()
		self.Height = texture:GetActualHeight ()
	else
		self.Width  = 16
		self.Height = 16
	end
end

function self:Draw (renderContext, x, y, r, g, b, a)
	surface.SetMaterial (self.Material)
	surface.SetDrawColor (r or 255, g or 255, b or 255, a or 255)
	surface.DrawTexturedRect (x or 0, y or 0, self.Width, self.Height)
end

function self:GetHeight ()
	return self.Height
end

function self:GetMaterial ()
	return self.Material
end

function self:GetSize ()
	return self.Width, self.Height
end

function self:GetWidth ()
	return self.Width
end