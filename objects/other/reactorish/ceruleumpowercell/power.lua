function init()
  self.msgHandler = config.getParameter("msgHandler")
  self.targetEntity = config.getParameter("targetEntity")
  if not self.msgHandler or not self.targetEntity then
    self.msgHandler, self.targetEntity = nil
    sb.logInfo("Powercell at position %s is mising the necessary configuration properties; no messages will be passed upon object death.", object.position())
  end

  object.setAllOutputNodes(true)
end

function die()
	if self.msgHandler and self.targetEntity then
  	world.sendEntityMessage(self.targetEntity, self.msgHandler)
	end
end
