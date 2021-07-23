function init()
  message.setHandler("timer1", function() preSpawnAnimate() end)
  message.setHandler("timer2", function() spawnAndClose() end)
  animator.setAnimationState("orb", "on")
end

function preSpawnAnimate()
  animator.setAnimationState("portal", "open")
  animator.setAnimationState("orb", "off")
end

function spawnAndClose()
  world.spawnMonster("ceruleumwraithboss", object.toAbsolutePosition({ 0, 0 }))
  animator.setAnimationState("portal", "close")
  animator.setAnimationState("orb", "on")
end
