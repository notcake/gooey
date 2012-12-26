if SERVER or
   file.Exists ("gooey/gooey.lua", "LUA") or
   file.Exists ("gooey/gooey.lua", "LCL") and GetConVar ("sv_allowcslua"):GetBool () then
	include ("gooey/gooey.lua")
end