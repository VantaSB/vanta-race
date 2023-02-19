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
dpsBonus = 1

-- The ability names for the bangle and grimoire are actually not used internally, this is more so for easier referencing when building the skill lines.
banglePrimaryAbilities = { "beambolt1" }
bangleAltAbilities = { "offensive1" }
grimoireAbilities = { "physbarrage" }

function reinit() --when "forgottenmemories" is triggered, clear all stat bonuses
	player.setProperty("banglePrimaryAbilities", banglePrimaryAbilities)
	player.setProperty("grimoireAbilities", grimoireAbilities)
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

		status.setPersistentEffects("ex_fireResistance", {
			{stat = "fireResistance", amount = resistIce},
			{stat = "fireStatusImmunity", amount = immuneIce}
		})
	end

	if params[1] == "elec" then
		resistElec = resistElec + params[2] or 0
		immuneElec = immuneElec + params[3] or 0

		status.setPersistentEffects("ex_fireResistance", {
			{stat = "fireResistance", amount = resistElec},
			{stat = "fireStatusImmunity", amount = immuneElec}
		})
	end

	if params[1] == "poison" then
		resistPoison = resistPoison + params[2] or 0
		immunePoison = immunePoison + params[3] or 0

		status.setPersistentEffects("ex_fireResistance", {
			{stat = "fireResistance", amount = resistPoison},
			{stat = "fireStatusImmunity", amount = immunePoison}
		})
	end
end

function hpPlus(params)
	hpBonus = hpBonus + tonumber(params[1]) or 0

	status.setPersistentEffects("ex_maxHealth", {
		{stat = "maxHealth", amount = hpBonus}
	})
end

function epPlus(params)
	epBonus = epBonus + tonumber(params[1]) or 0

	status.setPersistentEffects("ex_maxEnergy", {
		{stat = "maxEnergy", amount = epBonus}
	})
end

function epRePlus(params)
	epRePercentRate = epRePercentRate + tonumber(params[1]) or 0

	status.setPersistentEffects("ex_energyRegenBonus", {
		{stat = "energyRegenPercentageRate", amount = epRePercentRate or 0}
	})
end

function spPlus(params)
	spBonus = spBonus + tonumber(params[1]) or 0

	status.setPersistentEffects("ex_protection", {
		{stat = "protection", amount = spBonus}
	})
end

function dpsPlus(params)
	dpsBonus = dpsBonus + tonumber(params[1]) or 1

	status.setPersistentEffects("ex_powerMultiplier", {
		{stat = "powerMultiplier", effectiveMultiplier = dpsBonus}
	})
end

function addBangleAbility(params)
	local index = tonumber(params[1])
	local newAbility = tostring(params[2])

	banglePrimaryAbilities[index] = newAbility

	player.setProperty("banglePrimaryAbilities", banglePrimaryAbilities)
end

function addGrimoireAbility(params)
	local index = tonumber(params[1])
	local newAbility = tostring(params[2])

	grimoireAbilities[index] = newAbility

	player.setProperty("grimoireAbilities", grimoireAbilities)
end

function listBangleAbilities()
	banglePrimaryAbilities = player.getProperty("banglePrimaryAbilities")
	return banglePrimaryAbilities
end

function listGrimoireAbilities()
	grimoireAbilities = player.getProperty("grimoireAbilities")
	return grimoireAbilities
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
