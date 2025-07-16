require "/interface/scripted/ex_research/scripts/vantaSkills.lua"
require "/scripts/vec2.lua"

ElementShift = WeaponAbility:new()

function ElementShift:init()
	self.bangleShotTypes = listBangleAbilities()
	self.shotIndex = config.getParameter("shotIndex", 1)

	-- Ensure shotIndex is valid
	if not self.bangleShotTypes[self.shotIndex] then
		self.shotIndex = 1
	end

	self:adaptPrimaryAbility()

	self.weapon.onLeaveAbility = function()
		self.weapon:setStance(self.stances.idle)
	end

	local textOffset = {0, 1, 0, 1}
	animator.setParticleEmitterOffsetRegion(self.bangleShotTypes[self.shotIndex].emitter, textOffset)
	animator.burstParticleEmitter(self.bangleShotTypes[self.shotIndex].emitter)
end

function ElementShift:update(dt, fireMode, shiftHeld)
	WeaponAbility.update(self, dt, fireMode, shiftHeld)

	if not self.weapon.currentAbility and self.fireMode == (self.activatingFireMode or self.abilitySlot) and not shiftHeld then
		self:setState(self.switchElement)
	end
end

function ElementShift:switchElement()
	self.bangleShotTypes = listBangleAbilities()
	self.shotIndex = (self.shotIndex % #self.bangleShotTypes) + 1
	activeItem.setInstanceValue("shotIndex", self.shotIndex)

	self:adaptPrimaryAbility()
	animator.playSound("switch")
	local textOffset = {0, 1, 0, 1}
	animator.setParticleEmitterOffsetRegion(self.bangleShotTypes[self.shotIndex].emitter, textOffset)
	animator.burstParticleEmitter(self.bangleShotTypes[self.shotIndex].emitter)

	self.weapon:setStance(self.stances.switch)
	util.wait(self.stances.switch.duration)
end

function ElementShift:adaptPrimaryAbility()
	if self.bangleShotTypes[self.shotIndex] then
		local projectileType = self.bangleShotTypes[self.shotIndex].shotType
		for i, shotType in ipairs(self.shotTypes) do
			if shotType.projectileType == projectileType then
				local ability = self.weapon.abilities[self.adaptedAbilityIndex]
				util.mergeTable(ability, shotType)
				return
			end
		end
		sb.logError("Shot type %s not found in shotTypes: %s", projectileType, self.shotTypes)
	else
		sb.logError("Invalid shotIndex %s in bangleShotTypes: %s", self.shotIndex, self.bangleShotTypes)
	end
end

function ElementShift:uninit()
end
