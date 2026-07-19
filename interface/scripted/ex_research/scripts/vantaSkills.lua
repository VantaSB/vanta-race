vSaberSkills = {
	seishoujin = false,
	zaneiretsu = false,
	yamigetsuga = false,
	kokuugetsujin = false
}

vGunSkills = {
	--TBD
}

vElements = {
	physical = true,
	fire = false,
	ice = false,
	electric = false,
	poison = false,
	cerlueum = false
}

vElementalDamageBonuses = {
	physical = 0,
	fire = 0,
	ice = 0,
	electric = 0,
	poison = 0,
	ceruleum = 0
}

vStatBonuses = {
	maxHealth = 0,
	maxEnergy = 0,
	energyRegenPercentageRate = 0,
	energyRegenBlockTime = 0,
	powerMultiplier = 0,
	protection = 0
}

function reinit() --when "forgottenmemories" is triggered, clear all stat bonuses
	player.setProperty("vSaberSkills", vSaberSkills)
	player.setProperty("vGunSkills", vGunSkills)
	player.setProperty("vElements", vElements)
	player.setProperty("vElementalDamageBonuses", vElementalDamageBonuses)
	status.clearPersistentEffects("vStatBonuses")

	player.unequipTech("vantapsicore")
	player.unequipTech("vantastealth1")
	player.unequipTech("vantastealth2")
	player.unequipTech("vantarazorjump")
	player.unequipTech("vantasphere")
	player.unequipTech("vantananosphere1")
	player.unequipTech("vantananosphere2")
	player.unequipTech("enhancedwalljump")
	player.unequipTech("stopwalljump")

	player.makeTechUnavailable("vantapsicore")
	player.makeTechUnavailable("vantastealth1")
	player.makeTechUnavailable("vantastealth2")
	player.makeTechUnavailable("vantarazorjump")
	player.makeTechUnavailable("vantasphere")
	player.makeTechUnavailable("vantananosphere1")
	player.makeTechUnavailable("vantananosphere2")
	player.makeTechUnavailable("enhancedwalljump")
	player.makeTechUnavailable("stopwalljump")
end

function addSaberSkill(params)
	if type(params) ~= "table" or params == nil then
		sb.logError("Invalid params for addSaberSkill(): table expected, but got %s", params)
	else
		if type(params[1]) == "string" and vSaberSkills[params[1]] ~= nil then
			if type(params[2]) == "boolean" then
				vSaberSkills[params[1]] = params[2]
				player.setProperty("vSaberSkills", vSaberSkills)
			else
				sb.logWarn("Invalid value for addSaberSkill(): \"%s\" must be a boolean (true or false)", params[2])
			end
		else
			sb.logWarn("Invalid skill name for addSaberSkill(): \"%s\" is not found in the array", params[1])
		end
	end
end

function addGunSkill(params)
	--
end

function addWeaponElement(params)
	if type(params) ~= "table" or params == nil then
		sb.logError("Invalid params for addWeaponElement(): table expected, but got %s", params)
	else
		if type(params[1]) == "string" and vElements[params[1]] ~= nil then
			if type(params[2]) == "boolean" then
				vElements[params[1]] = params[2]
				player.setProperty("vElements", vElements)
			else
				sb.logWarn("Invalid value for addWeaponElement(): \"%s\" must be a boolean (true or false)", params[2])
			end
		else
			sb.logWarn("Invalid element name for addWeaponElement(): \"%s\" is not found in the array", params[1])
		end
	end
end

function addElementalBonus(params)
	if type(params) ~= "table" or params == nil then
		sb.logError("Invalid params for addElementalBonus(): table expected, but got %s", params)
	else
		if type(params[1]) == "string" and vElementalDamageBonuses[params[1]] ~= nil then
			if type(params[2]) == "number" then
				vElementalDamageBonuses[params[1]] = vElementalDamageBonuses[params[1]] + params[2]
				player.setProperty("vElementalDamageBonuses", vElementalDamageBonuses)
			else
				sb.logWarn("Invalid value for addElementalBonus(): \"%s\" must be a number", params[2])
			end
		else
			sb.logWarn("Invalid element name for addElementalBonus(): \"%s\" is not found in the array", params[1])
		end
	end
end

