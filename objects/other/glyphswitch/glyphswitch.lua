-- Based on the Ztarbound scaninteracationexample script

function init()
  message.setHandler('scanInteraction', scanInteraction)

  if storage.state == nil then
    output(config.getParameter("defaultSwitchState", false))
  else
    output(storage.state)
  end

  if storage.triggered == nil then
    storage.triggered = false
  end
end

function scanInteraction(_, _, playerID)
  if not self.scanned then
    animator.setAnimationState("switchState", "on")
    object.setAllOutputNodes(true)
    self.scanned = true
  end
end

function onInteraction()
  object.setInteractive(false)
  output(not storage.state)
end

function output(state)
  storage.state = state
  if state then
    animator.setAnimationState("switchState", "on")
    object.setAllOutputNodes(true)
  else
    animator.setAnimationState("switchState", "off")
    object.setAllOutputNodes(false)
  end
end
