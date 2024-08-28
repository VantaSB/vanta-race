function init()
	self.moved = false
end

function update()
  if effect.sourceEntity() and not self.moved then
    --local dest = vec2.add(world.entityMouthPosition(effect.sourceEntity()), {0, -1.5})
		local dest = world.entityMouthPosition(effect.sourceEntity())
		dest[2] = dest[2] - 1.5
		--world.sendEntityMessage(effect.sourceEntity(), "openDoor")
    mcontroller.setPosition(dest)
		self.moved = true
		sb.logInfo("Landed: %s", dest)
  end

	if self.moved then
		effect.expire()
	end
end
