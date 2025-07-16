require "/scripts/rect.lua"

function addDrops(drops)
  storage.extraDrops = storage.extraDrops or {}
  for _,item in pairs(drops) do
    table.insert(storage.extraDrops, item)
  end
end

function spawnDrops()
  if storage.extraDrops then
    for _,item in pairs(storage.extraDrops) do
      world.spawnItem(item, mcontroller.position())
    end
  end

	local queryArea = rect.translate({-30, -30, 30, 30}, entity.position())
	local playerList = world.playerQuery(rect.ll(queryArea), rect.ur(queryArea), {includedTypes = { "player" }})
	local threatLevel = world.threatLevel() or 1
	local spChance = math.random(100)

	local spAmount
	local spChanceThreshold
	local bossMonster = config.getParameter("baseParameters.monsterClass", nil)

	if threatLevel == 1 then
		if not bossMonster then
			spAmount = math.random(1, 5)
			spChanceThreshold = 90
		else
			spAmount = 30
			spChance = 100
		end
	elseif threatLevel == 2 or threatLevel == 3 then
		if not bossMonster then
			spAmount = math.random(5, 10)
			spChanceThreshold = 80
		else
			spAmount = 40
			spChance = 100
		end
	elseif threatLevel == 4 or threatLevel == 5 then
		if not bossmonster then
			spAmount = math.random(10, 15)
			spChanceThreshold = 75
		else
			spAmount = 50
			spChance = 100
		end
	elseif threatLevel >= 6 then
		if not bossMonster then
			spAmount = math.random(15, 25)
			spChanceThreshold = 65
		else
			spAmount = 60
			spChance = 100
		end
	end

	if spChance >= spChanceThreshold then
		for _, id in pairs(playerList) do
			world.sendEntityMessage(id, "ex.giveskillpoints", spAmount)
		end
	end
end
