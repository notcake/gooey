local PANEL = {}

function PANEL:Init ()
	self.Column = nil
	
	self:SetCursor ("arrow")
	self:SetTextInset (8, 0)
	self:SetWide (256)
	
	self:AddEventListener ("RightClick",
		function (_)
			if not self:GetListView ():GetHeaderMenu () then return end
			self:GetListView ():GetHeaderMenu ():SetOwner (self:GetListView ())
			self:GetListView ():GetHeaderMenu ():Open (self.Column)
		end
	)
end

function PANEL:GetColumn ()
	return self.Column
end

function PANEL:GetListView ()
	return self.Column:GetListView ()
end

local overlayColor = Color (GLib.Colors.CornflowerBlue.r, GLib.Colors.CornflowerBlue.g, GLib.Colors.CornflowerBlue.b, 64)
function PANEL:PaintOver (w, h)
	if self:GetListView ():GetSortColumnId () == self.Column:GetId () then
		surface.SetDrawColor (overlayColor)
		surface.DrawRect (1, 1, w - 2, h - 2)
		
		if self:GetListView ():GetSortOrder () == Gooey.SortOrder.Ascending then
			Gooey.Glyphs.Draw ("up",   Gooey.RenderContext, GLib.Colors.Black, 0, 0, self:GetWide (), 8)
		else
			Gooey.Glyphs.Draw ("down", Gooey.RenderContext, GLib.Colors.Black, 0, 0, self:GetWide (), 8)
		end
	end
end

function PANEL:ResizeColumn (size)
	self:GetListView ():OnRequestResize (self:GetColumn (), size)
end

function PANEL:SetColumn (column)
	self.Column = column
end

function PANEL:SetWidth (width)
	width = math.Clamp (width, self.m_iMinWidth, self.m_iMaxWidth)
	
	if width ~= self:GetWide () then
		self:GetListView ():SetDirty (true)
	end
	
	self:SetWide (width)
	return width
end

Gooey.Register ("GListViewColumnHeader", PANEL, "GButton")