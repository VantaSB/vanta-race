--[[
  This functions similarly to the wired latch and
  invisible latch objects, but this takes it a
  step further by only updating when the input
  wire switches out and back into an active state.
]]--

function init()
  object.setInteractive(false)
  if storage.state == nil then
    output(false)
  else
    output(storage.state)
  end
  if storage.timer == nil then
    storage.timer = 0
  end
  self.interval = config.getParameter("interval")
end

function output(state)
  if storage.state ~= state then
    storage.state = state
    object.setAllOutputNodes(state)
    if state then
      animator.setAnimationState("switchState", "on")
    else
      animator.setAnimationState("switchState", "off")
    end
  end
end

function update(dt)
  if storage.timer > 0 then
    storage.timer = storage.timer - 1
  end

  if object.getInputNodeLevel(0) and storage.timer == 0 then
    if storage.state == true then
      output(false)
    else
      output(true)
    end
    storage.timer = self.interval
  end
end
