local self = {}
Gooey.KeyboardMap = Gooey.MakeConstructor (self)

function self:ctor ()
	self.Keys = {}
end

function self:Execute (control, key, ctrl, shift, alt)
	if not self.Keys [key] then return false end
	
	local handled
	for _, handler in ipairs (self.Keys [key]) do
		handled = handler (control, key, ctrl, shift, alt)
		if handled == nil then handled = true end
		if handled then break end
	end
	return handled or false
end

function self:Register (key, handler)
	if type (key) == "table" then
		for _, v in ipairs (key) do
			self:Register (v, handler)
		end
		return
	end
	
	self.Keys [key] = self.Keys [key] or {}
	self.Keys [key] [#self.Keys [key] + 1] = handler
end