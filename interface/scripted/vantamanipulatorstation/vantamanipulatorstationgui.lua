require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  self.upgradeList = "modules"
  self.upgradeLockedIcon = config.getParameter("upgradeLockedIcon")

  self.busterUnlocked = false
  self.scanningUnlocked = false
  self.shieldingUnlocked = false
  self.grapplingUnlocked = false
end

function upgradeCost(upgradeName)

end

function setSelectedSlot(slot)

end

function enableModule(upgradeName)

end

function moduleEnabled(upgradeName)

end

function doEnable()
  if self.selectedModule and not moduleEnabled(self.selectedModule) then
    enableModule(self.selctedModule)
  end
end
