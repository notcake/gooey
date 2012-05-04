if CLIENT then
	local PanelMetatable = table.Copy (_R.Panel)

	function PanelMetatable:__gc (...)
		ErrorNoHalt (tostring (self) .. ":dtor\n")
		if self.dtor then
			self:dtor (...)
		end
		_R.Panel.__gc (self, ...)
	end

	function Gooey.AddDestructor (panel, dtor)
		debug.setmetatable (panel, PanelMetatable)
		panel.dtor = panel.dtor or dtor
	end
end

function Gooey.MakeConstructor (metatable, base)
	metatable.__index = metatable
	
	if base then
		local name, basetable = debug.getupvalue (base, 1)
		metatable.__base = basetable
		setmetatable (metatable, basetable)
	end
	
	return function (...)
		local object = {}
		setmetatable (object, metatable)
		
		-- Call base constructors
		local base = object.__base
		local basectors = {}
		while base ~= nil do
			basectors [#basectors + 1] = base.ctor
			base = base.__base
		end
		for i = #basectors, 1, -1 do
			basectors [i] (object, ...)
		end
		
		-- Call object constructor
		if object.ctor then
			object:ctor (...)
		end
		return object
	end
end