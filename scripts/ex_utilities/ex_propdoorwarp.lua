function init()
  if storage.timer == nil then
    storage.timer = 0
  end

  if storage.locked == nil then
    storage.locked = config.getParameter("locked", false)
  end

  if storage.state == nil then
    storage.state = config.getParameter("defaultState", false)
    animator.setAnimationState("doorState", "closed")
  end

  self.interval = config.getParameter("interval", 15)

  storage.dCoord = config.getParameter("dCoord")
  if storage.dCoord == nil then
    storage.locked = true
    animator.setLightActive("fg", false)
  end

  object.setInteractive(true)
end

function update(dt)
  if storage.timer > 0 then
    storage.timer = storage.timer - 1
    if storage.timer == 0 then
      closeDoor()
    end
  end
end

function onInteraction(args)
  if not storage.locked then
    storage.timer = self.interval
    world.sendEntityMessage(args.sourceId, "ex.warp", storage.dCoord)
    openDoor()
  else
    --world.sendEntityMessage(args.sourceId, "ex.playSound", "/sfx/interface/clickon_error.ogg")
    animator.playSound("locked")
  end
end

function closeDoor()
  if storage.state ~= false then
    storage.state = false
    animator.playSound("close")
    animator.setAnimationState("doorState", "closing")
    object.setInteractive(true) --Re-enable interactivity for warping
  end
end

function openDoor()
  if not storage.state then
    object.setInteractive(false) --Prevent the warp function from being called successively
    storage.state = true
    animator.playSound("open")
    animator.setAnimationState("doorState", "open")
  end
end
