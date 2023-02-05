function init()
  script.setUpdateDelta(60)
end

function update(dt)
  --[[local lightModifier = (world.lightLevel(mcontroller.position()) or 0.2) - 0.2
  if lightModifier > 0 then
    lightModifier = math.min(lightModifier * 5, 2)
  else
    lightModifier = math.min(lightModifier * 5, -1)
  end

  local lightLevel = string.format("$X", math.max(math.floor(100 - 50*world.lightLevel(mcontroller.position())), 50))
  ]]
  sb.logInfo("Light Level: %s", world.lightLevel(mcontroller.position()))
end
