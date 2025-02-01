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
	local spChance = math.random(100)
	local spChanceThreshold = nil
	local threatLevel = world.getProperty("threatLevel") or 1
	local spAmount = nil

	local eliteMonster = config.getParameter("elite", false)

	if threatLevel == 1 then
		spAmount = math.random(1, 5)
		spChanceThreshold = 90
	elseif threatLevel == 2 or 3 then
		spAmount = math.random(5, 10)
		spChanceThreshold = 80
	elseif threatLevel == 4 or 5 then
		spAmount = math.random(10, 15)
		spChanceThreshold = 75
	elseif threatLevel >= 6 then
		spAmount = math.random(15, 25)
		spChanceThreshold = 65
	end

	if eliteMonster then spAmount = spAmount * 2 end

	if spChance >= spChanceThreshold then
		for _, id in pairs(playerList) do
			world.sendEntityMessage(id, "ex.giveskillpoints", spAmount)
		end
	end
end
