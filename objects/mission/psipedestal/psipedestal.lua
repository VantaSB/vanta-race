function init()
  self.giveItem = config.getParameter("giveItem", "psicore")
  object.setInteractive(true)
end

function onInteraction(args)
  world.spawnItem(self.giveItem, object.position())
  object.setInteractive(false)
  animator.setAnimationState("pedestal", "off")
end

function uninit()

end
