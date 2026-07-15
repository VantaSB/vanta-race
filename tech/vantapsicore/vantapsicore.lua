require "/tech/doubletap.lua"
require "/scripts/vec2.lua"

-- Modes:
	-- none (default, prevent usage of dashing/sprinting if respective techs are not unlocked)
	-- dash
	-- blinkdash
	-- sprint

function init()
	self.dashTechs = {}
	self.airDashing = self.airDashing or false
	self.groundOnly = self.groundOnly or false
	self.dashMode = self.dashMode or "none" --global dash / blinkdash / sprint indicator
	self.dashDirection = 0
	self.dashTimer = 0
	self.dashCooldownTimer = 0
	self.dashControlForce = config.getParameter("dashControlForce")
	self.dashSpeed = config.getParameter("dashSpeed")
	self.sprintSpeedModifier = config.getParameter("sprintSpeedModifier")
	self.dashDuration = config.getParameter("dashDuration")
	self.dashCooldown = config.getParameter("dashCooldown")
	self.blinkMode = "none" --specifically for blinkdash
	self.blinkDistance = config.getParameter("blinkDistance")
	self.blinkCooldown = config.getParameter("blinkCooldown")
	self.blinkInTime = config.getParameter("blinkInTime")
	self.blinkOutTime = config.getParameter("blinkOutTime")
	self.stopAfterDash = config.getParameter("stopAfterDash")
	self.maxDoubleTapTime = config.getParameter("maxDoubleTapTime")
	self.energyCostPerSecond = config.getParameter("sprintEnergyCostPerSecond")

	self.rechargeEffectTimer = 0
	self.rechargeEffectTime = config.getParameter("rechargeEffectTime", 0.1)
	self.rechargeDirectives = config.getParameter("rechargeDirectives", "?fade=ccccffff=0.25")

	self.switchTimer = 0
	self.switchEffectTimer = 0
	self.switchEffectTime = 0.1
	self.switchDirectives = "?fade=ff99ffff=0.25"

	self.stealthAvailable = self.stealthAvailable or false
	self.stealthActive = false
	self.stealthDrainRate = config.getParameter("stealthDrainRate")
	self.stealthDrainFraction = config.getParameter("stealthDrainFraction")
	self.forceWalk = config.getParameter("forceWalk", true)
	self.stealthBaseCooldown = config.getParameter("stealthBaseCooldown")
	self.stealthRechargeTimer = 0
	self.primaryItem = nil
	self.altItem = nil
	self.holdingPrimaryWeapon = false
  self.holdingAltWeapon = false
	self.heldWeaponType = {
	  primary = "none",
	  alt = "none"
  }
  self.heldConfig = {
	  primary = {},
	  alt = {}
  }
  self.windupHeldTimers = {
	  primary = nil,
	  alt = nil
  }
  sneakStats = {
    {stat = "grit", amount = 1}
  }
	self.weaponTypes = {
    ["gun"] = true,
    ["staff"] = true,
    ["sword"] = true,
    ["thrownitem"] = true
  }
	self.sneakAttackWindow = -2
	self.sneakAttackMult = config.getParameter("sneakAttackMult")
  self.stealthBreakCooldowns = config.getParameter("stealthBreakCooldowns")
	world.setProperty("entity["..tostring(entity.id()).."]Stealthed", nil)

	message.setHandler("ex.enabledTechsResponse", function(_, _, enabledTechs)
  	for _, tech in pairs(enabledTechs) do
    	if tech == "dash" or tech == "sprint" or tech == "blinkdash" then
      	table.insert(self.dashTechs, tech)
				if self.dashMode == "none" then self.dashMode = "dash" else self.dashMode = self.dashMode end
			elseif tech == "airdash" then
				self.airDashing = true
				self.groundOnly = false
			elseif tech == "vantastealth1" then
				self.stealthAvailable = true
				self.forceWalk = true
			elseif tech == "vantastealth2" then
				self.stealthAvailable = true
				self.forceWalk = false
    	end
  	end
	end)

	world.sendEntityMessage(entity.id(), "ex.enabledTechs")

	self.doubleTapDash = DoubleTap:new({"left", "right"}, self.maxDoubleTapTime, function(dashKey)
		if self.dashMode == "dash" then
			if self.dashTimer == 0
      and self.dashCooldownTimer == 0
      and groundValid()
      and not mcontroller.crouching()
      and not status.statPositive("activeMovementAbilities") then
        startDash(dashKey == "left" and -1 or 1)
      end
		elseif self.dashMode == "blinkdash" then
			if self.blinkMode == "none"
      and self.dashCooldownTimer == 0
      and groundValid()
      and not mcontroller.crouching()
      and not status.statPositive("activeMovementAbilities") then
        self.targetPosition = findTargetPosition(dashKey == "left" and -1 or 1, self.blinkDistance)
      	if self.targetPosition then self.blinkMode = "start" end
      end
		elseif self.dashMode == "sprint" then
			local direction = dashKey == "left" and -1 or 1
      if not self.sprintDirection
      and groundValid()
      and mcontroller.facingDirection() == direction
      and not mcontroller.crouching()
      and not status.resourceLocked("energy")
      and not status.statPositive("activeMovementAbilities") then
        startSprint(direction)
      end
		end
	end)

	self.doubleTapStealth = DoubleTap:new({"up"}, self.maxDoubleTapTime, function(stealthKey)
		if self.stealthActive then
			endStealth()
		else
			if not self.stealthActive and not status.resourceLocked("energy") and self.stealthRechargeTimer == 0 then
				startStealth()
			else
				animator.playSound("activationFail")
			end
		end
	end)

	animator.setAnimationState("dashing", "off")
	animator.setAnimationState("sprinting", "off")
