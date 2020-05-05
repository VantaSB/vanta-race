require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

function init()
  self.weapon = Weapon:new()

  self.weapon:addTransformationGroup("weapon", {0, 0}, 0)

  local primaryAbility = getPrimaaryAbility()
  self.weapon:addAbility(primaryAbility)

  self.weapon:init()
end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
end

function unit()
  self.weapon:uninit()
end
