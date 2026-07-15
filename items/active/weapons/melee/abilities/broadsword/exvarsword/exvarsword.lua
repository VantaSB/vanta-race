require "/scripts/util.lua"
require "/items/active/weapons/vantaweapon.lua"
require "/interface/scripted/ex_research/scripts/vantaSkills.lua"

-- Moves to be included:
-- Tenretsujin							Rising Slash
-- Kougenjin								Travelling Swoosh
-- Rakuretsuzan							Pogo Sword

ExVarSword = WeaponAbility:new()
vSaberSkills = {}

function ExVarSword:init()
	--vSaberSkills = listSaberSkills()
	self.cooldownTimer = self.cooldownTime
end

function ExVarSword:update(dt, fireMode, shiftHeld)
	WeaponAbility.update(self, dt, fireMode, shiftHeld)

	self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

	local moves = getTechInput()
	if self.weapon.currentAbility == nil and self.fireMode == "alt" and self.cooldownTimer == 0 then
		if moves == "up" and mcontroller.onGround() then
			self:setState(self.tenretsujin)
		elseif moves == "down" then
			if mcontroller.onGround() then
				self:setState(self.kougenjin)
			else
				self:setState(self.rakuretsuzan)
			end
		end
	end
end

function ExVarSword:tenretsujin()
	sb.logInfo("Skill Activated: Tenretsujin")
	self.cooldownTimer = self.cooldownTime
end

function ExVarSword:kougenjin()
	sb.logInfo("Skill Activated: Kougenjin")
	self.cooldownTimer = self.cooldownTime
end

function ExVarSword:rakuretsuzan()
	sb.logInfo("Skill Activated: Rakuretsuzan")
	self.cooldownTimer = self.cooldownTime
end

function ExVarSword:uninit()
end
