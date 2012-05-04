local PANEL = {}
surface.CreateFont ("Courier New", 16, 400, false, false, "GooeyMonospace")

function PANEL:Init ()
	self.Disabled = false
	
	Gooey.EventProvider (self)
	
	self.TextEntry = vgui.Create ("DTextEntry", self)
	self.TextEntry:SetMultiline (true)
	self.TextEntry:SetAllowNonAsciiCharacters (true)
	self.TextEntry.OnKeyCodeTyped = function (textEntry, keyCode)
		return self:OnKeyCodeTyped (keyCode)
	end
	self.TextEntry.OnTextChanged = function (textEntry)
		local Text = self.TextEntry:GetValue ()
		if Text == "" then
			return
		end
		self:OnTextInserted (Text)
		self.TextEntry:SetText ("")
	end
	
	self.VScroll = vgui.Create ("DVScrollBar", self)
	self.VScroll:SetUp (0, 0)
	
	-- Settings.
	self.Settings = {}
	self.Settings.CharacterWidth = 8
	self.Settings.LineHeight = 16
	self.Settings.LineNumberWidth = 48
	self.Settings.TabWidth = 4
	
	self.TotalLinesVisible = 0
	self.Lines = {}
	self.LineOffset = 0
	
	self.CaretX = 0
	self.CaretY = 0
	self.PreferredCaretX = 0
	
	self.StringIndex = 0
	
	self:SetText ("ლ(ﾟдﾟ)ლ")
end

function PANEL:CheckCaretPosition ()
	self.StringIndex = self.CaretX
	if self.Lines [self.CaretY + 1].CharacterMap then
		self.StringIndex = -1
		local Previous = nil
		for k, v in ipairs (self.Lines [self.CaretY + 1].CharacterMap) do
			if self.CaretX >= v.CharacterOffset and
				self.CaretX < v.CharacterOffset + v.CharacterWidth then
				self.StringIndex = v.StringOffset - 1
				break
			elseif self.CaretX < v.CharacterOffset then
				if Previous then
					self.StringIndex = Previous.StringOffset + Previous.StringLength + (self.CaretX - Previous.CharacterOffset - Previous.CharacterWidth) - 1
				else
					self.StringIndex = self.CaretX
				end
				break
			end
			Previous = v
		end
		if self.StringIndex == -1 then
			self.StringIndex = Previous.StringOffset + Previous.StringLength + (self.CaretX - Previous.CharacterOffset - Previous.CharacterWidth) - 1
		end
	end
end

function PANEL:DrawCaret ()
	if not self:HasFocus () then
		return
	end
	local CaretX = self.Settings.LineNumberWidth + self.CaretX * self.Settings.CharacterWidth
	local CaretY = (self.CaretY - self.LineOffset) * self.Settings.LineHeight
	if SysTime () % 1 < 0.5 then
		surface.SetDrawColor (128, 128, 128, 255)
		surface.DrawLine (CaretX, CaretY, CaretX, CaretY + self.Settings.LineHeight)
	end
end

function PANEL:DrawLine (lineOffset)
	local Line = self.Lines [self.LineOffset + lineOffset]
	if not Line then
		return
	end
	if not Line.CharacterMap then
		draw.SimpleText (Line.Text or "", "GooeyMonospace", self.Settings.LineNumberWidth, (lineOffset - 1) * self.Settings.LineHeight, Color (255, 255, 255, 255), TEXT_ALIGN_LEFT)
	else
		local StringIndex = 1
		local MapIndex = 1
		local Y = (lineOffset - 1) * self.Settings.LineHeight
		local X = self.Settings.LineNumberWidth
		local NextMapEntry = Line.CharacterMap [MapIndex]
		while StringIndex <= Line.Text:len () do
			if NextMapEntry and StringIndex == NextMapEntry.StringOffset then
				draw.SimpleText (Line.Text:sub (StringIndex, StringIndex + NextMapEntry.StringLength - 1), "GooeyMonospace", X, Y, Color (255, 255, 255, 255), TEXT_ALIGN_LEFT)
				X = X + NextMapEntry.CharacterWidth * self.Settings.CharacterWidth
				StringIndex = StringIndex + Line.CharacterMap [MapIndex].StringLength
				MapIndex = MapIndex + 1
				NextMapEntry = Line.CharacterMap [MapIndex]
			else
				local Length = NextMapEntry and NextMapEntry.StringOffset - StringIndex or 1
				draw.SimpleText (Line.Text:sub (StringIndex, StringIndex + Length - 1), "GooeyMonospace", X, Y, Color (255, 255, 255, 255), TEXT_ALIGN_LEFT)
				X = X + Length * self.Settings.CharacterWidth
				StringIndex = StringIndex + Length
			end
		end
	end
end

function PANEL:DrawSelection ()
	self:DrawCaret ()
end

function PANEL:GetText ()
	local Text = ""
	for _, Line in ipairs (self.Lines) do
		Text = Text .. Line.Text .. "\n"
	end
	return Text
end

function PANEL:HasFocus ()
	return self.TextEntry:HasFocus ()
end

