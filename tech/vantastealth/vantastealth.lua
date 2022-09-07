require "/scripts/vec2.lua"

function init()
  self.stealthActive = false
  world.setProperty("entity["..tostring(entity.id()).."]Stealthed", nil)
  self.lastMoves = {} --used to keep track of held buttons
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
  sneakStats = {
    {stat = "grit", amount = 1}
  }
  self.forceWalk = config.getParameter("forceWalk", false)
  self.holdingPrimaryWeapon = false
  self.holdingAltWeapon = false
  self.doubleTapTimer = 0
  self.baseRebootCooldown = config.getParameter("baseRebootCooldown")
  self.rebootCooldown = self.baseRebootCooldown
  self.rebootTimer = 0
  self.sneakAttackWindow = -2
  self.sneakAttackMult = config.getParameter("sneakAttackMult") or 1
  self.energyCost = config.getParameter("energyDrainRate")
  self.energyFraction = config.getParameter("energyDrainFraction")

  self.weaponTypes = {
    ["gun"] = true,
    ["staff"] = true,
    ["sword"] = true,
    ["thrownitem"] = true
  }
  self.stealthBreakCooldowns = config.getParameter("stealthBreakCooldowns")
  --world.sendEntityMessage(entity.id(), "enableTech", "vantastealth")
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

function input(args)
  if args.moves["up"] then
	  if not self.lastMoves["up"] then
		  if self.doubleTapTimer <= 0 then
			  self.doubleTapTimer = 0.25
		  else
			  if self.stealthActive then
				  deactivateStealth()
			  elseif not status.resourceLocked("energy") and self.rebootTimer < 0 and not args.moves["primaryFire"] and not args.moves["altFire"]then
				  activateStealth()
			  else
				  animator.playSound("activationFail")
			  end
			  self.doubleTapTimer = 0
		  end
	  end
  end

  if args.moves["primaryFire"] and self.stealthActive and not self.lastMoves["primaryFire"] and self.holdingPrimaryWeapon then
	local windup = self.heldConfig["primary"].level2ChargeTime
	if not windup and self.heldConfig["primary"].stances and self.heldConfig["primary"].stances.windup and self.heldConfig["primary"].stances.windup.minWindup then
    windup = self.heldConfig["primary"].stances.windup.minWindup
	end
	if not windup then
		breakStealth("primary")
	elseif not self.windupHeldTimers["primary"] then
    self.windupHeldTimers["primary"] = windup
	end
  elseif not args.moves["primaryFire"] and self.windupHeldTimers["primary"] then
    if self.windupHeldTimers["primary"] <=0 then
		breakStealth("primary")
	end
	self.windupHeldTimers["primary"] = nil
  elseif not args.moves["primaryFire"] then
    self.windupHeldTimers["primary"] = nil
  end

  if args.moves["altFire"] and self.stealthActive and not self.lastMoves["altFire"] and self.holdingAltWeapon then
    local windup = self.heldConfig["alt"].level2ChargeTime
	if not windup and self.heldConfig["alt"].stances and self.heldConfig["alt"].stances.windup and self.heldConfig["alt"].stances.windup.minWindup then
		windup = self.heldConfig["alt"].stances.windup.minWindup
	end
	if not windup then
		breakStealth("alt")
	elseif not self.windupHeldTimers["alt"] then
		self.windupHeldTimers["alt"] = windup
	end
  elseif not args.moves["altFire"] and self.windupHeldTimers["alt"] then
    if self.windupHeldTimers["alt"] <=0 then
		breakStealth("alt")
	end
	self.windupHeldTimers["alt"] = nil
  elseif not args.moves["altFire"] then
    self.windupHeldTimers["alt"] = nil
  end

  self.lastMoves = args.moves
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

function activateStealth()
	self.stealthActive = true
	world.setProperty("entity["..tostring(entity.id()).."]Stealthed", true)
	self.heldWeaponGraceTimer = 0
	local stealthTransparency = string.format("%X", math.max(math.floor(100 - 50*world.lightLevel(mcontroller.position())), 50))
	if string.len(stealthTransparency) == 1 then stealthTransparency = "0"..stealthTransparency end
	tech.setParentDirectives("multiply=000000"..stealthTransparency)
	local sneakMult = math.floor(100*self.sneakAttackMult*status.stat("powerMultiplier"))/100
	status.setPersistentEffects("sneakAttack", {
		{stat = "powerMultiplier", baseMultiplier = sneakMult}
	  })
	status.setPersistentEffects("moreGrit", {
		{stat = "grit", amount = 1}
	  })
    animator.playSound("activate")
	tech.setToolUsageSuppressed(false)
end

function deactivateStealth()
	self.stealthActive = false
	world.setProperty("entity["..tostring(entity.id()).."]Stealthed", nil)
	tech.setParentDirectives("")
	self.sneakAttackWindow = 0
	animator.playSound("deactivate")
	status.clearPersistentEffects("moreGrit")
end

function breakStealth(mode)
	self.stealthActive = false
	world.setProperty("entity["..tostring(entity.id()).."]Stealthed", nil)
	animator.playSound("breakStealth")
	animator.burstParticleEmitter("breakStealth")
	self.rebootCooldown = self.baseRebootCooldown
	for listWeaponType,weight in pairs(self.stealthBreakCooldowns) do
		if string.find(self.heldWeaponType[mode], listWeaponType) then
			self.rebootCooldown = weight
			break
		end
	end
	self.sneakAttackWindow = config.getParameter("sneakAttackWindow")
	self.rebootTimer = self.rebootCooldown
	tech.setParentDirectives(rebootDirective())
end

function update(args)
  input(args)
  if self.doubleTapTimer > 0 then self.doubleTapTimer = self.doubleTapTimer - args.dt end
  if self.rebootTimer > 0 then
	self.rebootTimer = math.max(self.rebootTimer - args.dt, 0)
  elseif self.rebootTimer == 0 then
    self.rebootTimer = -1
  end
  if self.stealthActive then
    if self.forceWalk then
      mcontroller.controlModifiers({runningSuppressed = true})
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
	  else
	    if stealthCost <= 0 then
			status.modifyResource("energy", -stealthCost)
			local regenColor = math.max(0.0, 1.0 + stealthCost * 0.4)
			status.setResourcePercentage("energyRegenBlock", regenColor)
		end
		local stealthTransparency = string.format("%X", math.max(math.floor(100 - 50*world.lightLevel(mcontroller.position())), 50))
		if string.len(stealthTransparency) == 1 then stealthTransparency = "0"..stealthTransparency end
		tech.setParentDirectives("multiply=000000"..stealthTransparency)
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
	  end
  elseif self.rebootTimer > 0 then
	tech.setParentDirectives(rebootDirective())
  elseif self.rebootTimer == 0 then
	tech.setParentDirectives("")
  end
  decreaseTimers()
end

function rebootDirective()
	local borderMagnitude = string.format("%X", math.ceil(130 * (self.rebootTimer*1.3) * 1 / self.rebootCooldown))
	if string.len(borderMagnitude) == 1 then borderMagnitude = "0"..borderMagnitude end
	local borderColor = string.format("%X", math.ceil(200 - 50*math.cos((self.rebootCooldown - self.rebootTimer)*2)))
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

function uninit()
	if self.stealthActive then
		deactivateStealth()
	end
	status.clearPersistentEffects("sneakAttack")
end
