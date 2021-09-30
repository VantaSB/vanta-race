function init()
  setParticleConfig(0)
  script.setUpdateDelta(1)
end

function setParticleConfig(dt)
  if not particleConfig then
		particleConfig={type = "textured",image = "/animations/fogoverlay/fogoverlay35.png",velocity = {0, 0},approach = {0, 0},destructionAction = "fade",size = 1,layer = "front",variance = {initialVelocity = {0, 0}}}
	end
	particleConfig.position=entity.position()
	particleConfig.timeToLive = dt*10
	particleConfig.destructionTime = dt*4.5
end

function update(dt)
  if world.entityType(entity.id()) ~= "player" then
    effect.expire()
  end
  setParticleConfig(dt)
  world.sendEntityMessage(entity.id(),"ex.spawnParticle",particleConfig)
end

function uninit()

end
