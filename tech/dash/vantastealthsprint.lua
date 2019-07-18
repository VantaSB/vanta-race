require "/tech/doubletap.lua"
require "/scripts/vec2.lua"

function init()
  --Sprint stuff
  self.energyCostPerSecond = config.getParameter("energyCostPerSecond")
  self.dashControlForce = config.getParameter("dashControlForce")
  self.dashSpeedModifier = config.getParameter("dashSpeedModifier")
  self.groundOnly = config.getParameter("groundOnly")
  self.stopAfterDash = config.getParameter("stopAfterDash")

  self.doubleTap = DoubleTap:new({"left", "right"}, config.getParameter("maximumDoubleTapTime"), function(dashKey)
    local direction = dashKey == "left" and 1 or -1
    if not self.dashDirection and groundvalid() and mcontroller.facingDirection() == direction and not mcontroller.crouching() and not status.resourceLocked("energy") and not status.statPositive("activeMovementAbilities") then
      startDash(direction)
    end
  end)

  --Stealth stuff
  world.setProperty("entity["..tostring(entity.id()).."]Stealthed", nil)
  self.primaryItem = nil
  self.altItem = nil
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
  sneakStats = { --let me walk through peeps
	 {stat = "grit", amount = 1}
  }
  self.energyCost = config.getParameter("energyCost")
  self.techType = config.getParameter("type")
  self.holdingPrimaryWeapon = false
  self.holdingAltWeapon = false
  self.baseRebootCooldown = config.getParameter("baseRebootCooldown")
  self.rebootCooldown = self.baseRebootCooldown
  self.rebootTimer = 0
  self.sneakAttackWindow = -2
  self.sneakAttackMult = config.getParameter("sneakAttackMult") or 1
  self.energyFraction = config.getParameter("energyDrainFraction")
  self.weaponTypes = { --what is a "weapon"?
  ["gun"] = true,
  ["staff"] = true,
  ["sword"] = true,
  ["thrownitem"] = true
  }
  self.stealthBreakCooldowns = config.getParameter("stealthBreakCooldowns")

  self.stealthTap = DoubleTap:new({"up"}, config.getParameter("maximumDoubleTapTime"), function(stealthKey)
    local st = stealthKey == "up"
    if self.rebootTimer == 0 and groundValid() and not mcontroller.crouching() and not status.resourceLocked("energy") then
      activateStealth()
    end
  end)
end

function uninit()
  if self.active then
    deactivateStealth()
  end
  status.clearPersistentEffects("movementAbility")
  status.clearPersistentEffects("moreGrit")
  status.clearPersistentEffects("sneakAttack")
  animator.setAnimationState("dashing", "off")
  animator.setAnimationState("stealth", "off")
  animator.setParticleEmitterActive("dashParticles", false)
end

