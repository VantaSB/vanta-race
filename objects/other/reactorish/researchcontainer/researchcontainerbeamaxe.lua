function init()
  self.lightColor = config.getParameter("lightColor", {12, 142, 144})
  object.setLightColor(self.lightColor)
  animator.setAnimationState("container", "active")
  object.setInteractive(true)
  object.setAllOutputNodes(true)
end

function onInteraction(args)
  animator.setAnimationState("container", "inactive")
  object.setInteractive(false)
  object.setLightColor({0, 0, 0})
  object.setAllOutputNodes(false)
  world.sendEntityMessage(args.sourceId, "giveBeamaxe")

  for parameter,value in pairs(config.getParameter("pickedUpParameters")) do
    object.setConfigParameter(parameter, value)
  end
end
