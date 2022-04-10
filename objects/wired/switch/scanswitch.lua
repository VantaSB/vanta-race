-- yoinked from Ztarbound, this one is for 'invisible' switches with graphics akin to bounty scan clues.

function init()
  self.persistent = config.getParameter("persistent", false)
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
    animator.setAnimationState("switch", "switching")
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
    animator.setAnimationState("switch", "switching")
    object.setAllOutputNodes(true)
  else
    animator.setAnimationState("switch", "off")
    object.setAllOutputNodes(false)
  end
end
