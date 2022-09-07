require "/scripts/stagehandutil.lua"

function init()
  self.open = false
  self.uniqueId = object.setUniqueId(config.getParameter("uniqueId"))

  self.triggerTime = config.getParameter("openDelay")
  self.timer = 0

  self.messageType = config.getParameter("messageType")
  message.setHandler(self.messageType, function(...)
    self.open = true
  end)
end

function update()
  if not self.open then
    self.timer = self.timer + script.updateDt()

    if self.timer > self.triggerTime then
      object.setAllOutputNodes(true)
      self.open = true
      self.timer = 0
    end
  end
end
