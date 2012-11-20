if Gooey then return end
Gooey = Gooey or {}

include ("glib/glib.lua")

GLib.Initialize ("Gooey", Gooey)
Gooey.AddCSLuaFolderRecursive ("gooey")

function Gooey.DeprecatedFunction ()
	GLib.Error ("Gooey: Derma function should not be called.")
end

if CLIENT then
	function Gooey.Register (className, classTable, baseClassName)
		local init = classTable.Init
		
		for k, v in pairs (Gooey.BasePanel) do
			if not rawget (classTable, k) then
				classTable [k] = v
			end
		end
		
		classTable.Init = function (...)
			-- BasePanel._ctor will check for and avoid multiple initialization
			Gooey.BasePanel._ctor (...)
			if init then
				init (...)
			end
		end
		
		vgui.Register (className, classTable, baseClassName)
	end
	
	include ("clipboard.lua")
	include ("rendercontext.lua")
	include ("ui/controls.lua")
end

Gooey:DispatchEvent ("Initialize")

Gooey.AddReloadCommand ("gooey/gooey.lua", "gooey", "Gooey")