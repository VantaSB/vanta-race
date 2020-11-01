require "/scripts/util.lua"
--require

PrimaryShot = WeaponAbility:new()

function PrimaryShot:init()
  self.shotIndex = math.min(config.getParameter("shotIndex", 1), #self.shotTypes)
  self:loadShot()

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function PrimaryShot:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  if not self.weapon.currentAbility and self.fireMode == (self.activatingFireMode or self.abilitySlot) then
    self:setState(self.switch)
  end
end

function PrimaryShot:switchShot()
  self.shotIndex = (self.shotIndex % #self.shotTypes) + 1
  activeItem.setInstanceValue("shotIndex", self.shotIndex)

  self:loadShot()
end

function PrimaryShot:switchElement()
  self.elementalIndex = (self.elementalIndex % #self.elementalTypes) + 1
  activeItem.setInstanceValue("elementalIndex", self.elementalIndex)

  self.loadElement()
end

function PrimaryShot:loadShot()
  local shot = self.weapon.abilities[self.adaptedAbilityIndex]
  util.mergeTable(shot, self.shotTypes[self.shotIndex])
end

function PrimaryShot:loadElement()
  local element = self.weapon.elements[self.adaptedElementIndex]
  util.mergeTable(element, self.elementalTypes[self.elementalIndex])
end

function PrimaryShot:uninit()
end
