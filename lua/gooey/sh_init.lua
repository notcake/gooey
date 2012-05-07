Gooey = Gooey or {}
Gooey.Debug = SinglePlayer () or (GetConVar ("sensitivity") and true or false)
Gooey.Resources = {}

if Gooey.DispatchEvent then
	Gooey:DispatchEvent ("Unload")
end

function Gooey.AddResource (path)
	Gooey.Resources [path] = true
end

function Gooey.DeprecatedFunction ()
	if GLib then GLib.Error ("Gooey: Derma function should not be called.") end
end

if SERVER then
	AddCSLuaFile ("gooey/sh_init.lua")
	
	function Gooey.AddLuaFolder (folder)
		local files = file.FindInLua (folder .. "/*")
		for _, fileName in pairs (files) do
			if fileName:sub (-4) == ".lua" then
				AddCSLuaFile (folder .. "/" .. fileName)
			end
		end
	end

	function Gooey.AddLuaFolderRecursive (folder)
		Gooey.AddLuaFolder (folder)
		local folders = file.FindDir ("../lua/" .. folder .. "/*")
		for _, v in pairs (folders) do
			Gooey.AddLuaFolderRecursive (folder .. "/" .. v)
		end
	end
	
	if not Gooey.Debug then
		Gooey.AddLuaFolderRecursive ("gooey")
	end
end


include ("gooey/sh_oop.lua")
include ("gooey/sh_eventprovider.lua")
include ("gooey/sh_unicode.lua")
Gooey.EventProvider (Gooey)

if CLIENT then
	include ("gooey/ui/cl_controls.lua")
else
	include ("gooey/sh_resources.lua")
end

Gooey:DispatchEvent ("Initialize")

concommand.Add ("gooey_reload" .. (CLIENT and "" or "_sv"), function ()
	include ("autorun/sh_gooey.lua")
end)

if SERVER then
	concommand.Add ("gooey_reload_sh", function ()
		include ("autorun/sh_gooey.lua")
		for _, ply in ipairs (player.GetAll ()) do
			ply:ConCommand ("gooey_reload")
		end
	end)
end