end

function update(args)
	if args.moves["up"] then
		world.sendEntityMessage(entity.id(), "ex.techInput", "up")
	elseif args.moves["down"] then
		world.sendEntityMessage(entity.id(), "ex.techInput", "down")
	end

	if self.switchTimer > 0 then
		self.switchTimer = math.max(0, self.switchTimer - args.dt)
		if self.switchTimer == 0 then
			self.switchEffectTimer = self.switchEffectTime
			tech.setParentDirectives(self.switchDirectives)
		end
	end

	if self.switchEffectTimer > 0 then
		self.switchEffectTimer = math.max(0, self.switchEffectTimer - args.dt)
		if self.switchEffectTimer == 0 then
			tech.setParentDirectives()
		end
	end

	if self.dashCooldownTimer > 0 then
    self.dashCooldownTimer = math.max(0, self.dashCooldownTimer - args.dt)
    if self.dashCooldownTimer == 0 then
      self.rechargeEffectTimer = self.rechargeEffectTime
      tech.setParentDirectives(self.rechargeDirectives)
			if self.dashMode == "dash" then
      	animator.playSound("dashRecharge")
			elseif self.dashMode == "blinkdash" then
				animator.playSound("blinkRecharge")
			end
    end
  end

  if self.rechargeEffectTimer > 0 then
    self.rechargeEffectTimer = math.max(0, self.rechargeEffectTimer - args.dt)
    if self.rechargeEffectTimer == 0 then
      tech.setParentDirectives()
    end
  end

	if self.stealthRechargeTimer > 0 then
		self.stealthRechargeTimer = math.max(0, self.stealthRechargeTimer - args.dt)
		tech.setParentDirectives(rebootDirective())
		if self.stealthRechargeTimer == 0 then
			tech.setParentDirectives()
		end
	end

	self.doubleTapStealth:update(args.dt, args.moves)

	if self.dashMode == "dash" and not self.stealthActive then
		self.doubleTapDash:update(args.dt, args.moves)
		if self.dashTimer > 0 then
	    mcontroller.controlApproachVelocity({self.dashSpeed * self.dashDirection, 0}, self.dashControlForce)
	    mcontroller.controlMove(self.dashDirection, true)

	    if self.airDashing then
	      mcontroller.setYVelocity(0)
	    end
	    mcontroller.controlModifiers({jumpingSuppressed = true})

	    animator.setFlipped(mcontroller.facingDirection() == -1)

	    self.dashTimer = math.max(0, self.dashTimer - args.dt)

	    if self.dashTimer == 0 then
	      endDash()
	    end
	  end
	end

	if self.dashMode == "blinkdash" and not self.stealthActive then
		self.doubleTapDash:update(args.dt, args.moves)
		if self.blinkMode == "start" then
	    mcontroller.setVelocity({0, 0})
	    tech.setToolUsageSuppressed(true)
	    self.blinkMode = "out"
	    self.blinkTimer = 0
	    animator.playSound("blinkActivate")
	    status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
	  elseif self.blinkMode == "out" then
	    tech.setParentDirectives("?multiply=00000000")
	    animator.setAnimationState("blinking", "out")
	    mcontroller.setVelocity({0, 0})
	    self.blinkTimer = self.blinkTimer + args.dt

	    if self.blinkTimer > self.blinkOutTime then
	      mcontroller.setPosition(self.targetPosition)
	      self.targetPosition = nil
	      self.blinkMode = "in"
	      self.blinkTimer = 0
	    end
	  elseif self.blinkMode == "in" then
	    tech.setParentDirectives()
	    animator.setAnimationState("blinking", "in")
	    mcontroller.setVelocity({0, 0})
	    self.blinkTimer = self.blinkTimer + args.dt

	    if self.blinkTimer > self.blinkInTime then
	      tech.setToolUsageSuppressed(false)
	      self.blinkMode = "none"
	      self.dashCooldownTimer = self.blinkCooldown
	      status.clearPersistentEffects("movementAbility")
	    end
	  end
	end

	if self.dashMode == "sprint" and not self.stealthActive then
		self.doubleTapDash:update(args.dt, args.moves)
		if self.sprintDirection then
	    if args.moves[self.sprintDirection > 0 and "right" or "left"]
	        and not mcontroller.liquidMovement()
	        and not sprintBlocked() then

	      if mcontroller.facingDirection() == self.sprintDirection then
	        if status.overConsumeResource("energy", self.energyCostPerSecond * args.dt) then
	          mcontroller.controlModifiers({speedModifier = self.sprintSpeedModifier})

	          animator.setAnimationState("sprinting", "on")
	          animator.setParticleEmitterActive("sprintParticles", true)
	        else
	          endSprint()
	        end
	      else
	        animator.setAnimationState("sprinting", "off")
	        animator.setParticleEmitterActive("sprintParticles", false)
	      end
	    else
	      endSprint()
	    end
	  end
	end

	if args.moves["up"] and args.moves["down"] and not args.moves["run"] and mcontroller.onGround() and self.switchTimer == 0 and #self.dashTechs > 0 then
		switchDash()
	end

	if self.stealthActive then
		if self.forceWalk then
			mcontroller.controlModifiers({runningSuppressed = true})
		end

		local lightMod = (world.lightLevel(mcontroller.position()) or 0.2) - 0.2
		local speedMod = vec2.mag(mcontroller.velocity())

		if lightMod > 0 then
			lightMod = math.min(lightMod * 5, 2)
		else
			lightMod = math.max(lightMod * 5, -1)
		end

		if mcontroller.crouching() then
			lightMod = math.min(lightMod, 1.5)
			speedMod = -2.0
		elseif speedMod <= 1 then
			speedMod = -0.75
		elseif speedMod <= 10 then
			speedMod = 0
		else
			speedMod = 0.75
		end

		local stealthCost = (self.stealthDrainRate + math.floor(status.resourceMax("energy") * self.stealthDrainFraction)) * args.dt * (lightMod + speedMod)
		if stealthCost > 0 and not status.consumeResource("energy", stealthCost) then
			endStealth()
		elseif stealthCost <= 0 then
			status.modifyResource("energy", -stealthCost)
			local regenColor = math.max(0.0, 1.0 + stealthCost * 0.4)
			status.setResourcePercentage("energyRegenBlock", regenColor)
		end

		local transparency = string.format("%X", math.max(math.floor(100 - 50 * world.lightLevel(mcontroller.position())), 50))
		tech.setParentDirectives("multiply=000000"..transparency)

		local check2Hand = false
		local newAltItem = world.entityHandItemDescriptor(entity.id(), "alt")
		local newPrimaryItem = world.entityHandItemDescriptor(entity.id(), "primary")

		if not peaslyDeepCompare(self.altItem, newAltItem) then
			self.altItem = newAltItem
			check2Hand = true
			if self.altItem and self.altItem.name ~= "sapling" then
				self.holdingAltWeapon = isWeapon(self.altItem.name)
				self.heldConfig["alt"] = root.itemConfig(self.altItem.name).config
				self.heldWeaponType["alt"] = "none"
			else
				self.heldConfig["alt"] = {}
				self.heldWeaponType["alt"] = "none"
			end
		end

		if not peaslyDeepCompare(self.primaryItem, newPrimaryItem) then
			self.primaryItem = newPrimaryItem
			check2Hand = true
			if self.primaryItem and self.primaryItem.name ~= "sapling"then
				self.holdingPrimaryWeapon = isWeapon(self.primaryItem.name)
				self.heldConfig["primary"] = root.itemConfig(self.primaryItem.name).config
				self.heldWeaponType["primary"] = getWeaponType(self.primaryItem)
			else
				self.heldConfig["primary"] = {}
				self.heldWeaponType["primary"] = "none"
			end
		end

		if check2Hand then
			if self.primaryItem and not self.altItem and (self.primaryItem.parameters.twoHanded or self.heldConfig["primary"].twoHanded) and self.primaryItem.name ~= "sapling" then
				self.holdingAltWeapon = isWeapon(self.primaryItem.name)
				self.heldWeaponType["alt"] = self.heldWeaponType["primary"]
				self.heldConfig["alt"] = self.heldConfig["primary"]
			elseif not self.altItem then
				self.holdingAltWeapon = false
				self.heldWeaponType["alt"] = "none"
			end
		end

		if args.moves["primaryFire"] and self.holdingPrimaryWeapon and not self.windupHeldTimers["primary"] then
			local windup = self.heldConfig["primary"].level2ChargeTime
			if not windup and self.heldConfig["primary"].stances then
				windup = self.heldConfig["primary"].stances.windup or self.heldConfig["primary"].stances.basic.windup1
			elseif not self.windupHeldTimers["primary"] then
				self.windupHeldTimers["primary"] = windup
			end
			if not windup then
				breakStealth("primary")
			end
		end

		if args.moves["alt"] and self.holdingAltWeapon and not self.windupHeldTimers["alt"] then
			local windup = self.heldConfig["alt"].level2ChargeTime
			if not windup and self.heldConfig["alt"].stances then
				windup = self.heldConfig["alt"].stances.windup or self.heldConfig["alt"].stances.basic.windup1
			elseif not self.windupHeldTimers["alt"] then
				self.windupHeldTimers["alt"] = windup
			end
			if not windup then
				breakStealth("alt")
			end
		end
		decreaseTimers()
	end
	world.sendEntityMessage(entity.id(), "ex.techInput", "none")
