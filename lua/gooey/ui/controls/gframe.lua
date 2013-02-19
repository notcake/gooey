local PANEL = {}

--[[
	Events:
		MaximizableChanged (sizable)
			Fired when this frame's maximizability has been changed.
		Maximized ()
			Fired when this frame has been maximized.
		Restored ()
			Fired when this frame has been restored.
		SizableChanged (sizable)
			Fired when this frame's sizability has been changed.
]]

function PANEL:Init ()
	-- Size Control
	self.btnMaxim:SetDisabled (false)
	self.btnMaxim.DoClick = function ()
		if self:IsMaximized () then
			self:Restore ()
		else
			self:Maximize ()
		end
	end
	
	self.Maximizable = true
	self.Maximized = false
	
	self.Sizable = true
	
	self.RestoredX = 0
	self.RestoredY = 0
	self.RestoredWidth = 0
	self.RestoredHeight = 0
	
	self.ResizeGrip = vgui.Create ("GResizeGrip", self)
	self.ResizeGrip:SetSize (16, 16)
	
	self:AddEventListener ("DoubleClick",
		function (_, x, y)
			if x >= self.btnMinim:GetPos () then return end
			if y >= 31 then return end
			if self:IsMaximized () then
				self:Restore ()
			else
				self:Maximize ()
			end
		end
	)
	
	-- Double Clicks
	self.LastLeftMouseButtonReleaseTime = 0
end

-- Size Control
function PANEL:IsMaximized ()
	return self.Maximized
end

function PANEL:IsSizable ()
	return self.Sizable
end

function PANEL:Maximize ()
	if self:IsMaximized () then return end
	
	self.Maximized = true
	
	-- Based off SKIN:PaintWindowMaximizeButton
	self.btnMaxim.Paint = function (panel, w, h)
		if not panel.m_bBackground then return end
		
		if panel:GetDisabled () then
			return panel:GetSkin ().tex.Window.Restore (0, 0, w, h, Color (255, 255, 255, 50))
		end	
		
		if panel.Depressed or panel:IsSelected () then
			return panel:GetSkin ().tex.Window.Restore_Down (0, 0, w, h)
		end	
		
		if panel.Hovered then
			return panel:GetSkin ().tex.Window.Restore_Hover (0, 0, w, h)
		end
		
		panel:GetSkin ().tex.Window.Restore (0, 0, w, h)
	end
	
	self.ResizeGrip:SetVisible (false)
	
	self.RestoredX, self.RestoredY = self:GetPos ()
	self.RestoredWidth = self:GetWide ()
	self.RestoredHeight = self:GetTall ()
	
	self:SetPos (0, 0)
	self:SetSize (self:GetParent ():GetSize ())
	
	self:DispatchEvent ("Maximized")
end

function PANEL:Restore ()
	if not self:IsMaximized () then return end
	
	self.Maximized = false
	self.btnMaxim.Paint = function (panel, w, h)
		derma.SkinHook ("Paint", "WindowMaximizeButton", panel, w, h)
	end
	
	self.ResizeGrip:SetVisible (self:IsSizable ())
	
	self:SetPos (self.RestoredX, self.RestoredY)
	self:SetSize (self.RestoredWidth, self.RestoredHeight)
	
	self:DispatchEvent ("Restored")
end

function PANEL:SetMaximizable (maximizable)
	if self.Maximizable == maximizable then return end
	
	self.Maximizable = maximizable
	self.btnMaxim:SetDisabled (not self.Maximizable)
	
	self:DispatchEvent ("MaximizableChanged", self.Maximizable)
end

function PANEL:SetSizable (sizable)
	self.Sizable = sizable
	
	DFrame.SetSizable (self, sizable)
	self.ResizeGrip:SetVisible (sizable)
end

-- Event handlers
function PANEL:OnCursorMoved (x, y)
	self:DispatchEvent ("MouseMove", 0, x, y)
	if self.OnMouseMove then self:OnMouseMove (0, self:CursorPos ()) end
end

function PANEL:OnKeyCodePressed (keyCode)
	return self:DispatchKeyboardAction (keyCode)
end
PANEL.OnKeyCodeTyped = PANEL.OnKeyCodePressed

function PANEL:OnMousePressed (mouseCode)
	DFrame.OnMousePressed (self, mouseCode)
	
	self:DispatchEvent ("MouseDown", mouseCode, self:CursorPos ())
	if self.OnMouseDown then self:OnMouseDown (mouseCode, self:CursorPos ()) end
end

function PANEL:OnMouseReleased (mouseCode)
	DFrame.OnMouseReleased (self, mouseCode)
	
	self:DispatchEvent ("MouseUp", mouseCode, self:CursorPos ())
	if self.OnMouseUp then self:OnMouseUp (mouseCode, self:CursorPos ()) end
	
	if mouseCode == MOUSE_LEFT then
		if SysTime () - self.LastLeftMouseButtonReleaseTime < 0.4 then
			if self.OnDoubleClick then self:OnDoubleClick (mouseCode, self:CursorPos ()) end
			self:DispatchEvent ("DoubleClick", self:CursorPos ())
		else
			if self.OnClick then self:OnClick (mouseCode, self:CursorPos ()) end
			self:DispatchEvent ("Click", self:CursorPos ())
		end
		
		self.LastLeftMouseButtonReleaseTime = SysTime ()
	elseif mouseCode == MOUSE_RIGHT then
		self:DispatchEvent ("RightClick", self:CursorPos ())
	end
end

function PANEL:OnMouseWheeled (delta)
	self:DispatchEvent ("MouseWheel", delta, self:CursorPos ())
	if self.OnMouseWheel then self:OnMouseWheel (delta, self:CursorPos ()) end
end

Gooey.Register ("GFrame", PANEL, "DFrame")