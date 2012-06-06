if Gooey then return end
Gooey = {}
Gooey.Resources = {}

function Gooey.AddResource (path)
	Gooey.Resources [path] = true
end

function Gooey.DeprecatedFunction ()
	if GLib then GLib.Error ("Gooey: Derma function should not be called.") end
end

if SERVER then
	AddCSLuaFile ("gooey/sh_init.lua")
	
	function Gooey.AddCSLuaFolder (folder)
		local files = file.FindInLua (folder .. "/*")
		for _, fileName in pairs (files) do
			if fileName:sub (-4) == ".lua" then
				AddCSLuaFile (folder .. "/" .. fileName)
			end
		end
	end

	function Gooey.AddCSLuaFolderRecursive (folder)
		Gooey.AddCSLuaFolder (folder)
		local folders = file.FindDir ("lua/" .. folder .. "/*", true)
		for _, childFolder in pairs (folders) do
			Gooey.AddCSLuaFolderRecursive (folder .. "/" .. childFolder)
		end
	end
	
	Gooey.AddCSLuaFolderRecursive ("gooey")
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

if SERVER then
	concommand.Add ("gooey_reload_sv", function (ply)
		if ply and not ply:IsSuperAdmin () then return end
		
		if Gooey and Gooey.DispatchEvent then Gooey:DispatchEvent ("Unload") end
		Gooey = nil
		include ("autorun/sh_gooey.lua")
	end)

	concommand.Add ("gooey_reload_sh", function (ply)
		if ply and not ply:IsSuperAdmin () then return end
		
		if Gooey and Gooey.DispatchEvent then Gooey:DispatchEvent ("Unload") end
		Gooey = nil
		include ("autorun/sh_gooey.lua")
		for _, ply in ipairs (player.GetAll ()) do
			ply:ConCommand ("gooey_reload")
		end
	end)
elseif CLIENT then
	concommand.Add ("gooey_reload", function ()
		if Gooey and Gooey.DispatchEvent then Gooey:DispatchEvent ("Unload") end
		Gooey = nil
		include ("autorun/sh_gooey.lua")
	end)
end