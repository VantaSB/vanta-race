require "/interface/scripted/ex_research/scripts/vantaSkills.lua"

ChapterSelect = WeaponAbility:new()

function ChapterSelect:init()
	bangleAbilities = listGrimoireAbilities()
	self.currentChapter = config.getParameter("currentChapter", 1)
	self:adaptAbility()

	self.weapon.onLeaveAbility = function()
		self.weapon:setStance(self.stances.idle)
	end
end

function ChapterSelect:update(dt, fireMode, shiftHeld)
	WeaponAbility.update(self, dt, fireMode, shiftHeld)

	if not self.weapon.currentAbility and self.fireMode == (self.activatingFireMode or self.abilitySlot) then
		self:setState(self.nextChapter)
	end
end

function ChapterSelect:nextChapter()
	bangleAbilities = listGrimoireAbilities()
	--self.currentChapter = (self.currentChapter % #self.shotTypes) + 1

	self.currentChapter = next(bangleAbilities, self.currentChapter)
	if self.currentChapter == nil then
		self.currentChapter = 1
	end

	activeItem.setInstanceValue("currentChapter", self.currentChapter)

	self:adaptAbility()
	animator.playSound("switch")

	self.weapon:setStance(self.stances.switch)

	util.wait(self.stances.switch.duration)
end

function ChapterSelect:adaptAbility()
	local ability = self.weapon.abilities[self.adaptedAbilityIndex]
	util.mergeTable(ability, self.chapters[self.currentChapter])
	activeItem.setInstanceValue("elementalType", ability.elementalType)
end

function element()
	return self.elementalType
end

function ChapterSelect:uninit()
end
