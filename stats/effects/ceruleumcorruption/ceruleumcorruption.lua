function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)

  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.075
  self.tickTime = 5
  self.tickTimer = self.tickTime
end

function update(dt)
  if world.entityType(entity.id()) == "player" then
    status.addEphemeralEffect("ceruleumcorruptionblur")
  else
    effect.expire()
  end
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
      damageSourceKind = "ceruleum",
      sourceEntityId = entity.id()
    })
  end

  effect.setParentDirectives(string.format("fade=0F6362=0.25", self.tickTimer * 1.0))
end

function uninit()
end
