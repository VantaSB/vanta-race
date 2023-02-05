function init() --when "forgottenmemories" is triggered, re-initialize all stat bonuses
	status.clearPersistentEffects("ex_fireResistance")
	status.clearPersistentEffects("ex_iceResistance")
	status.clearPersistentEffects("ex_electricResistance")
	status.clearPersistentEffects("ex_poisonResistance")
	status.clearPersistentEffects("ex_maxHealth")
	status.clearPersistentEffects("ex_protection")
	status.clearPersistentEffects("ex_maxEnergy")
	status.clearPersistentEffects("ex_energyRegenPercentageRate")
	status.clearPersistentEffects("ex_powerMultiplier")

	self.swimBoost = false
	self.swimMovementParams = {}

	self.runBoost = false
	self.runMovementParams = {}
end

--[[function update(dt)
	if self.swimBoost then
		mcontroller.controlParameters(self.movementParameters)
	end

	if self.runBoost then
		mcontroller.controlModifiers({
			speedModifier = self.speedModifier
		})
	end
end]]

function PlayCinematic(cinematic)
	self.cinematic = config.getParameter("cinematic")
	player.playCinematic(self.cinematic)
end

function ApplyStatIncrease(params)
	--Elemental Resistances
		--fireResistance
		--iceResistance
		--electricResistance
		--poisonResistance
		--ceruleumResistance (TBD)

	--Elemental Status Immunities
		--fireStatusImmunity
		--iceStatusImmunity
		--electricStatusImmunity
		--poisonStatusImmunity
		--ceruleumStatusImmunity (TBD)

	--Core Stats
		--maxHealth
		--protection
		--maxEnergy
		--energyRegenPercentageRate
		--powerMultiplier

	-- Fire resistance
	if params[1] == "elr_fire" then
		status.setPersistentEffects("ex_fireResistance", {
			{stat = "fireResistance", amount = params[2] or 0},
			{stat = "fireStatusImmunity", amount = params[3] or 0}
		})
	end

	-- Ice resistance
	if params[1] == "elr_ice" then
		status.setPersistentEffects("ex_iceResistance", {
			{stat = "iceResistance", amount = params[2] or 0},
			{stat = "iceStatusImmunity", amount = params[3] or 0}
		})
	end

	-- Electric resistance
	if params[1] == "elr_elec" then
		status.setPersistentEffects("ex_elecResistance", {
			{stat = "electricResistance", amount = params[2] or 0},
			{stat = "electricStatusImmunity", amount = params[3] or 0}
		})
	end

	-- Poison resistance
	if params[1] == "elr_poison" then
		status.setPersistentEffects("ex_poisonResistance", {
			{stat = "poisonResistance", amount = params[2] or 0},
			{stat = "poisonStatusImmunity", amount = params[3] or 0}
		})
	end


	-- Health boost
	if params[1] == "hpPlus" then
		status.setPersistentEffects("ex_maxHealth", {
			{stat = "maxHealth", amount = params[2] or 0},
			{stat = "maxHealth", baseMultiplier = params[3] or 1.0},
	    {stat = "maxHealth", effectiveMultiplier = params[4] or 1.0}
		})
	end


	-- Protection boost
	if params[1] == "spPlus" then
		status.setPersistentEffects("ex_protection", {
			{stat = "protection", amount = params[2] or 0}
		})
	end


	-- Energy & energy regen boost
	if params[1] == "epPlus" then
		status.setPersistentEffects("ex_maxEnergy", {
			{stat = "maxEnergy", amount = params[2] or 0},
			{stat = "energyRegenPercentageRate", amount = params[3] or 0},
			{stat = "energyRegenBlockTime", effectiveMultiplier = params[4] or 0}
		})
	end


	-- Damage boost
	if params[1] == "dpsPlus" then
		status.setPersistentEffects("ex_powerMultiplier", {
			{stat = "powerMultiplier", effectiveMultiplier = params[2] or 0}
		})
	end
end

function ApplyMovementParameters(params)
	--General Movement Modifiers
		--jumpModifier
		--gravityModifier
		--speedModifier

	--liquid Movement Modifiers
		--liquidImpedance
		--liquidForce
		--liquidJumpProfile { jumpSpeed }

	if params[1] == "swimBoost" then
		self.swimBoost = true
		self.movementParameters = config.getParameter(params[2])
	end
end

function AddHeadTech(params)
end

function AddBodyTech(params)
end

function AddLegsTech(params)
end
