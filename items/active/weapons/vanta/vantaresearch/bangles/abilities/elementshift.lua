require "/interface/scripted/ex_research/scripts/vantaSkills.lua"

ElementShift = WeaponAbility:new()

function ElementShift:init()
	bangleShotTypes = listBangleAbilities()

	self.shotIndex = config.getParameter("shotIndex", 1)
	self:adaptPrimaryAbility()

	self.weapon.onLeaveAbility = function()
		self.weapon:setStance(self.stances.idle)
	end

	sb.logInfo("Bangle Ability Array: %s", bangleShotTypes)
	sb.logInfo("Shot Index: %s", bangleShotTypes[self.shotIndex])

	local textOffset = {0, 1, 0, 1}
	animator.setParticleEmitterOffsetRegion(bangleShotTypes[self.shotIndex], textOffset)
	animator.burstParticleEmitter(bangleShotTypes[self.shotIndex])
end

function ElementShift:update(dt, fireMode, shiftHeld)
	WeaponAbility.update(self, dt, fireMode, shiftHeld)

	if not self.weapon.currentAbility and self.fireMode == (self.activatingFireMode or self.abilitySlot) then
		if not self.shiftHeld then
			self:setState(self.switchElement)
		end
	end
end

function ElementShift:switchElement()
	bangleShotTypes = listBangleAbilities()

	self.shotIndex = next(bangleShotTypes, self.shotIndex)
	if self.shotIndex == nil then
		self.shotIndex = 1
	end

	activeItem.setInstanceValue("shotIndex", self.shotIndex)

	self:adaptPrimaryAbility()
	animator.playSound("switch")
	local textOffset = {0, 1, 0, 1}
	animator.setParticleEmitterOffsetRegion(bangleShotTypes[self.shotIndex], textOffset)
	animator.burstParticleEmitter(bangleShotTypes[self.shotIndex])

	self.weapon:setStance(self.stances.switch)

	util.wait(self.stances.switch.duration)
end

function ElementShift:adaptPrimaryAbility()
	local ability = self.weapon.abilities[self.adaptedAbilityIndex]
	util.mergeTable(ability, self.shotTypes[self.shotIndex])
end

function ElementShift:uninit()
end
