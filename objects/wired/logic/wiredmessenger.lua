function init()
	object.setInteractive(false)
	self.targetId = config.getParameter("targetId")
  self.messageType = config.getParameter("messageType")
	self.messageArgs = config.getParameter("messageArgs")
end

function onNodeConnectionChange(args)
	updateWire()
end

function onInputNodeChange(args)
  updateWire()
end

function updateWire()
	if object.getInputNodeLevel(0) then
		world.sendEntityMessage(self.targetId, self.messageType, self.messageArgs)
	else
		world.sendEntityMessage(self.targetId, self.messageType, self.messageArgs)
	end
end
