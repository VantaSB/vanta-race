function init()
  self.persistent = config.getParameter("persistent", false)
  object.setInteractive(true)
  if storage.state == nil then
    output(config.getParameter("defaultSwitchState", false))
  else
    output(storage.state)
  end
end

function state()
  return storage.state
end

function onInteraction(args)
  output(not storage.state)
  if self.persistent == true then
    object.setInteractive(false)
  end
end

function output(state)
  storage.state = state
  if state then
    animator.setAnimationState("switchState", "on")
    if not (config.getParameter("alwaysLit")) then object.setLightColor(config.getParameter("lightColor", {0, 0, 0, 0})) end
    object.setSoundEffectEnabled(true)
    animator.playSound("on");
    object.setAllOutputNodes(true)
  else
    animator.setAnimationState("switchState", "off")
    if not (config.getParameter("alwaysLit")) then object.setLightColor({0, 0, 0, 0}) end
    object.setSoundEffectEnabled(false)
    animator.playSound("off");
    object.setAllOutputNodes(false)
  end
end
