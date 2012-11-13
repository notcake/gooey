Gooey.Glyphs = {}
Gooey.Glyphs.Renderers = {}

function Gooey.Glyphs.Draw (name, renderContext, color, x, y, w, h)
	surface.SetDrawColor (color)
	xpcall (Gooey.Glyphs.Renderers [name], Gooey.Error, renderContext, color, x, y, w, h)
end

function Gooey.Glyphs.Register (name, renderer)
	Gooey.Glyphs.Renderers [name] = renderer
end