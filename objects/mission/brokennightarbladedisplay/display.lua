function init()
  animator.setAnimationState("display", "active")
  object.setInteractive(true)
  object.setAllOutputNodes(true)
end

function onInteraction(args)
  animator.setAnimationState("display", "inactive")
  object.setInteractive(false)
  object.setLightColor({0, 0, 0})
  object.setAllOutputNodes(false)
  world.sendEntityMessage(args.sourceId, "giveSword")

  for parameter,value in pairs(config.getParameter("pickedUpParameters")) do
    object.setConfigParameter(parameter, value)
  end
end
