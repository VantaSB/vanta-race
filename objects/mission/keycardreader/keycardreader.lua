function init()
	storage.active = storage.active or false
  self.interactData = config.getParameter("interactData")
  self.keycardType = config.getParameter("keycardType")
  animator.setAnimationState("switchState", "off")
  object.setAllOutputNodes(false)

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
  if not storage.active then
		object.setAllOutputNodes(false)
	  object.setInteractive(true)
		animator.setAnimationState("switchState", "off")
	else
		object.setAllOutputNodes(true)
	  object.setInteractive(false)
		animator.setAnimationState("switchState", "on")
  end
end

function activate()
  storage.active = true
end
