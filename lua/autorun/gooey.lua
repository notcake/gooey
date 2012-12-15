if CLIENT and not file.Exists ("gooey/gooey.lua", "LCL") then return end
if CLIENT and not GetConVar ("sv_allowcslua"):GetBool () then return end
include ("gooey/gooey.lua")