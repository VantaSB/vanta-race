require "/scripts/util.lua"

function init()

end

function onInteraction(args)
	return { "OpenTeleportDialog", {
			canBookmark = false,
			includePlayerBookmarks = false,
			destinations = { {
				name = "Exit Portal",
				planetName = "Return to world... hopefully!",
				icon = "return",
				warpAction = "Return"
			} }
		}
	}
end
