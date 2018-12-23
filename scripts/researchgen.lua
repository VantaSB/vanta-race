require "/scripts/util.lua"

function researchgen.init()
  if storage == nil then
    storage = {}
  end
  if storage.init == nil then
    storage.init = true
  end
  storage.disabled = (entity.entityType() ~= "object")
  if storage.disabled then
    sb.logInfo("researchgen automation functions are not compatible with non-object types (current type: %s).", entityType.entityType())
    return
  end
  storage.position=entity.position()
end

function researchgen.loadCont()
  storage.containerId = entity.id()
  researchgen.unloadCont()
  storage.inCont[storage.containerId] = storage.position
  storage.outCont[storage.containerId] = storage.position
end

function researchgen.unloadCont()
  storage.inCont={}
  storage.outCont={}
end

function gen(dt)
  researchgen.loadCont()
  storage.waterCount = math.min( (storage.waterCount or 0)+dt, 100 )
  for i=2,#config.getParameter('slot') do
    if world.containerItemAt(entity.id(), i-1) and
    world.containerItemAt(entity.id(), i-1).name ~=
    config.getParameter('slot')[i].name then
      world.containerConsumeAt( entity.id(), i-1,world.containerItemAt(entity.id(), i-1).count )
      world.spawnItem( world.containerItemAt(entity.id(),i-1), entity.position() )
    end
  end

  local item = world.containerItemAt(entity.id(),0) or { name = config.getParameter('slot')[1].name, count = 0 }
  if item.name ~= config.getParameter('slot')[1].name then
    world.spawnItem(item, entity.position())
    world.containerConsumeAt(entity.id(), 0, item.count)
    item.count = 0
  elseif item.count > config.getParameter('sloit')[1].max then
    local dropitem = dropitem.count - config.getParameter('slot')[1].max
    world.spawnItem(dropitem, entity.position())
    world.containerConsumeAt(entity.id(), 0, dropitem.count)
    item.count = config.getParameter('slot')[1].max
  end

  local amt = math.min(math.floor(storage.waterCount/config.getParameter('slot')[1].ratio), config.getParameter('slot')[1].max - item.count)
  world.containerPutItemsAt(entity.id(), {
    name = config.getParameter('slot')[1].name, count = amount
  }, 0)
  storage.waterCount = storage.waterCount - amt * config.getParameter('slot')[1].ratio
  if amt > 0 and #config.getParameter('slot') > 1 then
    for i=(storage.count or 0)+1, (storage.count or 0)+amt do
      for z=2, #config.getParameter('slot') do
        amtMod = math.min(math.floor(math.max(config.getParameter('slot')[z].count / config.getParameter('slot')[z].amt, 1)), config.getParameter('slot')[z].amt)
        if config.getParameter('slot')[z].chance > 0 and math.fmod(i, config.getParameter('slot')[z].count / amtMod) == 0 and math.random() <= config.getParameter('slot')[z].chance then
          world.containerPutItemsAt(entity.id(), {
            name = config.getParameter('slot')[z].name, count = config.getParameter('slot')[z].amt / amtMod
          }, z - 1)
        end
      end
    end
    storage.count = (storage.count or 0) + amt
  end
end
