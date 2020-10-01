function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)

  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.125
  self.tickTime = 1
  self.tickTimer = self.tickTime
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
      damageSourceKind = "ceruleumpoison",
      sourceEntityId = entity.id()
      })
  end

  effect.setParentDirectives(string.format("fade=0F6362=%.1f", self.tickTimer * 0.4))
end

function uninit()
end