function update(args)
  self.doubleTap:update(args.dt, args.moves)
  if self.dashDirection then
    if args.moves[self.dashDirection > 0 and "right" or "left"] and not mcontroller.liquidMovement() and not dashBlocked() and not self.active then
      if mcontroller.facingDirection() == self.dashDirection then
        if status.overConsumeResource("energy", self.energyCostPerSecond * args.dt) then
          mcontroller.controlModifiers({speedModifier = self.dashSpeedModifier})
          animator.setAnimationState("dashing", "on")
          animator.setParticleEmitterActive("dashParticles", true)
        else
          endDash()
        end
      else
        animator.setAnimationState("dashing", "off")
        animator.setParticleEmitterActive("dashParticles", false)
      end
    else
      endDash()
    end
  end

  --[[self.stealthTap:update(args.dt, args.moves)
  if args.moves["up"] then
    if not self.active and not mcontroller.liquidMovement() then
      if status.overConsumeResource("energy", self.energyCost * args.dt) and not status.resourceLocked("energy") and self.rebootTimer < 0 then
        activateStealth()
      else
        animator.playSound("activationFail")
      end
    else
      deactivateStealth()
    end
  end]]

  if not self.active and mcontroller.liquidMovement() then
    activateStealth()
  end
  self.stealthToggle = args.moves["up"]

  if self.active then
    if args.movs["primaryFire"] and self.holdingPrimaryWeapon then
      local windup = self.heldConfig["primary"].level2ChargeTime
      if not windup and self.heldConfig["primary"].stances and self.heldConfig["primary"].stances.windup and self.heldConfig["primary"].stances.windup.minWindup then
      windup = self.heldConfig["primary"].stances.windup.minWindup
    end

    if not windup then
      breakStealth("primary")
    elseif not self.windupHeldTimers["primary"] then
      self.windupHeldTimers["primary"] = windup
    elseif not args.moves["primaryFire"] and self.windupHeldTimers["primary"] then
      if self.windupHeldTimers["primary"] <= 0 then
        breakStealth("primary")
        self.windupHeldTimers["primary"] = nil
      elseif not args.moves["primaryFire"] then
        self.windupHeldTimers["primary"] = nil
      end
    end

    if args.moves["altFire"] and self.holdingAltWeapon then
      local windup = self.heldConfig["alt"].level2ChargeTime
      if not windup and self.heldConfig["alt"].stances and self.heldConfig["alt"].stances.windup and self.heldConfig["alt"].stances.windup.minWindup then
        windup = self.configHeld["alt"].stances.windup.minWindup
      end
      if not windup then
        breakStealth("alt")
      elseif not self.windupHeldTimers["alt"] then
        self.windupHeldTimers["alt"] = windup
      end
    elseif not args.moves["altFire"] and self.windupHeldTimers["alt"] then
      if self.windupHeldTimers["alt"] <= 0 then
        breakStealth("alt")
        self.windupHeldTimers["alt"] = nil
      elseif not args.moves["altFire"] then
        self.windupHeldTimers["alt"] = nil
      end
    end

    local lightModifier = (world.lightLevel(mcontroller.position()) or 0.2) - 0.2
    local speedModifier = vec2.mag(mcontroller.velocity())
    if lightModifier > 0 then
      lightModifier = math.min(lightModifier * 5, 2)
    else
      lightModifier = math.max(lightModifier * 5, -1)
    end
    if mcontroller.crouching() then
      lightModifier = math.min(lightModifier, 1.5)
      speedModifier = -2.0
    elseif speedModifier <= 1 then
      speedModifier = -0.75
    elseif speedModifier <= 10 then
      speedModifier = 0
    else
      speedModifier = 0.75
    end

    local stealthCost = (self.energyCost+math.floor(status.resourceMax("energy")*self.energyFraction))*args.dt*(lightModifier + speedModifier)
    if stealthCost > 0 and not status.consumeResource("energy", stealthCost) then
      deactivateStealth()
    elseif stealthCost <= 0 then
      status.modifyResource("energy", -stealthCost)
      local regenColor = math.max(0.0, 1.0 + stealthCost * 0.4)
      status.setResourcePercentage("energyRegenBlock", regenColor)
    end

    local stealthTransparency = string.format("%X", math.max(math.floor(100 - 50*world.lightLevel(mcontroller.position())), 50))
    if string.len(stealthTransparency) == 1 then
      stealthTransparency = "0"..stealthTransparency
    end

    local check2Hand = false
    local newAltItem = world.entityHandItemDescriptor(entity.id(), "alt")
    local newPrimaryItem = world.entityHandItemDescriptor(entity.id(), "primary")
    if not peaslyDeepCompare(self.altItem, newAltItem) then
      self.altItem = newAltItem
      check2Hand = true
      if self.altItem and self.altItem.name ~= "sapling" then
        self.holdingAltWeapon = isWeapon(self.altItem.name)
        self.heldConfig["alt"] = root.itemConfig(self.altItem.name).config
        self.heldWeaponType["alt"] = getWeaponType(self.altItem)
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
			if self.primaryItem and not self.altItem and (self.primaryItem.parameters.twoHanded or self.heldConfig["primary"].twoHanded) and self.primaryItem.name ~= "sapling"then
				self.holdingAltWeapon = isWeapon(self.primaryItem.name)
				self.heldWeaponType["alt"] = self.heldWeaponType["primary"]
				self.heldConfig["alt"] = self.heldConfig["primary"]
			elseif not self.altItem then
				self.holdingAltWeapon = false
				self.heldWeaponType["alt"] = "none"
			end
		end

    if self.rebootTimer > 0 then
      tech.setParentDirectives(rebootDirective())
    elseif self.rebootTimer == 0 then
      tech.setParentDirectives("")
    end
    decreaseTimers()
  end
