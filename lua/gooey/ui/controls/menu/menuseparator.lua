local self = {}
Gooey.MenuSeparator = Gooey.MakeConstructor (self, Gooey.BaseMenuItem)

function self:ctor ()
end

function self:dtor ()
end

function self:Clone (clone)
	clone = clone or self.__ictor ()
	
	clone:Copy (self)
	
	return clone
end

function self:Copy (source)
	-- BaseMenuItem
	self:SetId      (source:GetId     ())
	self:SetEnabled (source:IsEnabled ())
	self:SetVisible (source:IsVisible ())
	
	-- Events
	self:GetEventProvider ():Copy (source)
	
	return self
end

function self:GetText ()
	return "-"
end

function self:IsSeparator ()
	return true
end