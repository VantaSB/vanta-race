require "/scripts/researchgen.lua"

function update(dt)
  researchgen.loadSelfContainer()
  storage.waterCount = math.min((storage.waterCount or 0) + dt, 100)
  for i=2, #config.getParameter('iSlot') do
    if world.containerItemAt(entity.id(), i-1) and world.containerItemAt(entity.id(), i-1).name ~= config.getParameter('iSlot')[i].name then
      world.containerConsumeAt(entity.id(), i-1, world.containerItemAt(entity.id(), i-1).count)
      world.spawnItem(world.containerItemAt(entity.id(), i-1), entity.position())
    end
  end

  local item = world.containerItemAt(entity.id(), 0) or {
    name = config.getParameter('iSlot')[1].name, count = 0
  }
  if item.name ~= config.getParameter('iSlot')[1].name then
    world.spawnItem(item, entity.position())
    world.containerConsumeAt(entity.id(), 0, item.count)
    item.count = 0
  elseif item.count > config.getParameter('iSlot')[1].max then
    local dropitem = item
    dropitem.count = dropitem.count - config.getParameter('iSlot')[1].max
    world.spawnItem(dropitem, entity.position())
    world.containerConsumeAt(entity.id(), 0, dropitem.count)
    item.count = config.getParameter('iSlot')[1].max
  end

  local amt = math.min(math.floor(storage.waterCount/config.getParameter('iSlot')[1].ratio), config.getParameter('iSlot')[1].max - item.count)
  world.containerPutItemsAt(entity.id(), {
    name = config.getParameter('iSlot')[1].name, count = amt
  }, 0)
  storage.waterCount = storage.waterCount - amt * config.getParameter('iSlot')[1].ratio
  if amt > 0 and #config.getParameter('iSlot') > 1 then
    for i=(storage.count or 0)+1, (storage.count or 0)+amt do
      for z=2, #config.getParameter('iSlot') do
        amtMod = math.min(math.floor(math.max(config.getParameter('iSlot')[z].count / config.getParameter('iSlot')[z].amt, 1)), config.getParameter('iSlot')[z].amt)
        if config.getParameter('iSlot')[z].chance > 0 and math.fmod(i, config.getParameter('iSlot')[z].count / amtMod) == 0 and math.random() <= config.getParameter('iSlot')[z].chance then
          world.containerPutItemsAt(entity.id(), {
            name = config.getParameter('iSlot')[z].name, count = config.getParameter('iSlot')[z].amt / amtMod
          }, z - 1)
        end
      end
    end
    storage.count = (storage.count or 0) + amt
  end
end
