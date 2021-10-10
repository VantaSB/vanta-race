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
end


--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- For some reason, this breaks mech deployment, so this is going to be nixed. Will need to find a way to update MM tool skins outside of ex_player_init that doesn't interfere with the MM Upgrade or Quickbar utility windows.
-- Curiously, this was also breaking the ability to begin the initial bounty hunting quest normally.

--[[function update(dt)
		checkMatterManipulator()
end

--[[function checkMatterManipulator()
	local playerSpecies = player.species()
	local wireTool = player.essentialItem("wiretool")
	local paintTool = player.essentialItem("painttool")

	-- If there is a wire tool equipped, let's make sure it's the species-appropriate variant, otherwise ignore
	if playerSpecies == "vanta" then
		if not paintTool then
			return
		elseif paintTool and paintTool.name ~= "vantapainttool" then
			player.giveEssentialItem("painttool", "vantapainttool")
		end

		if not wireTool then
			return
		elseif wireTool and wireTool.name ~= "vantawiretool" then
			player.giveEssentialItem("wiretool", "vantawiretool")
		end
	end
end]]

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function uninit()
	origUninit()
	if exUninited then return end
	exUninited = true

	world.sendEntityMessage(player.id(), "stopAltMusic", 2.0)
end
