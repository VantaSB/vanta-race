function init()
  self.containerItem = config.getParameter("containerItem", nil)
  self.isEssential = config.getParameter("isEssential", false)
  self.stage = 0

  if not self.isEssential then
    if self.containerItem ~= nil then
      animator.setAnimationState("base", "active")
      animator.setAnimationState("item", "active")
      object.setInteractive(true)
    else
      animator.setAnimationState("base", "inactive")
      animator.setAnimationState("item", "taken")
      object.setInteractive(false)
    end

  elseif self.isEssential then
    self.containerItem = nil
    animator.setAnimationState("base", "active")
    animator.setAnimationState("item", "active")
    object.setInteractive(true)
  end
end

function onInteraction(args)
  self.stage = self.stage + 1
  if self.stage == 1 then
    animator.setAnimationState("base", "opening")
    animator.setAnimationState("item", "opening")
  elseif self.stage == 2 then
    animator.setAnimationState("base", "taken")
    animator.setAnimationState("item", "taken")
    object.setInteractive(false)
    if self.isEssential then
      world.sendEntityMessage(args.sourceId, "giveBeamaxe")

      for parameter,value in pairs(config.getParameter("pickedUpParameters")) do
        object.setConfigParameter(parameter, value)
      end
    else
      world.spawnItem(self.containerItem, object.toAbsolutePosition({2, 4}), 1)
    end
  end
end
