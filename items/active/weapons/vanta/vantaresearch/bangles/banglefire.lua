require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

BangleFire = WeaponAbility:new()

function BangleFire:init()
  self.weapon:setStance(self.stances.idle)
	self.projectileType = config.getParameter("primaryAbility.projectileType")

  self.cooldownTimer = 0
	self.chargeTimer = 0

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function BangleFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

	self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
		and self.cooldownTimer == 0
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
		and not status.resourceLocked("energy") then

		if not shiftHeld then
			if self.fireType == "auto" and status.overConsumeResource("energy", self:energyPerShot()) then
				self:setState(self.auto)
			elseif self.fireType == "burst" then
				self:setState(self.burst)
			end
		else
			self:setState(self.charge)
		end
  end
end

function BangleFire:charge()
	self.weapon:setStance(self.stances.charge)

	self.chargeTimer = 0

	animator.setAnimationState("firing", "charge", true)
	animator.playSound("charge", 0)
	animator.playSound("chargeloop", -1)

	while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
		self.chargeTimer = self.chargeTimer + self.dt
		coroutine.yield()
	end

	self.chargeLevel = self:currentChargeLevel()
	local energyCost = (self.chargeLevel and self.chargeLevel.energyCost) or 0

	if self.chargeLevel and (energyCost == 0 or status.overConsumeResource("energy", energyCost)) then
		self:setState(self.chargeFire)
	end
end

function BangleFire:chargeFire()
	if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
		animator.setAnimationState("firing", "off")
		self.cooldownTimer = self.chargeLevel.cooldown or 0
		self:setState(self.cooldown, self.cooldownTimer)
		return
	end

	self.weapon:setStance(self.stances.fire)

	--animator.setAnimationState("firing", self.chargeLevel.fireAnimationState or "fire")
	animator.stopAllSounds("charge")
	animator.stopAllSounds("chargeloop")
	animator.playSound(self.chargeLevel.fireSound or "fire")

	self:fireChargeShot()

	if self.stances.fire.duration then
		util.wait(self.stances.fire.duration)
	end

	self.cooldownTimer = self.chargeLevel.cooldown or 0

  self:setState(self.cooldown, self.cooldownTimer)
end

function BangleFire:auto()
  self.weapon:setStance(self.stances.fire)

  self:fireProjectile()
	animator.playSound("fire")

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self.cooldownTimer = self.fireTime
  self:setState(self.cooldown)
end

function BangleFire:burst()
  self.weapon:setStance(self.stances.fire)

  local shots = self.burstCount
  while shots > 0 and status.overConsumeResource("energy", self:energyPerShot()) do
    self:fireProjectile()
    --self:muzzleFlash()
    shots = shots - 1

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.armRotation))

    util.wait(self.burstTime)
  end

  self.cooldownTimer = (self.fireTime - self.burstTime) * self.burstCount
end

function BangleFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
end

function BangleFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
  params.power = self:damagePerShot()
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)

  if not projectileType then
    projectileType = self.projectileType
  end
  if type(projectileType) == "table" then
    projectileType = projectileType[math.random(#projectileType)]
  end

  local projectileId = 0
  for _ = 1, (projectileCount or self.projectileCount) do
    if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
    end

    projectileId = world.spawnProjectile(
        projectileType,
        firePosition or self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(inaccuracy or self.inaccuracy),
        false,
        params
      )
  end
  return projectileId
end

function BangleFire:fireChargeShot()
  local projectileCount = self.chargeLevel.projectileCount or 1

  local params = copy(self.chargeLevel.projectileParameters or {})
  params.power = (self.chargeLevel.baseDamage * config.getParameter("damageLevelMultiplier")) / projectileCount
  params.powerMultiplier = activeItem.ownerPowerMultiplier()

	--[[if self.projectileType == "psiphysicalshot" then
		if self.chargeLevel.level == 1 then
			self.chargeProjectile = "psiphysicalshot"
		elseif self.chargeLevel.level == 2 then
			self.chargeProjectile = "psiphysicalshot2"
		elseif self.chargeLevel.level == 3 then
			self.chargeProjectile = "psiphysicalshot3"
		end
	elseif self.projectileType == "psifireshot" then
		if self.chargeLevel[1] then
			self.chargeProjectile = "psifireshot"
		elseif self.chargeLevel.level == 2 then
			self.chargeProjectile = "psifireshot2"
		elseif self.chargeLevel.level == 3 then
			self.chargeProjectile = "psifireshot3"
		end
	elseif self.projectileType == "psiiceshot" then
		if self.chargeLevel.level == 1 then
			self.chargeProjectile = "psiiceshot"
		elseif self.chargeLevel.level == 2 then
			self.chargeProjectile = "psiiceshot2"
		elseif self.chargeLevel.level == 3 then
			self.chargeProjectile = "psiiceshot3"
		end
	elseif self.projectileType == "psielectricshot" then
		if self.chargeLevel.level == 1 then
			self.chargeProjectile = "psielectricshot"
		elseif self.chargeLevel.level == 2 then
			self.chargeProjectile = "psielectricshot2"
		elseif self.chargeLevel.level == 3 then
			self.chargeProjectile = "psielectricshot3"
		end
	elseif self.projectileType == "psipoisonshot" then
		if self.chargeLevel.level == 1 then
			self.chargeProjectile = "psipoisonshot"
		elseif self.chargeLevel.level == 2 then
			self.chargeProjectile = "psipoisonshot2"
		elseif self.chargeLevel.level == 3 then
			self.chargeProjectile = "psipoisonshot3"
		end
	end]]

	self.chargeProjectile = self.projectileType

	if self.chargeLevel.level == 3 then
		animator.setAnimationState("firing", self.chargeLevel.fireAnimationState or "fullchargefire")
	else
		animator.setAnimationState("firing", self.chargeLevel.fireAnimationState or "chargefire")
	end

  local spreadAngle = util.toRadians(self.chargeLevel.spreadAngle or 0)
  local totalSpread = spreadAngle * (projectileCount - 1)
  local currentAngle = totalSpread * -0.5
  for _ = 1, projectileCount do
    if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
    end

    world.spawnProjectile(
        self.chargeProjectile,
        self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(currentAngle, self.chargeLevel.inaccuracy or 0),
        false,
        params
      )

    currentAngle = currentAngle + spreadAngle
  end
end

function BangleFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function BangleFire:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function BangleFire:energyPerShot()
  return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0)
end

function BangleFire:damagePerShot()
  return (self.baseDamage or (self.baseDps * self.fireTime)) * (self.baseDamageMultiplier or 1.0) * config.getParameter("damageLevelMultiplier") / self.projectileCount
end

function BangleFire:currentChargeLevel()
  local bestChargeTime = 0
  local bestChargeLevel
  for _, chargeLevel in pairs(self.chargeLevels) do
    if self.chargeTimer >= chargeLevel.time and self.chargeTimer >= bestChargeTime then
      bestChargeTime = chargeLevel.time
      bestChargeLevel = chargeLevel
    end
  end
  return bestChargeLevel
end

function BangleFire:uninit()
end
