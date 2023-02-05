function init()
  self.useRadioMessages = config.getParameter("useRadioMessages", false)
  self.radioMessages = config.getParameter("radioMessages") or {config.getParameter("radioMessage")}
  self.itemList = config.getParameter("itemList")
  if storage.active == nil then activate() end
end

function onInteraction(args)
  if storage.active then
    if not self.useRadioMessages then
      dispense(args)
    else
      world.sendEntityMessage(args.source, "queueRadioMessages", self.radioMessages)
    end
  end
end

function dispense(args)
  if storage.active then
    animator.playSound("use1")
    animator.playSound("use2")

    deactivate()

    if self.itemList == nil then
      world.spawnItem("money", object.position(), math.random(50))
    else
      for _, item in pairs(self.itemList) do
        world.spawnItem(item.name, object.position(), item.count)
      end
    end
  end
end

function activate()
  animator.setAnimationState("podState", "active")
  storage.active = true
  object.setInteractive(true)
end

function deactivate()
  animator.setAnimationState("podState", "expire")
  storage.active = false
  object.setInteractive(false)
end