end

function groundValid()
	return mcontroller.groundMovement() or not self.groundOnly
end

function startDash(direction)
	self.dashDirection = direction
	self.dashTimer = self.dashDuration
	self.airDashing = not mcontroller.groundMovement()
	status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
	animator.playSound("startDash")
	animator.setAnimationState("dashing", "on")
	animator.setParticleEmitterActive("dashParticles", true)
end

function endDash()
	status.clearPersistentEffects("movementAbility")

	if self.stopAfterDash then
		local movementParams = mcontroller.baseParameters()
		local currentVelocity = mcontroller.velocity()
		if math.abs(currentVelocity[1]) > movementParams.runSpeed then
			mcontroller.setVelocity({movementParams.runSpeed * self.dashDirection, 0})
		end
		mcontroller.controlApproachXVelocity(self.dashDirection * movementParams.runSpeed, self.dashControlForce)
	end

	self.dashCooldownTimer = self.dashCooldown

  animator.setAnimationState("dashing", "off")
  animator.setParticleEmitterActive("dashParticles", false)
end

function startSprint(direction)
	self.sprintDirection = direction
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  animator.setFlipped(self.sprintDirection == -1)
  animator.setAnimationState("sprinting", "on")
  animator.setParticleEmitterActive("sprintParticles", true)
