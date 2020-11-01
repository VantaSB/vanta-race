require "/scripts/util.lua"

function init()
  self.detectArea = config.getParameter("detectArea")
  self.detectArea[1] = object.toAbsolutePosition(self.detectArea1[1])
  self.detectArea[2] = object.toAbsolutePosition(self.detectArea2[2])

  storage.active = storage.active or config.getParameter("startActive", false)

  message.setHandler("activate", function()
    storage.active = true
    animator.setAnimationState("gate", "turnon")
    object.setLightColor(config.getParameter("lightColor", {255, 255, 255}))
  end)

  message.setHandler("isActive", function()
    return storage.active == true
  end)

  --need to add some custom configuration here, since this isn't technically an ancient gate.

  --[[

  self.activeTime = config.getParameter("activeTime", 60)
  self.instanceOption = config.getParameter("instanceOption")
  self.accessConfig = root.assetJson("/interface/scripted/darkgate/gateaccess.config")

  storage.active = storage.active or false

  message.setHandler("activateGate", function()
    if not storage.active then
      storage.active = true
      storage.closeTime = world.time() + self.activeTime
      math.randomseed(util.seedTime())
      local instanceOption = util.randomFromList(self.instanceOptions)
      storage.instanceType = instanceOption[1]
      storage.instanceWorldId = string.format("InstanceWorld:%s:%s:%s", instanceOption[2], sb.makeUuid(), 8)

      animator.setGlobalTag("destination", storage.instanceType)
      animator.setAnimationState("portal", "open")
      animator.playSound("on");
      object.setLightColor(config.getParameter("lightColor", {255, 255, 255}))
    end
  end)

  message.setHandler("closeGate", function()
    if storage.active then
      closeGate()
    end
  end)

  if storage.active then
    animator.setAnimationState("portal", "off")
    object.setLightColor({0, 0, 0, 0})
  end
  ]]
end

function onInteraction()
  if not storage.active then
    return {config.getParameter("inactiveInteractAction"), config.getParameter("inactiveInteractData")}
  else
    return {config.getParameter("interactAction"), config.getParameter("interactData")}
  end
end

function update(dt)
  --if self.
end
