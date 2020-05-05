require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

DarkSlice = WeaponAbility:new()

function DarkSlice:init()
  self.cooldownTimer = self.cooldownTime
end

function DarkSlice:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil and self.fireMode == "alt" and self.cooldownTimer == 0 and status.overConsumeResource("energy", self.energyUsage) then
    self:setState(self.windup)
  end
end

function DarkSlice:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  util.wait(self.stances.windup.duration)

  self:setState(self.fire)
end

function DarkSlice:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self:damageAmount()
  }
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false, params)

  animator.playSound(self:slashSound())

  util.wait(self.stances.fire.duration)
  self.cooldownTimer = self.cooldownTime
end

function DarkSlice:slashSound()
  return self.weapon.elementalType.."TravelSlash"
end

function DarkSlice:aimVector()
  return {mcontroller.facingDirection(), 0}
end

function DarkSlice:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end

function DarkSlice:uninit()
end
