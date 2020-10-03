
--	Don't forget to add the following line to the script: (And don't forget to uncomment it(aka removing the --))
--	require "/ex/ex_util.lua"

--		Functions:
--	# marks optional parameters

--	math.clamp(number, number, number) : Clamps the first number to the given range
--		number	- Input number
--		number	- Minimum range (Will not be below this)
--		number	- Maximum range (Will not be above this)

--	exutil.PrintTable(table) : Prints the contents of the given table.
--		table	- The table you want to print (Can shove any other value, but it ill just print it as it is)

--	exutil.DeepPrintTable(table) : Prints the contents of the given table and all tables contained within.
--		table	- The table you want to print (Can shove any other value, but it ill just print it as it is)

--	exutil.FadeHex(string, string, integer, string) : Returns a modified two-digit hex faded in the requested direction of the recieved two-digit hex
--		string	- Two-digit hex string, such as "FF" or "13" or "E4"
--		string	- "out" or "in", depending on the direction you want it to fade to. "out" strive to "00", and "in" strives to "FF"
--		integer	- By how much you want to modify the hex value
--	#	string	- Target hex value the modification should not exceed. If fading in, and increasing "10" hex by 5, but target is "13", it will go up to "13" instead of to "15"

--	exutil.ValToHex(number) : Turns a number between 0 and 1 into the hex equivalent of 0 and 255 RGB (0 = 00, 1 = FF)
--		number	- A number between 0 and 1 (gets clamped)

--	exutil.RGBToHex(number) : Turns a number between 0 and 255 into hex (0 = 00, 255 = FF)
--		number	- A number between 0 and 255

--	exutil.HexToRGB(hex) : Turns a hex into a number between 0 and 255 (00 = 0, FF = 255)
--		hex		- A hex string between 00 and FF

--	exutil.RollDice(integer, integer, integer) : Returns a value of a simulated dice roll. (Ever wanted to use a simple 2d4 somewhere before?)
--		integer	- Amount of rolled dice
--		integer	- Dice sides
--	#	integer - Static modifier added to the final value

--	exutil.MergeTable(table, table) : Merges tables. Unlike vanilla 'util.MergeTable', merges arrays (aka 'ipairs' table) instead of overriding them
--		table	- Table to merge into
--		table	- Table to merge from

--	exutil.IsArray(table) : Returns true if the table is an array ('ipairs' table)
--		table	- Table you'd like to check

--	exutil.positionWhithinBounds(table[2], table[2], table[2]) : Returns true if the first passed table is inside the box created by the second and third tables
--		table[2] - Position you're checking
--		table[2] - Position of the boxes lower left corner
--		table[2] - Position of the boxes upper right corner

--	exutil.positionWhithinBox(table[2], table[4]) : Returns true if the first passed table is inside the passed box
--		table[2] - Position you're checking
--		table[4] - Box coordinates

-- Preventing potential overrides
exutil = exutil or {}

function math.clamp(input, min, max)
	return math.max(min, math.min(input, max))
end

function exutil.PrintTable(tbl)
	if type(tbl) == "table" then
		local str = "\n{"
		for k, v in pairs(tbl) do
			local lenFix = ""
			for i = 1, 30 - string.len(tostring(k)) do
				lenFix = lenFix.." "
			end

			str = str.."\n	"..tostring(k)..lenFix.."=          ("..type(v)..") "..tostring(v)
		end

		sb.logInfo("\n%s", str.."\n}")
	else
		sb.logInfo("\n%s", tbl)
	end
end

function exutil.DeepPrintTable(tbl)
	sb.logInfo("%s", exutil._DeepPrintTableHelper(tbl, 0))
end

function exutil._DeepPrintTableHelper(toPrint, level)
	level = level or 0
	local str = ""

	if type(toPrint) == "table" then
		for k, v in pairs(toPrint) do
			for i = 0, level do
				str = str.."	"
			end

			local lenFix = ""
			for i = 1, 30 - string.len(tostring(k)) do
				lenFix = lenFix.." "
			end

			str = str..tostring(k)..lenFix.."=          ("..type(v)..") "..tostring(v)

			if type(v) == "table" then
				str = str..exutil._DeepPrintTableHelper(v, level +1).."\n"
			else
				str = str.."\n"
			end
		end

	else
		str = tostring(toPrint)
	end

	return "\n"..str
end

function exutil.RGBToHex(num)
	num = math.clamp(math.floor(num + 0.5), 0, 255)

	local hexidecimal = "0123456789ABCDEF"
	local units = num%16+1
	local tens = math.floor(num/16)+1
	return string.sub(hexidecimal, tens, tens)..string.sub(hexidecimal, units, units)
end

function exutil.ValToHex(num)
	return exutil.RGBToHex(255 * math.clamp(num, 0, 1))
end

function exutil.HexToRGB(hex)
	hex = string.upper(hex)
	if string.len(hex) == 1 then
		hex = "0"..hex
	elseif string.len(hex) == 0 then
		return 0
	end

	local hexidecimal = "0123456789ABCDEF"
	local tens = string.find(hexidecimal, string.sub(hex,1,1))
	local units = string.find(hexidecimal, string.sub(hex,2,2))
	return (tonumber(tens)-1)*16 + (tonumber(units)-1)
end

function exutil.FadeHex(hex, fade, amount, target)
	if target then target = exutil.HexToRGB(hex) end
	amount = math.floor(amount+0.5)
	fade = string.lower(fade)

	local rgbValue = exutil.HexToRGB(hex)

	if fade == "out" then
		rgbValue = math.max(target or 0, rgbValue - amount)
	elseif fade == "in" then
		rgbValue = math.min(target or 255, rgbValue + amount)
	else
		sb.logError("ERROR - 'exutil.FadeHex' 2nd arguement not 'in' or 'out'")
		return "00"
	end

	return exutil.RGBToHex(rgbValue)
end

function exutil.RollDice(dice, sides, mod)
	local sum = mod or 0

	for i = 1, dice do
		sum = sum + math.random(1, sides)
	end

	return sum
end

function exutil.MergeTable(t1, t2)
	if exutil.IsArray(t2) then
		for _, v in ipairs(t2) do
			table.insert(t1, v)
		end
	elseif exutil.IsArray(t1) then
		local length = #t2
		for _, v in ipairs(t2) do
			table.insert(t1, v)
		end

		for k, v in pairs(t2) do
			if type(k) ~= "number" or k > length then
				if type(v) == "table" and type(t1[k]) == "table" then
					exutil.MergeTable(t1[k] or {}, v)
				else
					t1[k] = v
				end
			end
		end
	else
		for k, v in pairs(t2) do
			if type(v) == "table" and type(t1[k]) == "table" then
				exutil.MergeTable(t1[k] or {}, v)
			else
				t1[k] = v
			end
		end
	end
	return t1
end

function exutil.IsArray(tbl)
	if type(tbl) == "table" then
		local length = #tbl
		for i, _ in pairs(tbl) do
			if type(i) ~= "number" or i > length then
				return false
			end
		end
		return true
	end
	return false
end

function exutil.positionWhithinBounds(target, startPoint, endPoint)
	return (target[1] >= startPoint[1] and target[1] <= endPoint[1] and target[2] >= startPoint[2] and target[2] <= endPoint[2])
end

function exutil.positionWhithinBox(target, box)
	return (target[1] >= box[1] and target[1] <= box[3] and target[2] >= box[2] and target[2] <= box[4])
end