function PANEL:MoveCaretHorizontal (offset)
	local Backwards = offset < 0
	if Backwards then
		offset = -offset
	end
	while offset > 0 do
		local Delta = Backwards and math.min (offset, self.CaretX) or math.min (offset, self.Lines [self.CaretY + 1].CharacterWidths - self.CaretX)
		if Backwards then
			self.CaretX = self.CaretX - Delta
		else
			self.CaretX = self.CaretX + Delta
		end
		offset = offset - Delta
		if offset > 0 then
			offset = offset - 1
			if Backwards then
				if self.CaretY <= 0 then
					break
				end
				self.CaretY = self.CaretY - 1
				self.CaretX = self.Lines [self.CaretY + 1].CharacterWidths
			else
				if self.CaretY + 2 >= #self.Lines then
					break
				end
				self.CaretX = 0
				self.CaretY = self.CaretY + 1
			end
		end
	end
	self.PreferredCaretX = self.CaretX
end

function PANEL:MoveCaretVertical (offset)
	self.CaretY = self.CaretY + offset
	if self.CaretY < 0 then
		self.CaretY = 0
	elseif self.CaretY + 1 >= #self.Lines then
		self.CaretY = #self.Lines - 1
	end
	if self.PreferredCaretX > self.CaretX then
		self.CaretX = self.PreferredCaretX
	end
	if self.CaretX > self.Lines [self.CaretY + 1].CharacterWidths then
		self.CaretX = self.Lines [self.CaretY + 1].CharacterWidths
	end
end

function PANEL:Paint ()
	surface.SetDrawColor (32, 32, 32, 255)
	surface.DrawRect (self.Settings.LineNumberWidth, 0, self:GetWide () - self.Settings.LineNumberWidth, self:GetTall ())
	for i = 1, self.TotalLinesVisible do
		draw.SimpleText (tostring (self.LineOffset + i), "GooeyMonospace", self.Settings.LineNumberWidth - 12, (i - 1) * self.Settings.LineHeight, Color (255, 255, 255, 255), TEXT_ALIGN_RIGHT)
		self:DrawLine (i)
	end
	self:DrawSelection ()
end

