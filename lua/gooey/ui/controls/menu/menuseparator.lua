local self = {}
Gooey.MenuSeparator = Gooey.MakeConstructor (self, Gooey.BaseMenuItem)

function self:ctor ()
end

function self:dtor ()
end

function self:GetText ()
	return "-"
end

function self:IsSeparator ()
	return true
end