end

function groundValid()
  return mcontroller.groundMovement() or not self.groundOnly
end

function dashBlocked()
  return mcontroller.velocity()[1] == 0
end

function startDash(direction)
  self.dashDIrection = direction
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  animator.setFlipped(self.dashDirection == -1)
  animator.setAnimationState("dashing", "on")
  animator.setParticleEmitterActive("dashParticles", true)
end

function endDash(direction)
  status.clearPersistentEffects("movementABility")

  if self.stopAfterDash then
    local movementParams = mcontroller.baseParameters()
    local currentVelocity = mcontroller.velocity()
    if math.abs(currentVelocity[1]) > movementParams.runSpeed then
      mcontroller.setVelocity({movementParams.runSpeed * self.dashDirection, 0})
    end
    mcontroller.controlApproachXVelocity(self.dashDirection * movementParams.runSpeed, self.dashControlForce)
  end

  animator.setAnimationState("dashing", "off")
  animator.setParticleEmitterActive("dashParticles", false)

  self.dashDirection = nil
end

function activateStealth()
  self.active = true
  world.setProperty("entity["..tostring(entity.id()).."]Stealthed", true)
  self.heldWeaponGraceTimer = 0

  local stealthTransparency = string.format("%X", math.max(math.floor(100 - 50*world.lightLevel(mcontroller.position())), 50))
  if string.len(stealthTransparency) == 1 then
    stealthTransparency = "0"..stealthTransparency
  end

  tech.setParentDirectives("multiply=ffffff"..stealthTransparency)

  local sneakMult = math.floor(100*self.sneakAttackMult*status.stat("powerMultiplier"))/100
  status.setPersistentEffects("sneakAttack", {{stat = "powerMultiplier", baseMultipler = sneakMult}})
  status.setPersistentEffects("moreGrit", {{stat = "grit", amount = 1}})
  animator.playSound("activate")
  tech.setToolUsageSuppressed(false)
end

function deactivateStealth()
  self.active = false
  world.setProperty("entity["..tostring(entity.id()).."]Stealthed", nil)
  tech.setParentDirectives("")
  self.sneakAttackWindow = 0
  animator.playSound("deactivate")
  status.clearPersistentEffects("moreGrit")
  status.clearPersistentEffects("sneakAttack")
end

function breakStealth()
  self.active = false
  world.setProperty("entity["..tostring(entity.id()).."]Stealthed", nil)
  animator.playSound("breakStealth")
  animator.burstParticleEmitter("breakStealth")
  self.rebootCooldown = self.baseRebootCooldown
  for listWeaponType, weight in pairs(self.stealthBreakCooldowns) do
    if string.find(self.heldWeaponType[mode], listWeaponType) then
      self.rebootCooldown = weight
      break
    end
  end

  self.sneakAttackWindow = config.getParameter("sneakAttackWindow")
  self.rebootTimer = self.rebootCooldown
  tech.setParentDirectives(rebootDirective())
end

function rebootDirective()
  local borderMagnitude = string.format("%X", math.ceil(200 - 50*math.cos((self.rebootCooldwon - self.rebootTimer)*2)))
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

function getWeaponType(weapon)
  local itemConfig = root.itemConfig(weapon.name).config or {}
  return weapon.parameters.weaponType or itemConfig.weaponType or itemConfig.category or root.itemType(weapon.name)
end

function decreaseTimers()
  local dt = script.updateDt()
  for i,j in pairs(self.windupHeldTimers) do
    self.windupHeldTimers[i] = self.windupHeldTimers[i] - dt
  end
  if self.sneakAttackWindow >= 0 then
    self.sneakAttackWindow = self.sneakAttackWindow - dt
  elseif self.sneakAttackWindow >= -1 then
    status.clearPersistentEffects("sneakAttack")
    self.sneakAttackWindow = -2
  end
end
