--[[
	This is a hack to allow the escape key to be processed on controls other than GTextEntry.
]]

local keyboardMonitor = Gooey.KeyboardMonitor ()

keyboardMonitor:RegisterKey (KEY_ESCAPE)
keyboardMonitor:AddEventListener ("KeyPressed",
	function (_, keyCode)
		local focusedPanel = vgui.GetKeyboardFocus ()
		
		if not focusedPanel then return end
		if not focusedPanel:IsValid () then return end
		if type (focusedPanel.DispatchKeyboardAction) ~= "function" then return end
		
		focusedPanel:DispatchKeyboardAction (keyCode)
	end
)