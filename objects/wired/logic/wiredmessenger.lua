function init()
  storage.state = false
  self.messageType = config.getParameter("messageType")
	self.messageArgs = config.getParameter("messageArgs", {})
	self.messageTargetEntity = config.getParameter("messageTargetEntity")
	object.setInteractive(false)

	if config.getParameter("inputNodes") then
    updateWire()
  end
end

function onNodeConnectionChange(args)
	updateWire()
end

function onInputNodeChange(args)
  updateWire()
end

function updateWire()
	if object.getInputNodeLevel(0) then
		storage.state = true
		world.sendEntityMessage(self.messageTargetEntity, self.messageType, self.messageArgs)
	else
		storage.state = false
		world.sendEntityMessage(self.messageTargetEntity, self.messageType, self.messageArgs)
	end
end
