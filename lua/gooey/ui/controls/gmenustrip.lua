local PANEL = {}

--[[
	Events:
		MenuClosed ()
			Fired when this menu has been closed.
		MenuOpening (Object targetItem)
			Fired when this menu is opening.
]]

Derma_Hook (PANEL, "Paint", "Paint", "MenuBar")

function PANEL:Init ()
	self:SetTall (24)
	
	self.TargetItem = nil
	
	self:SetMouseInputEnabled (true)
	self:SetKeyboardInputEnabled (true)
	
	self.Menus = {}
	self.Items = {}
end

function PANEL:AddMenu (id)
	if self.Menus [id] then return self.Menus [id] end
	
	local menu = vgui.Create ("GMenu")
	menu:SetText (id)
	menu.Id = id
	self.Menus [id] = menu
	
	local item = vgui.Create ("GButton", self)
	item:SetText (id)
	item:SetIsMenu (true)
	item:SetDrawBackground (false)
	item:SizeToContentsX (16)
	item.Id = id
	item.Menu = menu
	self.Items [#self.Items + 1] = item
	
	menu:AddEventListener ("EnabledChanged",
		function (_, enabled)
			item:SetEnabled (enabled)
		end
	)
	
	menu:AddEventListener ("MenuClosed",
		function (_)
			menu.CloseTime = CurTime ()
		end
	)
	
	menu:AddEventListener ("TextChanged",
		function (_, text)
			item:SetText (text)
			self:InvalidateLayout ()
		end
	)
	
	item:AddEventListener ("MouseDown",
		function (_)
			if not item.Menu or not item.Menu:IsValid () then return end
			
			if item.Menu:IsVisible () or
			   item.Menu.CloseTime == CurTime () then
				item.Menu:Hide ()
				return
			end
			
			local x, y = item:LocalToScreen (0, item:GetTall ())
			item.Menu:Open ()
			item.Menu:SetPos (x, y)
		end
	)
	
	item:AddEventListener ("TextChanged",
		function (_)
			item:SizeToContentsX (16)
		end
	)
	
	return menu
end

function PANEL:AddSeparator (id)
    local item = vgui.Create ("GMenuSeparator", self)
    item:SetWide (1)
    item.Id = id
	
	self.Items [#self.Items + 1] = item
	self:InvalidateLayout ()
	
	return item
end

function PANEL:GetItemById (id)
	for _, item in pairs (self.Items) do
		if item.Id == id then
			return item.Menu or item
		end
	end
	return nil
end

function PANEL:GetTargetItem ()
	return self.TargetItem
end

function PANEL:PerformLayout ()
	local x = 0
	for _, item in ipairs (self.Items) do
		item:SetPos (x, 1)
		item:SetTall (self:GetTall () - 2)
		item:PerformLayout ()
		
		if item:IsVisible () then
			x = x + item:GetWide () + 5
		end
	end
end

function PANEL:SetTargetItem (targetItem)
	self.TargetItem = targetItem
end

-- Event handlers
function PANEL:OnRemoved ()
	for _, menu in pairs (self.Menus) do
		menu:Remove ()
	end
end

Gooey.Register ("GMenuStrip", PANEL, "GPanel")