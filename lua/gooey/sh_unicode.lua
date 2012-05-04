function Gooey.HasUnicodeSequences (str)
	return string.find (str, "[\192-\255]") and true or false	
end

function Gooey.UnicodeByte (str)
	local Byte = string.byte (str)
	if Byte >= 240 then
		if string.len (str) < 4 then
			return 0
		end
		Byte = (Byte & 7) * 262144
		Byte = Byte + (string.byte (str, 2) & 63) * 4096
		Byte = Byte + (string.byte (str, 3) & 63) * 64
		Byte = Byte + (string.byte (str, 4) & 63)
	elseif Byte >= 224 then
		if string.len (str) < 3 then
			return 0
		end
		Byte = (Byte & 15) * 4096
		Byte = Byte + (string.byte (str, 2) & 63) * 64
		Byte = Byte + (string.byte (str, 3) & 63)
	elseif Byte >= 192 then
		if string.len (str) < 2 then
			return 0
		end
		Byte = (Byte & 31) * 64
		Byte = Byte + (string.byte (str, 2) & 63)
	elseif Byte >= 128 then
		Byte = 0
	end
	return Byte
end

function Gooey.UnicodeChar (byte)
	local str = ""
	if byte < 1 then
		return ""
	elseif byte < 128 then
		str = string.char (byte)
	elseif byte < 2048 then
		str = string.format ("%c%c", 192 + math.floor (byte / 64), 128 + (byte & 63))
	elseif byte < 65536 then
		str = string.format ("%c%c%c", 224 + math.floor (byte / 4096), 128 + (math.floor (byte / 64) & 63), 128 + (byte & 63))
	elseif byte < 2097152 then
		str = string.format ("%c%c%c%c", 240 + math.floor (byte / 262144), 128 + (math.floor (byte / 4096) & 63), 128 + (math.floor (byte / 64) & 63), 128 + (byte & 63))
	end
	return str
end

function Gooey.UnicodeIterator (str)
	local Offset = 1
	return function ()
		if Offset > str:len () then
			return nil, nil
		end
		local Length = Gooey.UnicodeSequenceLength (str:sub (Offset))
		local Character = str:sub (Offset, Offset + Length - 1)
		local LastOffset = Offset
		Offset = Offset + Length
		return LastOffset, Character
	end
end

function Gooey.UnicodeLength (str)
	local _, Length = string.gsub (str, "[^\128-\191]", "")
	return Length
end

function Gooey.UnicodeSequenceLength (str)
	local Byte = string.byte (str)
	if Byte >= 240 then
		return 4
	elseif Byte >= 224 then
		return 3
	elseif Byte >= 192 then
		return 2
	end
	return 1
end