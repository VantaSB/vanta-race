require "/scripts/util.lua"

function init()
--  self.broadcastArea = rect.translate(config.getParameter("broadcastArea", {-8, -8, 8, 8}), entity.position())
  local item = items[1]
  object.setInteractive(true)
  if storage.state == nil then
    output(config.getParameter("defaultSwitchState", false))
  else
    output(storage.state)
  end
  self.requiredKey = config.getParameter("requiredKey")
  if not self.requiredKey then
    self.requiredKey = "generickeycard"
    sb.logInfo("Keycard reader at %s is missing its configuration, defaulting to 'generickeycard'", object.position())
    return
  else
    sb.logInfo("Keycard reader initialized; required key: %s", self.requiredKey)
  end
end

function state()
  return storage.state
end

function update(dt)
  for _,item in pairs(world.containerItems(entity.id())) do
    if item then
      output(storage.state)
    elseif not item or item.name ~= self.requiredKey then
      animator.playSound("error")
    end
  end
end

--[[function onInteraction(args)
  player = world.entityQuery(entity.position(), 5, { includedTypes = { "player" } })
  sb.logInfo("Detected interaction from player: %s", player)

  if player.hasItem(self.requiredKey) then
    output(not storage.state)
    player.consumeItem(self.requiredKey)
  else
    animator.playSound("/sfx/interface/clickon_error.ogg")
  end
end]]

function output(state)
  storage.state = state
  if state then
    animator.setAnimationState("switchState", "on")
    if not (config.getParameter("alwaysLit")) then object.setLightColor(config.getParameter("lightColor", {0, 0, 0, 0})) end
    animator.playSound("on");
    object.setAllOutputNodes(true)
  else
    animator.setAnimationState("switchState", "off")
    if not (config.getParameter("alwaysLit")) then object.setLightColor({0, 0, 0, 0}) end
    animator.playSound("off");
    object.setAllOutputNodes(false)
  end
end
