require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"

function build(directory, config, parameters, level, seed)
	local configParameter = function(keyName, defaultValue)
		if parameters[keyName] ~= nil then
			return parameters[keyName]
		elseif config[keyName] ~= nil then
			return config[keyName]
		else
			return defaultValue
		end
	end

	if level and not configParameter("fixedLevel", true) then
		parameters.level = level
	end

	-- select, load and merge abilities
	setupAbility(config, parameters, "primary")
	setupAbility(config, parameters, "alt")

	-- elemental type
	local elementalType = configParameter("elementalType", "physical")
	replacePatternInData(config, nil, "<elementalType>", elementalType)

	-- calculate damage level multiplier
	config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))

	config.tooltipFields = {}
	config.tooltipFields.subtitle = parameters.category
	config.tooltipFields.maxDamageLabel = util.round(config.projectileParameters.power * config.damageLevelMultiplier, 1)
	config.tooltipFields.damagePerShotLabel = util.round(config.projectileParameters.power * config.damageLevelMultiplier, 1)
	config.tooltipFields.dpsLabel = util.round(config.projectileParameters.power * config.damageLevelMultiplier, 1)
	config.tooltipFields.speedLabel = "--"
	if elementalType ~= "physical" then
		config.tooltipFields.damageKindImage = "/interface/elements/"..elementalType..".png"
	end
	config.tooltipFields.levelLabel = util.round(configParameter("level", 1), 1)
	config.tooltipFields.critChanceLabel = util.round(configParameter("critChance",0), 0)
	config.tooltipFields.critBonusLabel = util.round(configParameter("critBonus",0), 0)
	config.price = (config.price or 0) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))

	return config, parameters
end
