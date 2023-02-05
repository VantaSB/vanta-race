function init()
  self.interactData = config.getParameter("interactData")
  self.keycardType = config.getParameter("keycardType", "nightar")
  self.requiredLevel = config.getParameter("requiredLevel", 0)
  animator.setAnimationState("switchState", "off")
  object.setAllOutputNodes(false)
  self.interval = 60
  storage.timer = 0

  message.setHandler("activate", function()
    activate()
  end)

  object.setInteractive(true)
end

function onInteraction(args)
  self.interactData.keycardType = self.keycardType
  self.interactData.requiredLevel = self.requiredLevel
  return {"ScriptPane", self.interactData}
end

function update(dt)
  if storage.timer > 0 then
    storage.timer = storage.timer - 1
    if storage.timer == 0 then
      object.setInteractive(true)
      animator.setAnimationState("switchState", "off")
      object.setAllOutputNodes(false)
    end
  end
end

function activate()
  storage.timer = self.interval
  object.setAllOutputNodes(true)
  object.setInteractive(false)
  animator.setAnimationState("switchState", "on")
end
