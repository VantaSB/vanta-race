require "/scripts/interp.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/ex_utilities/ex_stealthintercept.lua"

function init()
  -- Positions and angles
  self.baseOffset = config.getParameter("baseOffset")
  self.basePosition = vec2.add(object.position(), self.baseOffset)
  self.tipOffset = config.getParameter("tipOffset") --This is offset from BASE position, not object origin

  self.rotationSpeed = util.toRadians(config.getParameter("rotationSpeed"))
  self.offAngle = util.toRadians(config.getParameter("offAngle", -30))

  -- Targeting
  self.targetQueryRange = config.getParameter("targetQueryRange")
  self.targetMinRange = config.getParameter("targetMinRange")
  self.targetMaxRange = config.getParameter("targetMaxRange")
  self.targetAngleRange = util.toRadians(config.getParameter("targetAngleRange"))

  -- Energy
  storage.energy = storage.energy or 0
  self.regenBlockTimer = 0
  self.energyRegen = config.getParameter("energyRegen")
  self.maxEnergy = config.getParameter("maxEnergy")
  self.energyRegenBlock = config.getParameter("energyRegenBlock")

  self.energyBarOffset = config.getParameter("energyBarOffset")
  self.verticalScaling = config.getParameter("verticalScaling")
  animator.translateTransformationGroup("energy", self.energyBarOffset)

  -- Initialize turret
  object.setInteractive(false)

  self.state = FSM:new()
  self.state:set(offState)

	self.maxHealth = config.getParameter("health", 20)
	storage.currentHealth = self.maxHealth
	storage.activeHealth = storage.currentHealth

	storage.newObj = "nightarturretbroken"
	storage.pos = object.position()
	storage.direction = object.direction()
end

function update(dt)
	--sb.logInfo("storage.active = %s", storage.active)
  self.state:update(dt)
	storage.health = object.health()

	if storage.health < storage.currentHealth then
		animator.playSound("hurt")
		storage.currentHealth = object.health()
	end

  world.debugPoint(firePosition(), "green")

  if storage.energy == 0 then
    self.blockEnergyUsage = true
  elseif storage.energy == self.maxEnergy then
    self.blockEnergyUsage = false
  end

  if self.regenBlockTimer > 0 then
    self.regenBlockTimer = math.max(0, self.regenBlockTimer - script.updateDt())
  else
    storage.energy = math.min(self.maxEnergy, storage.energy + self.energyRegen * script.updateDt())
  end

  local ratio = storage.energy / self.maxEnergy
  local animationState = "full"

	if storage.active then
  	if ratio <= 0.75 then animationState = "high" end
  	if ratio <= 0.5 then animationState = "medium" end
  	if ratio <= 0.25 then animationState = "low" end
  	if ratio <= 0 then animationState = "none" end
		animator.setAnimationState("energy", animationState)
	elseif storage.active ~= true or storage.active == nil then
		animator.setAnimationState("energy", "none")
	end

  local scale = self.verticalScaling and {1, ratio * 11} or {ratio * 11, 1}

  animator.resetTransformationGroup("energy")
  animator.scaleTransformationGroup("energy", scale)
  animator.translateTransformationGroup("energy", self.energyBarOffset)

  --animator.setAnimationState("energy", animationState)
end

----------------------------------------------------------------------------------------------------------
-- States

function offState()
	storage.active = false
  animator.setAnimationState("attack", "dead")
	animator.setAnimationState("energy", "none")
  animator.playSound("powerDown")
  object.setAllOutputNodes(false)

  while true do
    animator.rotateGroup("gun", self.offAngle)

    if active() then break end
    coroutine.yield()
  end

  animator.playSound("powerUp")

  self.state:set(scanState)
end

function scanState()
	storage.active = true
  animator.setAnimationState("attack", "idle")
  util.wait(0.5)
  animator.playSound("scan")
  object.setAllOutputNodes(false)

  local timer = 0

  local scanInterval = config.getParameter("scanInterval")
  local scanAngle = util.toRadians(config.getParameter("scanAngle"))

  local scan = coroutine.wrap(function()
    while true do
      local target = findTarget()
      if target then return self.state:set(fireState, target) end
      util.wait(1.0)
    end
  end)

  while true do
    timer = timer + script.updateDt() / scanInterval
    if timer > 1 then timer = 0 end
    animator.rotateGroup("gun", scanAngle * math.sin(timer * math.pi*2))

    scan()

    if not active() then break end
    coroutine.yield()
  end

  self.state:set(offState)
