function init()
  if storage.state == nil then storage.state = config.getParameter("defaultPowerState", true) end

  self.interactive = config.getParameter("interactive", false)
  object.setInteractive(self.interactive)

  if config.getParameter("inputNodes") then
    processWireInput()
  end

  --setPowerState(storage.state)
end

function onNodeConnectionChange(args)
  processWireInput()
end

function onInputNodeChange(args)
  processWireInput()
end

function onInteraction(args)
  if not config.getParameter("inputNodes") or not object.isInputNodeConnected(0) then
    storage.state = not storage.state
    setPowerState(storage.state)
  end
end

function processWireInput()
  if object.isInputNodeConnected(0) then
    object.setInteractive(false)
    storage.state = object.getInputNodeLevel(0)
    setPowerState(storage.state)
  elseif self.interactive then
    object.setInteractive(true)
  end
end

function setPowerState(newState)
  if newState then
    object.setAllOutputNodes(true)
    animator.setAnimationState("base", "active")
    animator.setAnimationState("orb", "active")
    object.setSoundEffectEnabled(true)
    if animator.hasSound("on") then
      animator.playSound("on");
    end
    world.sendEntityMessage("reactorroommanager", "reactorOn")
  else
    object.setAllOutputNodes(false)
    animator.setAnimationState("base", "inactive")
    animator.setAnimationState("orb", "inactive")
    object.setSoundEffectEnabled(false)
    if animator.hasSound("off") then
      animator.playSound("off");
    end
  end
end
