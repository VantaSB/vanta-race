resistFire = 0
resistIce = 0
resistElec = 0
resistPoison = 0

immuneFire = 0
immuneIce = 0
immuneElec = 0
immunePoison = 0

hpBonus = 0
epBonus = 0
epRePercentRate = 0
spBonus = 0
dpsBonus = 1.0

banglePrimaryAbilities = { "beambolt" }
--bangleAltAbilities = { "offensive1" }

vSaberSkills = { }

function reinit() --when "forgottenmemories" is triggered, clear all stat bonuses
	player.setProperty("banglePrimaryAbilities", banglePrimaryAbilities)
	sb.logInfo("Script re-initialized - current bangle abilities: %s", banglePrimaryAbilities)
	--player.setProperty("vSaberSkills", vSaberSkills)
	--player.setProperty("bangleAltAbilities", bangleAltAbilities)

	status.clearPersistentEffects("ex_fireResistance")
	status.clearPersistentEffects("ex_iceResistance")
	status.clearPersistentEffects("ex_electricResistance")
	status.clearPersistentEffects("ex_poisonResistance")
	status.clearPersistentEffects("ex_maxHealth")
	status.clearPersistentEffects("ex_protection")
	status.clearPersistentEffects("ex_maxEnergy")
	status.clearPersistentEffects("ex_energyRegenPercentageRate")
	status.clearPersistentEffects("ex_powerMultiplier")
end

function playCinematic(cinematic)
	self.cinematic = config.getParameter("cinematic")
	player.playCinematic(self.cinematic)
end

function elrPlus(params)
	if params[1] == "fire" then
		resistFire = resistFire + params[2] or 0
		immuneFire = immuneFire + params[3] or 0

		status.setPersistentEffects("ex_fireResistance", {
			{stat = "fireResistance", amount = resistFire},
			{stat = "fireStatusImmunity", amount = immuneFire}
		})
	end

	if params[1] == "ice" then
		resistIce = resistIce + params[2] or 0
		immuneIce = immuneIce + params[3] or 0

		status.setPersistentEffects("ex_iceResistance", {
			{stat = "iceResistance", amount = resistIce},
			{stat = "iceStatusImmunity", amount = immuneIce}
		})
	end

	if params[1] == "elec" then
		resistElec = resistElec + params[2] or 0
		immuneElec = immuneElec + params[3] or 0

		status.setPersistentEffects("ex_electricResistance", {
			{stat = "electricResistance", amount = resistElec},
			{stat = "electricStatusImmunity", amount = immuneElec}
		})
	end

	if params[1] == "poison" then
		resistPoison = resistPoison + params[2] or 0
		immunePoison = immunePoison + params[3] or 0

		status.setPersistentEffects("ex_poisonResistance", {
			{stat = "poisonResistance", amount = resistPoison},
			{stat = "poisonStatusImmunity", amount = immunePoison}
		})
	end
end

function statPlus(params)
	if params[1] == "hpPlus" then
		hpBonus = hpBonus + tonumber(params[2])

		status.setPersistentEffects("ex_maxHealth", {
			{stat = "maxHealth", amount = hpBonus}
		})
	elseif params[1] == "epPlus" then
		epBonus = epBonus + tonumber(params[2])

		status.setPersistentEffects("ex_maxEnergy", {
			{stat = "maxEnergy", amount = epBonus}
		})
	elseif params[1] == "epRePlus" then
		epRePercentRate = epRePercentRate + tonumber(params[2])

		status.setPersistentEffects("ex_energyRegenBonus", {
			{stat = "energyRegenPercentageRate", amount = epRePercentRate}
		})
	elseif params[1] == "spPlus" then
		spBonus = spBonus + tonumber(params[2])

		status.setPersistentEffects("ex_protection", {
			{stat = "protection", amount = spBonus}
		})
	elseif params[1] == "dpsPlus" then
		dpsBonus = dpsBonus + tonumber(params[2])

		status.setPersistentEffects("ex_powerMultiplier", {
			{stat = "powerMultiplier", effectiveMultiplier = dpsBonus}
		})
	end
end

function hpPlus(params)
	hpBonus = hpBonus + tonumber(params[1])

	status.setPersistentEffects("ex_maxHealth", {
		{stat = "maxHealth", amount = hpBonus}
	})
end

function epPlus(params)
	epBonus = epBonus + tonumber(params[1])

	status.setPersistentEffects("ex_maxEnergy", {
		{stat = "maxEnergy", amount = epBonus}
	})
end

function epRePlus(params)
	epRePercentRate = epRePercentRate + tonumber(params[1])

	status.setPersistentEffects("ex_energyRegenBonus", {
		{stat = "energyRegenPercentageRate", amount = epRePercentRate}
	})
end

function spPlus(params)
	spBonus = spBonus + tonumber(params[1])

	status.setPersistentEffects("ex_protection", {
		{stat = "protection", amount = spBonus}
	})
end

function dpsPlus(params)
	dpsBonus = dpsBonus + tonumber(params[1])

	status.setPersistentEffects("ex_powerMultiplier", {
		{stat = "powerMultiplier", effectiveMultiplier = dpsBonus}
	})
end

function addBanglePrimaryAbility(params)
	if params then
		table.insert(banglePrimaryAbilities, params)
		player.setProperty("banglePrimaryAbilities", banglePrimaryAbilities)
		sb.logInfo("Unlocked bangle shot type: %s", params)
	else
		sb.logError("Invalid shot type for addBanglePrimaryAbility: %s", params)
	end
end

function addBangleAltAbility(params)
	local index = tonumber(params[1])
	local newAbility = tostring(params[2])

	bangleAltAbilities[index] = newAbility

	player.setProperty("bangleAltAbilities", bangleAltAbilities)
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
	for k, entry in ipairs(shotOrder) do
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

function listBangleAltAbilities()
	bangleAltAbilities = player.getProperty("bangleAltAbilities")
	return bangleAltAbilities
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
