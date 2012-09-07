local PANEL = {}

function PANEL:Init ()
	self:SetSize (24, 24)
	
	self:SetCursor ("sizenwse")
	
	self.DragController = Gooey.DragController (self)
	self.DragController:AddEventListener ("PositionCorrectionChanged",
		function (_, deltaX, deltaY)
			local statusBar = self:GetParent ()
			local frame = statusBar:GetParent ()
			
			local x, y   = frame:GetPos ()
			local width  = frame:GetWide () + deltaX
			local height = frame:GetTall () + deltaY
			
			-- Clamp to bottom right corner of screen
			width  = math.min (width,  ScrW () - x)
			height = math.min (height, ScrH () - y)
			
			-- Enforce minimum frame size
			width  = math.max (width,  128)
			height = math.max (height, self:GetTall () * 2 + 24)
			
			frame:SetSize (width, height)
		end
	)
end

function PANEL:Paint ()
	local w, h = self:GetSize ()
	local padding = 4
	local dotSize = (w - padding * 2) / 5
	dotSize = math.floor (dotSize + 0.5) -- round dotSize
	
	local x = padding
	draw.RoundedBox (2, x, h - padding - dotSize, dotSize, dotSize, GLib.Colors.Gray)
	x = x + dotSize * 2
	draw.RoundedBox (2, x, h - padding - dotSize * 3, dotSize, dotSize, GLib.Colors.Gray)
	draw.RoundedBox (2, x, h - padding - dotSize, dotSize, dotSize, GLib.Colors.Gray)
	x = x + dotSize * 2
	draw.RoundedBox (2, x, h - padding - dotSize * 5, dotSize, dotSize, GLib.Colors.Gray)
	draw.RoundedBox (2, x, h - padding - dotSize * 3, dotSize, dotSize, GLib.Colors.Gray)
	draw.RoundedBox (2, x, h - padding - dotSize, dotSize, dotSize, GLib.Colors.Gray)
end

function PANEL:PerformLayout ()
	self:SetTall (self:GetParent ():GetTall ())
	self:SetWide (self:GetTall ())
	self:SetPos (self:GetParent ():GetWide () - self:GetWide (), 0)
end

Gooey.Register ("GStatusBarGrip", PANEL, "GPanel")