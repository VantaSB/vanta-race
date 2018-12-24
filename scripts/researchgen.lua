require "/scripts/util.lua"

researchgen = {}
disabled = false
unhandled = {}
researchgen.itemTypes = nil

function researchgen.init()
  if storage == nil then
    storage = {}
  end
  if storage.init == nil then
    storage.init = true
  end
  storage.disabled = (entity.entityType() ~= "object")
  if storage.disabled then
    sb.logInfo("researchgen automation functions are not compatible with non-object types (this type is \'%s\').", entityType.entityType())
    return
  end
  storage.position = entity.position()
end

function researchgen.loadCont()
  storage.containerId = entity.id()
  researchgen.unloadCont()
  storage.inContainer[storage.containerId] = storage.position
  storage.outContainer[storage.containerId] = storage.position
end

function researchgen.unloadCont()
  storage.inContainer={}
  storage.outContainer={}
end

function researchgen.containerAwake(targetContainer, targetPos)
  if type(targetPos) ~= "table" then
		return nil,nil
	elseif util.tableSize(targetPos) > 2 then
		targetPos={targetPos[1],targetPos[2]}
	elseif util.tableSize(targetPos)<2 then
		return nil,nil
	end
	local awake = researchgen.zoneAwake(researchgen.pos2Rect(targetPos,0.1))
	if awake == nil then
		return nil,nil
	elseif awake then
		ping = world.objectAt(targetPos)
		if ping ~= nil then
			if ping ~= targetContainer then
				if world.containerSize(ping) ~= nil then
					return true, ping
				else
					return false,nil
				end
			else
				return true,nil
			end
		else
			return false,nil
		end
	end
	return nil,nil
end

function researchgen.zoneAwake(targetBox)
	if storage.disabled then return end
	if type(targetBox) ~= "table" then
		dbg({"zoneawake failure, invalid input:", targetBox})
		return nil
	else
		if util.tableSize(targetBox) ~= 4 then
			dbg({"zoneawake failure, invalid input:", targetBox})
			return nil
		end
	end
	if not world.regionActive(targetBox) then
		world.loadRegion(targetBox)
	else
		return true
	end
	if world.regionActive(targetBox) then
		return true
	else
		return false
	end
end

function researchgen.throwItemsAt(target, targetPos, item, drop)
  if item.count ~= math.floor(item.count) or item.count <= 0 then return false end

  drop = drop or false

  if target == nil and targetPos == nil then
    if drop then
      world.spawnItem(item, entity.position())
      return true, item.count, true
    else
      return false
    end
  end

  local awake, ping = researchgen.containerAwake(target, targetPos)
  if awake then
    if ping ~= nil then
      target = ping
    end
  elseif drop then
		world.spawnItem(item,entity.position())
		return true,item.count,true
	else
		return false
	end

	if world.containerSize(target) == nil or world.containerSize(target) == 0 then
		if drop then
			world.spawnItem(item, targetPos)
			return true, item.count,true
		else
			return false
		end
	end

	local leftOverItems = world.containerAddItems(target, item)
	if leftOverItems ~= nil then
		if drop then
			world.spawnItem(leftOverItems, targetPos)
			return true, item.count, true
		else
			return true, item.count - leftOverItems.count
		end
	else
		return true, item.count
	end

	return false;

end

function researchgen.pos2Rect(pos,size)
	if not size then size = 0 end
	return({pos[1]-size,pos[2]-size,pos[1]+size,pos[2]+size})
end

function researchgen.getType(item)
  if not item.name then
    return "unhandled"
  elseif item.name == "sapling" then
    return item.name
  elseif item.currency then
    return "currency"
  end
  local itemRoot = root.itemConfig(item)
  if itemRoot.category then
    itemCat = itemRoot.category
  elseif itemRoot.config.category then
    itemCat = itemRoot.config.category
  elseif itemRoot.config.projectileType then
    itemCat = "throwableitem"
  end
  if itemCat then
    return string.lower(itemCat)
  elseif not unhandled[item.name] then
    unhandled[item.name] = true
  end
  return "unhandled"
end

function update(dt)
  researchgen.loadCont()
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
