function init()

end

function update()
  if world.entityExists(effect.sourceEntity()) then
    local dest = world.entityMouthPosition(effect.sourceEntity())
    dest[2] = dest[2] - 2
    mcontroller.setPosition(dest)
  end
end