function addCoreStatBonus(params)
	local oldStats
	if status.getPersistentEffects("vStatBonuses") ~= nil then
		oldStats = status.getPersistentEffects("vStatBonuses")
		for _, effect in pairs(oldStats) do
			if effect.stat and vStatBonuses[effect.stat] ~= nil then
				vStatBonuses[effect.stat] = effect.amount
			end
		end
	end

	if type(params) ~= "table" or params == nil then
		sb.logError("Invalid params for addcoreStatBonus(): table expected, but got %s", params)
	else
		if type(params[1]) == "string" and vStatBonuses[param[1]] ~= nil then
			if type(params[2]) == "number" then
				vStatBonuses[params[1]] = vStatBonuses[params[1]] + params[2]
				local newStats = {}
				for statKey, amt in pairs(vStatBonuses) do
					if amt ~= 0 then
						table.insert(newStats, {stat = statKey, amount = amt})
					end
					status.setPersistentEffects("vStatBonuses", newStats)
				end
			else
				sb.logWarn("Invalid value for addCoreStatBonus(): \"%s\" must be a number", params[2])
			end
		else
			sb.logWarn("Invalid stat name for addCoreStatBonus(): \"%s\" is not found in the array", params[1])
		end
	end
end

function listBangleAbilities()
	banglePrimaryAbilities = player.getProperty("banglePrimaryAbilities")
	--sb.logInfo("Player bangle abilities: %s", banglePrimaryAbilities)

	--Define fixed order matching ElementalShift shotTypes
	local shotOrder = {
		{ ability = "beambolt", shot = "psiphysicalshot", emitter = "beambolt" },
		{ ability = "firebolt", shot = "psifireshot", emitter = "firebolt" },
		{ ability = "icebolt", shot = "psiiceshot", emitter = "icebolt" },
		{ ability = "thunderbolt", shot = "psielectricshot", emitter = "thunderbolt" },
		{ ability = "biobolt", shot = "psipoisonshot", emitter = "biobolt" }
	}

	--Filter unlocked shotTypes
	local abilities = {}
	for _, entry in ipairs(shotOrder) do
		--sb.logInfo("Entry Query: %s : %s", k, entry)
		local mappedAbility = entry.ability
		for _, unlocked in ipairs(banglePrimaryAbilities) do
			if unlocked == entry.shot or unlocked == mappedAbility then
				--sb.logInfo("Adding ability: ability=%s, shot=%s, emitter=%s", mappedAbility, entry.shot, entry.emitter)
				table.insert(abilities, { shotType = entry.shot, emitter = entry.emitter })
				break
			end
		end
	end
	--sb.logInfo("Abilities output: %s", abilities)
	return abilities
end

function getSaberSkills()
	local skills = player.getProperty("vSaberSkills")
	return skills
end

function getGunSkills()
	--
end

function getElementalBonuses()
	local bonuses = player.getProperty("vElementalDamageBonuses")
	return bonuses
end

function listBangleAltAbilities()
	bangleAltAbilities = player.getProperty("bangleAltAbilities")
	return bangleAltAbilities
end

function getPlayerTechs()
	local techs = player.enabledTechs()
	return techs
end

function getTechInput()
	local techInput = player.getProperty("vTechInput")
	return techInput
end

function modifyTech(params)
	if params == "vantasphere" then
		player.makeTechAvailable("vantasphere")
    player.enableTech("vantasphere")
    player.equipTech("vantasphere")
	elseif params == "vantananosphere" then
		player.makeTechAvailable("vantananosphere")
		player.enableTech("vantananosphere")
		player.equipTech("vantananosphere")
		player.makeTechUnavailable("vantasphere")
	elseif params == "vantananosphere2" then
		player.makeTechAvailable("vantananosphere2")
		player.enableTech("vantananosphere2")
		player.equipTech("vantananosphere2")
		player.makeTechUnavailable("vantananosphere")
	elseif params == "enhancedwalljump" then
		player.makeTechAvailable("enhancedwalljump")
    player.enableTech("enhancedwalljump")
    player.equipTech("enhancedwalljump")
	elseif params == "stopwalljump" then
		player.makeTechAvailable("stopwalljump")
    player.enableTech("stopwalljump")
    player.equipTech("stopwalljump")
	elseif params == "vantastealth1" then
		player.makeTechAvailable("vantastealth1")
    player.enableTech("vantastealth1")
    player.equipTech("vantastealth1")
	elseif params == "vantastealth2" then
		player.makeTechAvailable("vantastealth2")
    player.enableTech("vantastealth2")
    player.equipTech("vantastealth2")
		player.makeTechUnavailable("vantastealth1")
	end
end