function PANEL:PerformLayout ()
	self.TotalLinesVisible = math.floor (self:GetTall () / self.Settings.LineHeight)
	if self.TextEntry then
		self.TextEntry:SetPos (0, 0)
		self.TextEntry:SetSize (0, 0)
	end
	if self.VScroll then
		self.VScroll:SetPos (self:GetWide () - 16, 0)
		self.VScroll:SetSize (16, self:GetTall ())
		self.VScroll:SetUp (self.TotalLinesVisible, #self.Lines)
	end
end

function PANEL:PointToCharacter (x, y)
	local X, Y = math.floor ((x - self.Settings.LineNumberWidth) / self.Settings.CharacterWidth + 0.5), self.LineOffset + math.floor (y / self.Settings.LineHeight)
	if Y + 1 >= #self.Lines then
		Y = #self.Lines - 1
	end
	if X > self.Lines [Y + 1].CharacterWidths then
		PrintTable(self.Lines [Y + 1])
		X = self.Lines [Y + 1].CharacterWidths
	end
	return X, Y
end

function PANEL:RequestFocus ()
	self.TextEntry:RequestFocus ()
end

function PANEL:SetText (text)
	text = text:gsub ("\r\n?", "\n")
	local Lines = text:Split ("\n")
	self.Lines = {}
	for _, Line in ipairs (Lines) do
		local LineEntry = {}
		self.Lines [#self.Lines + 1] = LineEntry
		LineEntry.Text = Line
		LineEntry.CharacterWidths = Gooey.UnicodeLength (Line)
		
		local _, TabCount = string.gsub (Line, "\t", "")
		LineEntry.CharacterWidths = LineEntry.CharacterWidths + TabCount * (self.Settings.TabWidth - 1)
		
		if Gooey.HasUnicodeSequences (Line) or string.find (Line, "\t") then
			LineEntry.CharacterMap = {}
			local CharacterOffset = 0
			for Offset, Character in Gooey.UnicodeIterator (Line) do
				if #LineEntry.CharacterMap > 1000 then
					error ("Too many characters in line!")
				end
				if Character:len () > 1 then
					LineEntry.CharacterMap [#LineEntry.CharacterMap + 1] = {
						CharacterOffset = CharacterOffset,
						CharacterWidth = 1,
						StringOffset = Offset,
						StringLength = Character:len ()
					}
					CharacterOffset = CharacterOffset + 1
				elseif Character == "\t" then
					LineEntry.CharacterMap [#LineEntry.CharacterMap + 1] = {
						CharacterOffset = CharacterOffset,
						CharacterWidth = self.Settings.TabWidth,
						StringOffset = Offset,
						StringLength = 1
					}
					CharacterOffset = CharacterOffset + self.Settings.TabWidth
				else
					CharacterOffset = CharacterOffset + 1
				end
			end
		end
	end
	
	self.VScroll:SetUp (self.TotalLinesVisible, #self.Lines)
end

-- Events
function PANEL:OnGetFocus ()
	self.TextEntry:RequestFocus ()
end

function PANEL:OnKeyCodeTyped (keyCode)
	local Control = input.IsKeyDown (KEY_LCONTROL) or input.IsKeyDown (KEY_RCONTROL)
	local Shift = input.IsKeyDown (KEY_LSHIFT) or input.IsKeyDown (KEY_RSHIFT)
	local Alt = input.IsKeyDown (KEY_LALT) or input.IsKeyDown (KEY_RALT)
	
	if keyCode == KEY_RIGHT then
		self:MoveCaretHorizontal (1)
	elseif keyCode == KEY_LEFT then
		self:MoveCaretHorizontal (-1)
	elseif keyCode == KEY_UP then
		self:MoveCaretVertical (-1)
	elseif keyCode == KEY_DOWN then
		self:MoveCaretVertical (1)
	elseif keyCode == KEY_HOME then
		self.CaretX = 0
		self:CheckCaretPosition ()
	elseif keyCode == KEY_END then
		self.CaretX = self.Lines [self.CaretY + 1].CharacterWidths
		self:CheckCaretPosition ()
	end
	if keyCode == KEY_TAB then
		self:OnTextInserted ("\t")
	end
	if keyCode == KEY_BACKSPACE then
		self.CaretX = self.CaretX - 1
		local Line = self.Lines [self.CaretY + 1]
		if self.CaretX < 0 then
			self.CaretY = self.CaretY - 1
			if self.CaretY < 0 then
				self.CaretY = 0
				self.CaretX = 0
			else
				local PreviousLine = self.Lines [self.CaretY + 1]
				self.CaretX = PreviousLine.CharacterWidths
				PreviousLine.Text = PreviousLine.Text .. Line.Text
				PreviousLine.CharacterWidths = PreviousLine.CharacterWidths + Line.CharacterWidths
				table.remove (self.Lines, self.CaretY + 2)
				PrintTable (self.Lines)
			end
		else
			local Done = false
			if Line.CharacterMap then
				PrintTable (Line.CharacterMap)
				for k, v in ipairs (Line.CharacterMap) do
					if v.CharacterOffset + v.CharacterWidth == self.CaretX + 1 then
						self:CheckCaretPosition ()
						Line.Text = Line.Text:sub (1, math.max (self.StringIndex, 0)) .. Line.Text:sub (self.StringIndex + v.StringLength + 1)
						Line.CharacterWidths = Line.CharacterWidths - v.CharacterWidth
						for i = k, #Line.CharacterMap do
							Line.CharacterMap [i].CharacterOffset = Line.CharacterMap [i].CharacterOffset - v.CharacterWidth
							Line.CharacterMap [i].StringOffset = Line.CharacterMap [i].StringOffset - v.StringLength
						end
						table.remove (Line.CharacterMap, k)
						if #Line.CharacterMap == 0 then
							Line.CharacterMap = nil
						end
						Done = true
						break
					end
					if v.CharacterOffset >= self.CaretX + 1 then
						for i = k, #Line.CharacterMap do
							Line.CharacterMap [i].CharacterOffset = Line.CharacterMap [i].CharacterOffset - 1
							Line.CharacterMap [i].StringOffset = Line.CharacterMap [i].StringOffset - 1
						end
						break
					end
				end
			end
			if not Done then
				Line.Text = Line.Text:sub (1, math.max (self.StringIndex - 1, 0)) .. Line.Text:sub (self.StringIndex + 1)
				Line.CharacterWidths = Line.CharacterWidths - 1
			end
		end
		self:CheckCaretPosition ()
	end
end

function PANEL:OnMousePressed (mouseCode)
	self:RequestFocus ()
	
	if mouseCode == MOUSE_LEFT then
		self.CaretX, self.CaretY = self:PointToCharacter (self:CursorPos ())
		self.PreferredCaretX = self.CaretX
		self:CheckCaretPosition ()
	end
end

function PANEL:OnMouseWheeled (delta)
	self.VScroll:OnMouseWheeled (delta * 0.08)
end

function PANEL:OnTextInserted (text)
	local Control = input.IsKeyDown (KEY_LCONTROL) or input.IsKeyDown (KEY_RCONTROL)
	local Shift = input.IsKeyDown (KEY_LSHIFT) or input.IsKeyDown (KEY_RSHIFT)
	local Alt = input.IsKeyDown (KEY_LALT) or input.IsKeyDown (KEY_RALT)
	
	local Line = self.Lines [self.CaretY + 1]
	Line.Text = Line.Text:sub (1, self.StringIndex) .. text .. Line.Text:sub (self.StringIndex + 1)
	
	local CharacterWidths = Gooey.UnicodeLength (text)
	local _, TabCount = string.gsub (text, "\t", "")
	CharacterWidths = CharacterWidths + TabCount * (self.Settings.TabWidth - 1)
	Line.CharacterWidths = Line.CharacterWidths + CharacterWidths
	self.CaretX = self.CaretX + CharacterWidths
	self:CheckCaretPosition ()
end

function PANEL:OnVScroll (offset)
	if self.TotalLinesVisible < #self.Lines then
		self.LineOffset = math.floor (-offset)
	end
end

vgui.Register ("GCodeEditor", PANEL, "DPanel")