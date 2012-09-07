local PANEL = {}

function PANEL:Init ()
	self:SetTall (24)
	
	self.Panels = {}
	self.Grip = vgui.Create ("GStatusBarGrip", self)
	
	self.Text = ""
	
	self:SetBackgroundColor (GLib.Colors.Silver)
end

function PANEL:AddPanel (text)
	return self:AddTextPanel (text)
end

function PANEL:AddTextPanel (text)
	local panel = vgui.Create ("GStatusBarPanel", self)
	self.Panels [#self.Panels + 1] = panel
	panel:SetSizingMethod (Gooey.SizingMethod.ExpandToFit)
	
	local label = vgui.Create ("DLabel")
	label:SetTextColor (GLib.Colors.Black)
	label:SetTextInset (4)
	label:SetContentAlignment (4)
	panel:SetContents (label)
	panel:SetText (text)
	
	self:InvalidateLayout ()
	
	return panel
end

function PANEL:GetPanel (index)
	return self.Panels [index]
end

function PANEL:GetPanelCount ()
	return #self.Panels
end

function PANEL:GetText ()
	if self:GetPanelCount () == 0 then return self.Text or "" end
	return self:GetPanel (1):GetText ()
end

function PANEL:Paint ()
	draw.RoundedBoxEx (4, 0, 0, self:GetWide (), self:GetTall (), self:GetBackgroundColor (), false, false, true, true)
	
	if self:GetPanelCount () == 0 then
		surface.SetFont ("Default")
		local w, h = surface.GetTextSize (self:GetText ())
		surface.SetTextColor (self:GetTextColor ())
		surface.SetTextPos (4, (self:GetTall () - h) * 0.5)
		surface.DrawText (self:GetText ())
	else
		surface.SetDrawColor (GLib.Colors.Gray)
		for i = 2, self:GetPanelCount () do
			local x = self:GetPanel (i):GetPos ()
			surface.DrawLine (x - 2, 2, x - 2, self:GetTall () - 1)
		end
	end
	
	local x = self.Grip:GetPos ()
	surface.SetDrawColor (GLib.Colors.Gray)
	surface.DrawLine (x - 2, 2, x - 2, self:GetTall () - 1)
end

function PANEL:PerformLayout ()
	self:SetWide (self:GetParent ():GetWide () - 4)
	self:SetPos (2, self:GetParent ():GetTall () - self:GetTall () - 2)
	
	if self.Grip then
		self.Grip:PerformLayout ()
		
		-- Calculate panel widths
		local x = 0
		local w = self:GetWide () - self.Grip:GetWide ()
		local remainingWidth = w
		local index = 1
		
		local dividerWidth = 4
		
		local expandToFitPanelCount = 0
		for i = 1, self:GetPanelCount () do
			local panel = self:GetPanel (i)
			if panel:IsVisible () then
				local panelWidth = 0
				local sizingMethod = panel:GetSizingMethod ()
				if sizingMethod == Gooey.SizingMethod.Fixed then
					panelWidth = math.min (remainingWidth - dividerWidth, panel:GetFixedWidth ())
				elseif sizingMethod == Gooey.SizingMethod.Percentage then
					panelWidth = math.min (remainingWidth - dividerWidth, math.floor (panel:GetPercentageWidth () / 100 * w + 0.5))
				else
					expandToFitPanelCount = expandToFitPanelCount + 1
				end
				panel:SetWide (panelWidth)
				
				if sizingMethod ~= Gooey.SizingMethod.ExpandToFit then
					x = x + panelWidth + dividerWidth
					remainingWidth = remainingWidth - panelWidth - dividerWidth
				end
			end
		end
		
		-- Distribute remaining width among panels which expand to fit
		local dividedWidth = (remainingWidth - expandToFitPanelCount * dividerWidth) / expandToFitPanelCount
		for i = 1, self:GetPanelCount () do
			local panel = self:GetPanel (i)
			if panel:IsVisible () then
				if panel:GetSizingMethod () == Gooey.SizingMethod.ExpandToFit then
					panel:SetWidth (dividedWidth)
				end
			end
		end
		
		-- Layout panels
		local x = 0
		for i = 1, self:GetPanelCount () do
			local panel = self:GetPanel (i)
			if panel:IsVisible () and panel:GetWide () > 0 then
				panel:SetPos (x, 0)
				panel:SetTall (self:GetTall ())
				
				x = x + panel:GetWide () + dividerWidth
			end
		end
	end
end

function PANEL:SetText (text)
	if self:GetPanelCount () == 0 then self.Text = text or "" return end
	self:GetPanel (1):SetText (text)
end

Gooey.Register ("GStatusBar", PANEL, "GPanel")