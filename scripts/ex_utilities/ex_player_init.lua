require "/scripts/util.lua"

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

	-- Add any miscellaneuos functions/message handlers below this line in the future, if applicable
	message.setHandler("ex.spawnParticle",function (_,_,...) localAnimator.spawnParticle(...) end)
	message.setHandler("ex.warp",function (_,_,...) player.warp(...) end)
	message.setHandler("ex.playSound",function (_,_,...) localAnimator.playAudio(...) end)
end

function uninit()
	origUninit()
	if exUninited then return end
	exUninited = true

	world.sendEntityMessage(player.id(), "stopAltMusic", 2.0)
end
