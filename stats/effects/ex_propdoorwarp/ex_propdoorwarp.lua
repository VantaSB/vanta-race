require "/scripts/vec2.lua"

function init()

end

function update()
  if effect.sourceEntity() then
    local dest = vec2.add(world.entityMouthPosition(effect.sourceEntity()), {0.5, -1.0})
		world.sendEntityMessage(effect.sourceEntity(), "openDoor")
    mcontroller.setPosition(dest)
  end
end