end

function endSprint()
	status.clearPersistentEffects("movementAbility")

  if self.stopAfterDash then
    local movementParams = mcontroller.baseParameters()
    local currentVelocity = mcontroller.velocity()
    if math.abs(currentVelocity[1]) > movementParams.runSpeed then
      mcontroller.setVelocity({movementParams.runSpeed * self.sprintDirection, 0})
    end
    mcontroller.controlApproachXVelocity(self.sprintDirection * movementParams.runSpeed, self.dashControlForce / 2)
  end

  animator.setAnimationState("sprinting", "off")
  animator.setParticleEmitterActive("sprintParticles", false)

  self.sprintDirection = nil
end

function sprintBlocked()
  return mcontroller.velocity()[1] == 0
end

function findTargetPosition(dir, maxDist)
	local dist = 1
  local targetPosition
  local collisionPoly = mcontroller.collisionPoly()
  local testPos = mcontroller.position()
  while dist <= maxDist do
    testPos[1] = testPos[1] + dir
    if not world.polyCollision(collisionPoly, testPos, {"Null", "Block", "Dynamic", "Slippery"}) then
      local oneDown = {testPos[1], testPos[2] - 1}
      if not world.polyCollision(collisionPoly, oneDown, {"Null", "Block", "Dynamic", "Platform"}) then
        testPos = oneDown
      end
    else
      local oneUp = {testPos[1], testPos[2] + 1}
      if not world.polyCollision(collisionPoly, oneUp, {"Null", "Block", "Dynamic", "Slippery"}) then
        testPos = oneUp
      else
        break
      end
    end
    targetPosition = testPos
    dist = dist + 1
  end

  if targetPosition then
    local towardGround = {testPos[1], testPos[2] - 0.8}
    local groundPosition = world.resolvePolyCollision(collisionPoly, towardGround, 0.8, {"Null", "Block", "Dynamic", "Platform"})
    if groundPosition and not (groundPosition[1] == towardGround[1] and groundPosition[2] == towardGround[2]) then
      targetPosition = groundPosition
    end
  end

  return targetPosition
