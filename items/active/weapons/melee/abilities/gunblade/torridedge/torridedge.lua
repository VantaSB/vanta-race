require "/scripts/util.lua"
require "/scripts/rect.lua"
require "/scripts/pathing.lua"
require "/items/active/weapons/weapon.lua"

TorridEdge = WeaponAbility:new()

primaryAmmoType = "ceruleumcartridge"

function TorridEdge:init()
  self.cooldownTimer = self.cooldownTime
end

function TorridEdge:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  --if self.cooldownTimer == 0 and self.weapon.currentAbility == nil and self.fireMode == "alt" then
  if self.weapon.currentAbility == nil and fireMode == "alt" and self.cooldownTimer == 0 and mcontroller.onGround() and not status.statPositive("activeMovementAbilities") then
    if player.hasItem(primaryAmmoType) then
      self:setState(self.charge)
    else
      animator.playSound("activationFail")
      self.cooldownTimer = self.cooldownTime
      self:setState(self.reset)
    end
  end
  --[[if self.weapon.currentAbility == nil and fireMode == "alt" and mmcontroller.onGround() and not status.statPositive("activeMovementAbilities") and not status.resourceLocked("energy") then
    self:setState(self.charge)
  end]]
end

function TorridEdge:charge()
  self.weapon.aimAngle = 0
  self.weapon:setStance(self.stances.charge)

  status.setPersistentEffects("torridedgeability", { { stat = "invulnerable", amount = 1.0 }, { stat = "activeMovemenetAbilities", amount = 1.0 }, "icecharge" })
  animator.setAnimationState("blinkCharge", "charge")

  util.wait(self.stances.charge.duration, function(dt)
    mcontroller.controlModifiers({ movementSuppressed = true })
    --self.setState(self.blink)
  end)

  self:setState(self.blink)

  --[[if status.overConsumeResource("energy", self.energyUsage) then
    self.setState(self.blink)
  end]]

  --[[local chargeTimer = self.stances.charge.duration
  while self.fireMode == "alt" do
    chargeTimer = math.max(0, chargeTimer - self.dt)
    coroutine.yield()
  end

  if chargeTimer == 0 then
    self:setState(self.blink)
  end]]
end

function TorridEdge:blink()
  status.setPersistentEffects("torridedgeability", { { stat = "invulnerable", amount = 1.0}, {stat = "activeMovementAbilities", amount = 1} })
  status.addEphemeralEffect("blink")
  
  self.weapon:setStance(self.stances.slash)

  player.consumeItem(primaryAmmoType, true, false)

  -- wait until a certain point in the blink animation
  util.wait(0.25, function(dt)
    mcontroller.controlModifiers({ movementSuppressed = true })
  end)

  -- move to blink position
  local blinkPosition = self:findBlinkPosition()
  mcontroller.setPosition(blinkPosition)

  -- explode, hopefully AFTER we've moved
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self.baseDamage * config.getParameter("damageLevelMultiplier")
  }
  world.spawnProjectile(self.projectileType, mcontroller.position(), activeItem.ownerEntityId(), {0,0}, false, params)

  self.cooldownTimer = self.cooldownTime
end

function TorridEdge:findBlinkPosition()
  local position = mcontroller.position()

  local direction = mcontroller.facingDirection()
  for i = 0, self.maxDistance do
    if direction > 0 then
      position[1] = math.ceil(position[1])
    end

    local yDirs = {0, 1, -1}
    local lastPosition = position[1]
    for _,yDir in ipairs(yDirs) do
      local bounds = rect.translate(mcontroller.boundBox(), {position[1] + direction, position[2] + yDir})
      if not world.rectTileCollision(bounds, {"Null", "Block", "Dynamic", "Slippery"}) then
        position = {position[1] + direction, position[2] + yDir}
        break
      end
    end
    if position[1] == lastPosition or i == self.maxDistance then
      return position
    end
  end
  return mcontroller.position()
end

function TorridEdge:reset()
  status.setPersistentEffects("torridedgeability", {})
end

function TorridEdge:uninit()
  self:reset()
end
