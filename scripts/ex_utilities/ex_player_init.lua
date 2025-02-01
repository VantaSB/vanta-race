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
	message.setHandler("player.isAdmin", player.isAdmin)
	message.setHandler("player.uniqueId",player.uniqueId)
	message.setHandler("player.worldId",player.worldId)
	message.setHandler("player.hasCompletedQuest",function (_,_,...) return player.hasCompletedQuest(...) end)
	status.setStatusProperty("player.worldId",player.worldId())
	status.setStatusProperty("player.ownShipWorldId",player.ownShipWorldId())
	message.setHandler("player.equippedItem",function (_,_,...) return player.equippedItem(...) end)
	message.setHandler("player.hasItem",function (_,_,...) return player.hasItem(...) end)
	message.setHandler("player.hasCountOfItem",function (_,_,...) return player.hasCountOfItem(...) end)
	message.setHandler("player.availableTechs", player.availableTechs)
	message.setHandler("player.enabledTechs", player.enabledTechs)
	message.setHandler("player.shipUpgrades", player.shipUpgrades)
	message.setHandler("player.isLounging", player.isLounging)
	message.setHandler("player.loungingIn", player.loungingIn)
	message.setHandler("playerIsInMech", playerIsInMech)
	message.setHandler("playerIsInVehicle", playerIsInVehicle)

	message.setHandler("ex.spawnParticle",function (_,_,...) localAnimator.spawnParticle(...) end)
	message.setHandler("ex.warp",function (_,_,...) player.warp(...) end)
	message.setHandler("ex.playSound",function (_,_,...) localAnimator.playAudio(...) end)
	message.setHandler("ex.temperaturezone",function (_, _, effectName) status.addEphemeralEffect(effectName) end)
	message.setHandler("ex.giveskillpoints", function (_, _, ...) if player.species() == "vanta" then  world.spawnItem("skillpoint", entity.position())end end)
	message.setHandler("vantaArtifactTaken", function (_, _, ...) player.setProperty("darkGateKeyAcquired", true) end)
end

function uninit()
	origUninit()
	if exUninited then return end
	exUninited = true

	world.sendEntityMessage(player.id(), "stopAltMusic", 2.0)
end