end

function startStealth()
	self.stealthActive = true
	world.setProperty("entity["..tostring(entity.id()).."]Stealthed", true)

	local transparency = string.format("%X", math.max(math.floor(100 - 50 * world.lightLevel(mcontroller.position())), 50))
	if string.len(transparency) == 1 then transparency = "0"..transparency end

	tech.setParentDirectives("multiply=000000"..transparency)
	tech.setToolUsageSuppressed(false)

	local sneakMult = math.floor(100 * self.sneakAttackMult * status.stat("powerMultiplier")) / 100

	status.setPersistentEffects("sneakAttack", {{ stat = "powerMultiplier", baseMultiplier = sneakMult }})
	status.setPersistentEffects("moreGrit", {{ stat = "grit", amount = 1 }})

	animator.playSound("stealthActivate")
end

function endStealth()
	self.stealthActive = false
	self.sneakAttackWindow = 0

	world.setProperty("entity["..tostring(entity.id()).."]Stealthed", nil)

	tech.setParentDirectives()

	status.clearPersistentEffects("moreGrit")

	animator.playSound("stealthDeactivate")
end

function breakStealth(mode)
	self.stealthActive = false
	world.setProperty("entity["..tostring(entity.id()).."]Stealthed", nil)
	animator.playSound("breakStealth")
	animator.burstParticleEmitter("breakStealth")
	self.stealthRechargeTimer = self.stealthBaseCooldown
	for listWeaponType, weight in pairs(self.stealthBreakCooldowns) do
		if string.find(self.heldWeaponType[mode], listWeaponType) then
			self.stealthBaseCooldown = weight
			break
		end
	end
	self.sneakAttackWindow = config.getParameter("sneakAttackWindow")
