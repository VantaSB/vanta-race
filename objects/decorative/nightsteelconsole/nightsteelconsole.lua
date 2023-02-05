require "/scripts/stagehandutil.lua"

function init()
  self.containsPlayers = {}
  self.useRadioMessages = config.getParameter("useRadioMessages", false)
  self.persistent = config.getParameter("persistent", false)
  self.interactive = config.getParameter("interactive", true)
  object.setInteractive(self.interactive)
  storage.messagesSent = nil
  if storage.state == nil then
    output(config.getParameter("defaultSwitchState", false))
  else
    output(storage.state)
  end
  if self.useRadioMessages then
    self.radioMessages = config.getParameter("radioMessages") or {config.getParameter("radioMessage")}
    storage.messagesSent = false
  end
end

function state()
  return storage.state
end

function onInteraction(args)
  output(not storage.state)
  if self.persistent == true then
    object.setInteractive(false)
  end
  if self.useRadioMessages and not storage.messagesSent then
    local newPlayers = broadcastAreaQuery({includedTypes = {"player"}})
    local oldPlayers = table.concat(self.containsPlayers, ",")
    for _, id in pairs(newPlayers) do
      if not string.find(oldPlayers, id) then
        for _, message in ipairs(self.radioMessages) do
          world.sendEntityMessage(id, "queueRadioMessage", message)
          storage.messagesSent = true
        end
      end
    end
  end
end

function output(state)
  storage.state = state
  if state then
    animator.setAnimationState("switchState", "on")
    if not (config.getParameter("alwaysLit")) then object.setLightColor(config.getParameter("lightColor", {0, 0, 0, 0})) end
    object.setSoundEffectEnabled(true)
    animator.playSound("on");
    object.setAllOutputNodes(true)
  else
    animator.setAnimationState("switchState", "off")
    if not (config.getParameter("alwaysLit")) then object.setLightColor({0, 0, 0, 0}) end
    object.setSoundEffectEnabled(false)
    animator.playSound("off");
    object.setAllOutputNodes(false)
  end
end
