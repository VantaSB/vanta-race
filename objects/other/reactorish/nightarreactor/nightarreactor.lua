require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  self.uniqueId = config.getParameter("uniqueId")
  self.msgHandler = config.getParameter("msgHandler")
  if not self.uniqueId or not self.msgHandler then
    self.uniqueId = "null"
    self.msgHandler = "null"
    self.stock = 0
    animator.setAnimationState("base", "active")
    animator.setAnimationState("orb", "inactive")
    sb.logInfo("Reactor at position %s missing configuration parameters, no messages will be handled.", object.position())
  else
    object.setUniqueId(self.uniqueId)
    message.setHandler(self.msgHandler, function() checkPower() end)
    animator.setAnimationState("base", "active")
    animator.setAnimationState("orb", "active")
    self.power = config.getParameter("stock") or 6

    --sb.logInfo("Reactor at position %s configured: uniqueId = %s  |  msgHandler = %s  |  stock = %s", object.position(), self.uniqueId, self.msgHandler, self.power)
  end
  object.setOutputNodeLevel(0, false)
end

function checkPower()
  self.power = self.power - 1
  if self.power == 0 then
    animator.setAnimationState("base", "inactive")
    animator.setAnimationState("orb", "inactive")
    world.spawnProjectile("electricexplosion", object.toAbsolutePosition({ 6, 2 }))
    world.spawnProjectile("explosivebarrel", object.toAbsolutePosition({ 4, 3 }))
    world.spawnProjectile("electricexplosion", object.toAbsolutePosition({ 3, 5 }))
    world.spawnProjectile("explosivebarrel", object.toAbsolutePosition({ 1, 8 }))
    world.spawnProjectile("explosivebarrel", object.toAbsolutePosition({ 5, 9 }))
    world.spawnProjectile("electricexplosion", object.toAbsolutePosition({ 0, 10 }))
    world.spawnProjectile("explosivebarrel", object.toAbsolutePosition({ 8, 11 }))
    world.sendEntityMessage("reactorroommanager", "reactorDestroyed")
    object.setOutputNodeLevel(0, true)
    self.uniqueId = object.setUniqueId()
  end
end
