local PANEL = {}
local openMenus = {}

--[[
	GMenu
		A menu control that does not require recreating every time
		it needs to be shown (unlike DMenus)

	Events
		MenuOpening (GMenu menu, Object targetItem)
]]

local function CloseMenus ()
	for _, menu in pairs (openMenus) do
		menu:Hide ()
		openMenus [menu] = nil
	end
end

function PANEL:Init ()
	self.ClassName = "DMenu"
	self:SetVisible (false)
	self.TargetItem = nil
	
	-- Remove ourselves from the derma menu list
	local _, menuList = debug.getupvalue (RegisterDermaMenuForClose, 1)
	menuList [#menuList] = nil
	
	Gooey:AddEventListener ("Unload", tostring (self), function ()
		self:Remove ()
	end)
	
	Gooey.EventProvider (self)
end

function PANEL:AddOption (id, callback)
	local item = vgui.Create ("GMenuItem", self)
	item:SetParentMenu (self)
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
    local item = vgui.Create ("DBevel", self)
    item:SetTall (2)
    item:SetAlpha (100)
    item.Id = id
	
    self:AddPanel (item)
	
	return item
end

PANEL.AddSpacer = PANEL.AddSeparator

function PANEL:CloseMenus ()
	CloseMenus ()
end

function PANEL:FindItem (id)
	for _, item in pairs (self:GetItems ()) do
		if item.Id == id then
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
end

function PANEL:Open (targetItem)
	self.TargetItem = targetItem
	
	openMenus [self] = self
	self:DispatchEvent ("MenuOpening", targetItem)
	DMenu.Open (self)
end

function PANEL:PerformLayout ()
	DMenu.PerformLayout (self)
	
	if self.animOpen.Running then
		return
	end
	local w, h = self:GetMinimumWidth (), 0
	
	for _, item in pairs (self:GetItems ()) do
		item:PerformLayout()
        w = math.max (w, item:GetWide ())
    end
	
	self:SetWide (w)
	
	for _, item in pairs (self:GetItems ()) do
		item:SetWide (w)
		item:SetPos (0, h)
		item:InvalidateLayout (true)
		
		if item:IsVisible () then
			h = h + item:GetTall ()
		end
	end
	
	self:SetTall (h)
end

function PANEL:Remove ()
	Gooey:RemoveEventListener ("Unload", tostring (self))
	_R.Panel.Remove (self)
end

function PANEL:SetTargetItem (targetItem)
	self.TargetItem = targetItem
end

vgui.Register ("GMenu", PANEL, "DMenu")

hook.Add ("VGUIMousePressed", "GMenus", function (panel, mouseCode)
	while panel ~= nil and panel:IsValid () do
		if panel.ClassName == "DMenu" then
			return
		end
		panel = panel:GetParent ()
	end
	
	CloseMenus ()
end)

Gooey:AddEventListener ("Unload", function ()
	CloseMenus ()
end)