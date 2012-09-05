local self = {}
Gooey.KeyboardMap = Gooey.MakeConstructor (self)

function self:ctor ()
	self.Keys = {}
end

function self:Execute (control, key, ctrl, shift, alt)
	if not self.Keys [key] then return false end
	
	local handled = self.Keys [key] (control, key, ctrl, shift, alt)
	if handled == nil then handled = true end
	return handled
end

function self:Register (key, handler)
	if type (key) == "table" then
		for _, v in ipairs (key) do
			self:Register (v, handler)
		end
		return
	end
	self.Keys [key] = handler
end