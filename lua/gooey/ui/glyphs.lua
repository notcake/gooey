Gooey.Glyphs = {}
Gooey.Glyphs.Renderers = {}

function Gooey.Glyphs.Draw (name, renderContext, color, x, y, w, h)
	surface.SetDrawColor (color)
	Gooey.Glyphs.Renderers [name] (renderContext, color, x, y, w, h)
end

function Gooey.Glyphs.Register (name, renderer)
	Gooey.Glyphs.Renderers [name] = renderer
end