end

function switchDash()
	self.switchTimer = 0.25
	local i = 0
	for k, v in ipairs(self.dashTechs) do
		if v == self.dashMode then
			i = k
			break
		end
	end
	i = (i % #self.dashTechs) + 1
	self.dashMode = self.dashTechs[i]
	if self.dashMode == "dash" and self.airDashing then
		self.groundOnly = false
	elseif self.dashMode == "blinkdash" and self.airDasing then
		self.groundOnly = true
	end
	animator.burstParticleEmitter(self.dashMode.."SwitchParticles")
	animator.playSound("switchDash")
end

function rebootDirective()
	local borderMagnitude = string.format("%X", math.ceil(130 * (self.stealthRechargeTimer*1.3) * 1 / self.stealthBaseCooldown))
	if string.len(borderMagnitude) == 1 then borderMagnitude = "0"..borderMagnitude end
	local borderColor = string.format("%X", math.ceil(200 - 50*math.cos((self.stealthBaseCooldown - self.stealthRechargeTimer)*2)))
	borderColor = borderColor.."FF"..borderColor..borderMagnitude
	return "border=2;"..borderColor..";00000000"
end

function peaslyDeepCompare(a1, a2)
	if type(a1) ~= type(a2) then
		return false
	end
	if type(a1) ~= "table" then
		return a1 == a2
	end
	for i,b in pairs(a1) do
		c = a2[i]
		if type(b) ~= type(c) then
			return false
		elseif type(b) == "table" and not peaslyDeepCompare(b, c) then
			return false
		elseif type(b) == "number" and b ~= c then
			return false
		elseif type(b) == "string" and b ~= c then
			return false
		end
	end
	return true
end

function getWeaponType(weapon)
	local itemConfig = root.itemConfig(weapon.name).config or {}
	return weapon.parameters.weaponType or itemConfig.weaponType or itemConfig.category or root.itemType(weapon.name)
end

function decreaseTimers()
  local dt = script.updateDt()
  for i, _ in pairs(self.windupHeldTimers) do
    self.windupHeldTimers[i] = self.windupHeldTimers[i] - dt
  end
  if self.sneakAttackWindow >= 0 then
	self.sneakAttackWindow = self.sneakAttackWindow - dt
  elseif self.sneakAttackWindow >= -1 then
	status.clearPersistentEffects("sneakAttack")
    self.sneakAttackWindow = -2
  end
end

function isWeapon(name)
	if name == "sapling" then return false
	elseif self.weaponTypes[root.itemType(name)] then
		return true
	elseif root.itemHasTag(name, "weapon") then
		return true
	elseif root.itemConfig(name).config.weaponType then
		return true
	end
	return false
end

function uninit()
  status.clearPersistentEffects("movementAbility")
	animator.setAnimationState("sprinting", "off")
  animator.setParticleEmitterActive("sprintParticles", false)
  tech.setParentDirectives()
end
