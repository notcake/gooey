local PANEL = {}
local openMenus = {}

--[[
	Events:
		MenuClosed ()
			Fired when this menu has been closed.
		MenuOpening (Object targetItem)
			Fired when this menu is opening.
]]

function Gooey.CloseMenus ()
	for _, menu in pairs (openMenus) do
		menu:Hide ()
		openMenus [menu] = nil
	end
end

function Gooey.IsMenuOpen ()
	return next (openMenus) and true or false
end

function PANEL:Init ()
	self.ClassName = "DMenu"
	self:SetVisible (false)
	self.TargetItem = nil
	
	self:SetMouseInputEnabled (true)
	self:SetKeyboardInputEnabled (true)
	
	-- Remove ourselves from the derma menu list
	local _, menuList = debug.getupvalue (RegisterDermaMenuForClose, 1)
	menuList [#menuList] = nil
	
	self:SetDeleteSelf (false)
	
	Gooey:AddEventListener ("Unloaded", tostring (self:GetTable ()),
		function ()
			self:Remove ()
		end
	)
end

function PANEL:AddOption (id, callback)
	local item = vgui.Create ("GMenuItem", self)
	item:SetContainingMenu (self)
	item:SetText (id)
	item.Id = id
	if callback then
		item:AddEventListener ("Click",
			function (_)
				callback (self.TargetItem)
			end
		)
	end
	self:AddPanel (item)
	
	return item
end

function PANEL:AddSeparator (id)
    local item = vgui.Create ("GMenuSeparator", self)
    item:SetTall (1)
    item.Id = id
	
    self:AddPanel (item)
	
	return item
end

PANEL.AddSpacer = PANEL.AddSeparator

function PANEL:CloseMenus ()
	Gooey.CloseMenus ()
end

function PANEL:GetItemById (id)
	for _, item in pairs (self:GetCanvas ():GetChildren ()) do
		if not item:IsMarkedForDeletion () and item.Id == id then
			return item
		end
	end
	return nil
end

function PANEL:GetTargetItem ()
	return self.TargetItem
end

function PANEL:Hide ()
	self.TargetItem = nil
	
	openMenus [self] = nil
	DMenu.Hide (self)
	
	self:DispatchEvent ("MenuClosed")
end

function PANEL:Open (targetItem)
	self.TargetItem = targetItem
	
	openMenus [self] = self
	self:SetPos (gui.MouseX (), gui.MouseY ())
	self:DispatchEvent ("MenuOpening", targetItem)
	
	-- The MenuOpening hook may override our display position
	local x, y = self:GetPos ()
	DMenu.Open (self, x, y)
	
	-- This fixes menu items somehow losing mouse focus as 
	-- soon as a mouse press occurs when another panel has keyboard focus.
	self:SetKeyboardInputEnabled (true)
	self:RequestFocus ()
end

function PANEL:OpenSubMenu (item, menu)
	if item and not item:IsEnabled () then return end
	
	local openSubMenu = self:GetOpenSubMenu ()
	if openSubMenu then
		if menu and openSubMenu == menu then return end
		
		self:CloseSubMenu (openSubMenu)
	end
	
	if not menu then return end

	local x, y = item:LocalToScreen (self:GetWide (), 0)
	menu:Open ()
	menu:SetPos (x - 3, y)
	
	self:SetOpenSubMenu (menu)
end

function PANEL:PerformLayout ()
	DMenu.PerformLayout (self)
	
	local w, h = self:GetMinimumWidth (), 0
	
	for k, item in pairs (self:GetCanvas ():GetChildren ()) do
		if not item:IsMarkedForDeletion () then
			item:PerformLayout()
			w = math.max (w, item:GetWide ())
		end
    end
	
	self:SetWide (w)
	
	for _, item in pairs (self:GetCanvas ():GetChildren ()) do
		item:SetWide (w)
		item:SetPos (0, h)
		item:InvalidateLayout (true)
		
		if item:IsVisible () and not item:IsMarkedForDeletion () then
			h = h + item:GetTall ()
		end
	end
	
	self:SetTall (h)
end

function PANEL:SetTargetItem (targetItem)
	self.TargetItem = targetItem
end

-- Event handlers
function PANEL:OnRemoved ()
	Gooey:RemoveEventListener ("Unloaded", tostring (self:GetTable ()))
end

Gooey.Register ("GMenu", PANEL, "DMenu")

hook.Add ("VGUIMousePressed", "GMenus", function (panel, mouseCode)
	while panel ~= nil and panel:IsValid () do
		if panel.ClassName == "DMenu" then
			return
		end
		panel = panel:GetParent ()
	end
	
	Gooey.CloseMenus ()
end)

Gooey:AddEventListener ("Unloaded", function ()
	Gooey.CloseMenus ()
end)