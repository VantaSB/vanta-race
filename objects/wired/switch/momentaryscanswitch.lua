-- yoinked from Ztarbound, this one is for 'invisible' switches with graphics akin to bounty scan clues.

function init()
  message.setHandler('scanInteraction', scanInteraction)
  animator.setAnimationState("switch", "off")

  if storage.triggered == nil then
    storage.triggered = false
  end
  self.interval = config.getParameter("interval", 15)
  storage.timer = 0
end

function scanInteraction(_, _, playerID)
  animator.setAnimationState("switch", "switching")
  object.setAllOutputNodes(true)
  storage.timer = self.interval
end

function update(dt)
  if storage.timer > 0 then
    storage.timer = storage.timer - 1

    if storage.timer == 0 then
      animator.setAnimationState("switch", "off")
      object.setAllOutputNodes(false)
    end
  end
end
