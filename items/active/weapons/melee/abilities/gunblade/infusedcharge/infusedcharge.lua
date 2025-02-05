require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

InfusedCharge = WeaponAbility:new()

primaryAmmoType = "ceruleumcartridge"

function InfusedCharge:init()
  InfusedCharge:reset()

  self.cooldownTimer = 0
end

function InfusedCharge:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if self.cooldownTimer == 0 and not self.weapon.currentAbility and self.fireMode == "alt" and shiftHeld then
    if player.hasItem(primaryAmmoType) then
      self:setState(self.windup)
    else
      animator.playSound("activationFail")
      self.cooldownTimer = self.cooldownTime
      self:setState(self.reset)
    end
  elseif self.cooldownTimer == 0 and not self.weapon.currentAbility and not status.resourceLocked("energy") and self.fireMode == "alt" and not shiftHeld then
    self:setState(self.sliceWindup)
  end
end

function InfusedCharge:windup()
  self.weapon:setStance(self.stances.windup)

  animator.setAnimationState("bladeCharge", "charge")
  animator.setParticleEmitterActive("bladeCharge", true)

  local chargeTimer = self.chargeTime
  while self.fireMode == "alt" do
    chargeTimer = math.max(0, chargeTimer - self.dt)
    if chargeTimer == 0 then
      animator.setGlobalTag("bladeDirectives", "border=3;"..self.chargeBorder..";00000000")
    end
    coroutine.yield()
  end

  if chargeTimer == 0 then
    self:setState(self.slash)
  end
end

function InfusedCharge:sliceWindup()
  self.weapon:setStance(self.stances.sliceWindup)
  self.weapon:updateAim()

  util.wait(self.stances.sliceWindup.duration)

  --self:setState(self.sliceFire)
  if status.overConsumeResource("energy", self.energyUsage) then
    self:setState(self.sliceFire)
  end
end

function InfusedCharge:slash()
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()

  animator.setAnimationState("bladeCharge", "idle")
  animator.setParticleEmitterActive("bladeCharge", false)
  animator.setAnimationState("swoosh", "fire")
  animator.playSound("chargedSwing")

  player.consumeItem(primaryAmmoType, true, false)

  util.wait(self.stances.slash.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea)
  end)

  self.cooldownTimer = self.cooldownTime
end

function InfusedCharge:sliceFire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(), power = self:damageAmount()
  }
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false, params)

  animator.playSound(self:slashSound())

  util.wait(self.stances.fire.duration)
  self.cooldownTimer = self.cooldownTime
end

function InfusedCharge:slashSound()
  return self.weapon.elementalType.."TravelSlash"
end

function InfusedCharge:aimVector()
  return {mcontroller.facingDirection(), 0}
end

function InfusedCharge:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end

function InfusedCharge:reset()
  animator.setGlobalTag("bladeDirectives", "")
  animator.setParticleEmitterActive("bladeCharge", false)
  animator.setAnimationState("bladeCharge", "idle")
end

function InfusedCharge:uninit()
  self:reset()
end