end

function fireState(targetId)
  animator.setAnimationState("attack", "attack")
  animator.playSound("foundTarget")
  object.setAllOutputNodes(true)

  local maxFireAngle = util.toRadians(config.getParameter("maxFireAngle"))
  local fire = coroutine.wrap(autoFire)

  while true do
    if not active() then return self.state:set(offState) end

    if not world.entityExists(targetId) then break end

    local targetPosition = world.entityPosition(targetId)
    local toTarget = world.distance(targetPosition, self.basePosition)
    local targetDistance = world.magnitude(toTarget)
    local targetAngle = math.atan(toTarget[2], object.direction() * toTarget[1])

    if targetDistance > self.targetMaxRange or targetDistance < self.targetMinRange or world.lineTileCollision(self.basePosition, targetPosition) then break end
    if math.abs(targetAngle) > self.targetAngleRange then break end

    animator.rotateGroup("gun", targetAngle)

    local rotation = animator.currentRotationAngle("gun")
    if math.abs(util.angleDiff(targetAngle, rotation)) < maxFireAngle then
      fire()
    end
    coroutine.yield()
  end

  util.wait(1.0)

  self.state:set(scanState)
end

----------------------------------------------------------------------------------------------------------
-- Helping functions, not states

function consumeEnergy(amount)
  if storage.energy <= 0 or self.blockEnergyUsage then return false end
  storage.energy = storage.energy - amount
  self.regenBlockTimer = self.energyRegenBlock
  return true
end

function active()
  if object.isInputNodeConnected(0) then
    return object.getInputNodeLevel(0)
  end

  storage.active = storage.active ~= nil and storage.active or true
  return storage.active
end

function onInputNodeChange(args)
	if object.isInputNodeConnected(0) then
    return object.getInputNodeLevel(0)
  end

  storage.active = storage.active ~= nil and storage.active or true
  return storage.active
end

function firePosition()
  local animationPosition = vec2.div(config.getParameter("animationPosition"), 8)
  local fireOffset = vec2.add(animationPosition, animator.partPoint("gunBg", "projectileSource"))
  return vec2.add(object.position(), fireOffset)
end

-- Coroutine
function autoFire()
  local level = math.max(1.0, world.threatLevel())
  local power = config.getParameter("power", 2)
  power = root.evalFunction("monsterLevelPowerMultiplier", level) * power
  local fireTime = config.getParameter("fireTime", 0.1)
  local projectileParameters = config.getParameter("projectileParameters", {})
  projectileParameters.power = power
  local energyUsage = config.getParameter("energyUsage")

  while true do
    while not consumeEnergy(energyUsage) do coroutine.yield() end

    local rotation = animator.currentRotationAngle("gun")
    local aimVector = {object.direction() * math.cos(rotation), math.sin(rotation)}
    world.spawnProjectile("plasmabullet", firePosition(), entity.id(), aimVector, false, projectileParameters)
    animator.playSound("fire")
    util.wait(fireTime)
  end
end

-- Coroutine
function findTarget()
  local nearEntities = world.entityQuery(self.basePosition, self.targetQueryRange, { includedTypes = { "monster", "player" } })
  return util.find(nearEntities,  function(entityId)
    local targetPosition = world.entityPosition(entityId)
    if not entity.isValidTarget(entityId) or world.lineTileCollision(self.basePosition, targetPosition) then return false end

    local toTarget = world.distance(targetPosition, self.basePosition)
    local targetAngle = math.atan(toTarget[2], object.direction() * toTarget[1])
    return world.magnitude(toTarget) > self.targetMinRange and math.abs(targetAngle) < self.targetAngleRange
  end)
end

function uninit()
	if object.health() <= 0 then
		world.setTileProtection(0, false)
		world.placeObject(storage.newObj, storage.pos, storage.direction)
		world.setTileProtection(0, true)
		sb.logInfo("I am a dead turret")
	end
end
