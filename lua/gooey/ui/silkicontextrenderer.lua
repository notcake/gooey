local self = {}
Gooey.SilkiconTextRenderer = Gooey.MakeConstructor (self, Gooey.TextRenderer)

function self:ctor ()
end

function self:RebuildCache (cache)
	if not self:GetFont () then return end
	if not self:GetText () then return end
	
	cache = {}
	cache.Parts = self:ParseText (self:GetText ())
	cache.RenderParts = {}
	local x = 0
	local w = 0
	local y = 0
	local line = 0
	
	surface.SetFont (self:GetFont ())
	
	local previousType = nil
	for i = 1, #cache.Parts do
		local part = cache.Parts [i]
		local type = part.Type
		part.X = x
		part.Y = y
		part.Width  = 0
		part.Height = 0
		part.Line = line
		if type == "Text" then
			if previousType == "Icon" then
				x = x + 2
				part.X = x
			end
			part.Width, part.Height = surface.GetTextSize (part.Value:gsub ("&", "%"))
			x = x + part.Width
		elseif type == "Icon" then
			if previousType == "Text" then
				x = x + 2
				part.X = x
			end
			part.Image = Gooey.ImageCache:GetImage (part.Value)
			part.Width  = part.Image:GetWidth ()
			part.Height = part.Image:GetHeight ()
			x = x + part.Width
		elseif type == "Newline" then
			w = math.max (w, x)
			x = 0
			line = line + 1
		elseif type == "Tab" then
			part.Width, part.Height = surface.GetTextSize ("WWWW")
			x = x + part.Width
		end
		previousType = type
	end
	
	local lineHeight = self:CalculateLineHeight (cache.Parts, 1, #cache.Parts)
	lineHeight = math.max (lineHeight, 16)
	self:VerticalAlignParts (cache.Parts, 1, #cache.Parts, lineHeight)
	
	w = math.max (w, x)
	self:SetWidth (w)
	self:SetHeight (#cache.Parts > 0 and (cache.Parts [#cache.Parts].Y + lineHeight) or lineHeight)
	
	return cache
end

function self:RenderFromCache (renderContext, textColor, cache)
	if not cache then return end
	
	surface.SetFont (self:GetFont ())
	surface.SetTextColor (textColor)
	for i = 1, #cache.Parts do
		local part  = cache.Parts [i]
		local type  = part.Type
		local value = part.Value
		if type == "Text" then
			surface.SetTextPos (part.X, part.Y)
			surface.DrawText (part.Value)
		elseif type == "Icon" then
			Gooey.ImageCache:GetImage (part.Value):Draw (renderContext, part.X, part.Y, 255, 255, 255, 255)
		end
	end
end

-- Internal, do not call
function self:ParseText (text)
	local parts = {}
	
	local text = self:GetText ()
	local spanStart = 1
	local currentOffset = 1
	while currentOffset < #text do
		local character = string.sub (text, currentOffset, currentOffset)
		if character == "\r" or character == "\n" or character == "\t" then
			-- Commit last span
			local spanText = text:sub (spanStart, currentOffset - 1)
			if spanText ~= "" then
				parts [#parts + 1] =
				{
					Type  = "Text",
					Value = spanText
				}
			end
			
			-- Normalize line breaks
			if character == "\r" and string.sub (text, currentOffset + 1, currentOffset + 1) == "\n" then
				currentOffset = currentOffset + 1
				character = "\n"
			end
			
			parts [#parts + 1] =
			{
				Type  = character == "\n" and "Newline" or "Tab",
				Value = character
			}
			spanStart = currentOffset + 1
			currentOffset = currentOffset + 1
		elseif character == "=" then
			-- Check if this is a valid icon
			local match = text:match ("^=([a-zA-Z0-9_]+)=", currentOffset)
			if match then
				match = match:lower ()
				if match == "gaybow" then match = "rainbow" end
				if not file.Exists ("materials/icon16/" .. match .. ".png", "GAME") then
					match = nil
				end
			end
			
			if match then
				-- Commit last span
				local spanText = text:sub (spanStart, currentOffset - 1)
				if spanText ~= "" then
					parts [#parts + 1] =
					{
						Type  = "Text",
						Value = spanText
					}
				end
				parts [#parts + 1] =
				{
					Type  = "Icon",
					Value = "icon16/" .. match .. ".png"
				}
				
				currentOffset = currentOffset + #match + 2
				spanStart = currentOffset
			elseif not match then
				-- Nope, not an icon
				currentOffset = text:find ("[=\n\t]", currentOffset + 1) or (#text + 1)
			end
		else
			currentOffset = text:find ("[=\n\t]", currentOffset) or (#text + 1)
		end
	end
	
	-- Commit last span
	if spanStart <= #text then
		parts [#parts + 1] =
		{
			Type  = "Text",
			Value = string.sub (text, spanStart)
		}
	end
	
	return parts
end

function self:CalculateLineHeight (partArray, startIndex, endIndex)
	local lineHeight = 0
	for i = startIndex, endIndex do
		if partArray [i].Height > lineHeight then
			lineHeight = partArray [i].Height
		end
	end
	return lineHeight
end

function self:VerticalAlignParts (partArray, startIndex, endIndex, lineHeight)
	for i = startIndex, endIndex do
		partArray [i].Y = partArray [i].Line * lineHeight + lineHeight * 0.5 - partArray [i].Height * 0.5
	end
end