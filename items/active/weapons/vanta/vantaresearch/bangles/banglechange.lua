require "/interface/scripted/ex_research/scripts/vantaSkills.lua"

BangleChange = WeaponAbility:new()

function BangleChange:init()
	banglePrimaryAbilities = listBanglePrimaryAbilities()
	--bangleAltAbilities = listBangleAltAbilities()
	self.shotIndex = config.getParameter("shotIndex", 1)
	self:adaptPrimaryAbility()

	self.weapon.onLeaveAbility = function()
		self.weapon:setStance(self.stances.idle)
	end

	local textOffsetRegion = {0, 1, 0, 1}
	animator.setParticleEmitterOffsetRegion(banglePrimaryAbilities[self.shotIndex], textOffsetRegion)
	animator.burstParticleEmitter(banglePrimaryAbilities[self.shotIndex])
end

function BangleChange:update(dt, fireMode, shiftHeld)
	WeaponAbility.update(self, dt, fireMode, shiftHeld)

	if not self.weapon.currentAbility and self.fireMode == (self.activatingFireMode or self.abilitySlot) then
		if not self.shiftHeld then
			self:setState(self.switchPrimaryShot)
		--else
			--self:setState(self.switchAltShot)
		end
	end
end

function BangleChange:switchPrimaryShot()
	banglePrimaryAbilities = listBanglePrimaryAbilities()

	self.shotIndex = next(banglePrimaryAbilities, self.shotIndex)
	if self.shotIndex == nil then
		self.shotIndex = 1
	end

	activeItem.setInstanceValue("shotIndex", self.shotIndex)

	self:adaptPrimaryAbility()
	animator.playSound("switch")
	local textOffsetRegion = {0, 1, 0, 1}
	animator.setParticleEmitterOffsetRegion(banglePrimaryAbilities[self.shotIndex], textOffsetRegion)
	animator.burstParticleEmitter(banglePrimaryAbilities[self.shotIndex])

	self.weapon:setStance(self.stances.switch)

	util.wait(self.stances.switch.duration)
end

--[[function BangleChange:switchAltShot()
	bangleAltAbilities = listBangleAltAbilities()

	self.shotIndex = next(bangleAltAbilities, self.shotIndex)
	if self.shotIndex == nil then
		self.shotIndex = 1
	end

	activeItem.setInstanceValue("shotIndex", self.shotIndex)

	self:adaptAltAbility()
	animator.playSound("switch")
	local textOffsetRegion = {0, 1, 0, 1}
	animator.setParticleEmitterOffsetRegion(bangleAltAbilities[self.shotIndex], textOffsetRegion)
	animator.burstParticleEmitter(bangleAltAbilities[self.shotIndex])

	self.weapon:setStance(self.stances.switch)

	util.wait(self.stances.switch.duration)
end]]

function BangleChange:adaptPrimaryAbility()
	local ability = self.weapon.abilities[self.adaptedAbilityIndex]
	util.mergeTable(ability, self.primaryShotTypes[self.shotIndex])
end

--[[function BangleChange:adaptAltAbility()
	local ability = self.weapon.abilities[self.adaptedAbilityIndex]
	util.mergeTable(ability, self.altShotTypes[self.shotIndex])
end]]

function BangleChange:uninit()
end
