function init()
  self.msgHandler = config.getParameter("msgHandler")
  self.targetEntity = config.getParameter("targetEntity")
  if not self.msgHandler or not self.targetEntity then
    self.msgHandler = "null"
    self.targetEntity = "null"
    --sb.logInfo("Powercell at position %s is mising the necessary configuration properties; no messages will be passed upon object death.", object.position())
  else
    --sb.logInfo("Powercell at position %s configured: msgHandler = %s  |  targetEntity = %s", object.position(), self.msgHandler, self.targetEntity)
  end
end

function die()
  world.sendEntityMessage(self.targetEntity, self.msgHandler)
end
