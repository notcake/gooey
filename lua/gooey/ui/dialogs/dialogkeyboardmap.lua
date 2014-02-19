Gooey.DialogKeyboardMap = Gooey.KeyboardMap ()

Gooey.DialogKeyboardMap:Register (KEY_ESCAPE,
	function (self, key, ctrl, shift, alt)
		self:Close ()
	end
)