std = "lua53c"
max_line_length = false -- May enable later. Have too many lines with 150+ symbols in existing code

ignore = {
	-- Temporarily disabled warning (harmless, too many places to fix):
	-- due to how Starbound isolates Lua files, not using "local" for these variables is not a problem.
	"111", -- "setting non-standard global variable [...]"
	"112", -- "mutating non-standard global variable [...]"
	"113", -- "accessing undefined variable [...]"

	-- It's unfortunate to have to disable this warning (it is really good at catching real typos),
	-- but the log would be flooded with 1000 "unused argument dt" or "unused argument shiftHeld".
	"212", -- "unused argument"

	-- Skip warning when using variables starting with '_'
	"214", -- "used variable [...]"

	-- Skip "empty if branch", most (if not all) current cases
	-- seem to do this intentionally for better readability.
	-- Alternative would be having ~50 inline comments "-- luacheck: ignore 542".
	"542",

	-- Skip warning which suggests replacing 'not (x > y)' with 'x <= y'
	"581" -- "[...] can be replaced by [...] (if neither side is a table or NaN)"
}

-- These global variables are allowed.
globals = {
	"item",
	"self",
	"storage"
}

-- These global variables are allowed, but can't be modified.
-- These are mainly things from https://starbounder.org/Modding:Lua
read_globals = {
	celestial = {
		fields = {
			-- celestial.flyShip is supposed to be modified
			flyShip = { read_only = false }
		},
		other_fields = true
	},
	"config",
	"entity",
	"monster",
	"npc",
	"object",
	"player",
	"root",
	"world"
}

codes = true -- Show luacheck's error/warning codes. Useful for adding exceptions.

-- Ignore "unused argument self" (W212) in object-oriented methods like widgetBase:hasMouse()
self = false
