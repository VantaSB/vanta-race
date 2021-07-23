local origInit = init
local origUninit = uninit

-- Prevent the script from being called twice if it was patched into the player more than once for some reason
exInited = false
exUninited = false

function init()
	origInit()
	if exInited then return end
	exInited = true

	-- Add the scan interaction handler if its missing
	if not player.hasQuest("ex_scaninteraction") then
		sb.logInfo("Readded 'ex_scaninteraction' quest")
		player.startQuest("ex_scaninteraction")
	end
end

function uninit()
	origUninit()
	if exUninited then return end
	exUninited = true

	world.sendEntityMessage(player.id(), "stopAltMusic", 2.0)
end
