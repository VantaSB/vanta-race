require "/scripts/util.lua"

function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
	effect.setParentDirectives("fade=0F6362=0.25")

  script.setUpdateDelta(5)

	self.damageClampRange = config.getParameter("damageClampRange")

  self.tickTime = config.getParameter("boltInterval", 1.0)
  self.tickTimer = self.tickTime
end

--[[function update(dt)
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
end]]

function update(dt)
	status.addEphemeralEffect("ceruleumcorruptionblur")
	self.tickTimer = self.tickTimer - dt
	local cPower = util.clamp(status.resourceMax("health") * self.tickDamagePercentage, self.damageClampRange[1], self.damageClampRange[2])
	if self.tickTimer <= 0 then
		self.tickTimer = self.tickTime
		local targetIds = world.entityQuery(mcontroller.position(), config.getParameter("jumpDistance", 8), {
			withoutEntityId = entity.id(),
			includedTypes = {"creature"}
		})

		shuffle(targetIds)

		for i, id in ipairs(targetIds) do
			local sourceId = effect.sourceEntity() or entity.id()
			if world.entityCanDamage(sourceId, id) and not world.lineTileCollision(mcontroller.position(), world.entityPosition(id)) then
				local sourceTeam = world.entityDamageTeam(sourceId)
				local directionTo = world.distance(world.entityPosition(id), mcontroller.position())
				world.spawnProjectile(
				"ceruleumcorruption",
				mcontroller.position(),
				entity.id(),
				directionTo,
				false,
				{
					power = cPower,
					damageTeam = sourceTeam
				}
			)
			end
		end
	end
end

function uninit()
	status.removeEphemeralEffect("ceruleumcorruptionblur")
end
