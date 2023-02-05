require "/scripts/util.lua"

function init()
  self.detectArea = config.getParameter("detectArea")
  self.detectArea[1] = object.toAbsolutePosition(self.detectArea[1])
  self.detectArea[2] = object.toAbsolutePosition(self.detectArea[2])
  self.lightColor = config.getParameter("lightColor")

  animator.setAnimationState("baseState", "off")
  animator.setAnimationState("orb", "off")
  animator.setAnimationState("portal", "closed")
  object.setLightColor({0, 0, 0})
  sb.logInfo("Light color: %s", self.lightColor)

  storage.active = storage.active or config.getParameter("startActive", false)

  message.setHandler("activate", function()
    storage.active = true
    animator.setAnimationState("baseState", "on")
    animator.playSound("activate")
    object.setLightColor(self.lightColor)
  end)

  message.setHandler("isActive", function()
    return storage.active == true
  end)

  if storage.active then
    animator.setAnimationState("baseState", "on")
    animator.setAnimationState("orb", "on")
    animator.playSound("activate")
    object.setLightColor(self.lightColor)
    for parameter,value in pairs(config.getParameter("activatedParameters")) do
      object.setConfigParameter(parameter, value)
    end
  end
end

function onInteraction()
  if not storage.active then
    return {config.getParameter("inactiveInteractAction"), config.getParameter("inactiveInteractData")}
  else
    return {config.getParameter("interactAction"), config.getParameter("interactData")}
  end
end

function update(dt)
  if storage.active then
    local players = world.entityQuery(self.detectArea[1], self.detectArea[2], {
      includedTypes = {"player"},
      boundMode = "CollisionArea"
    })

    if #players > 0 and animator.animationState("portal") == "closed" then
      animator.setAnimationState("orb", "off")
      animator.setAnimationState("portal", "open")
    elseif #players == 0 and animator.animationState("portal") == "openloop" then
      animator.setAnimationState("portal", "close")
      animator.setAnimationState("orb", "on")
    end
  end
end
