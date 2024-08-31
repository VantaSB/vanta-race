function init()
	if storage.state == nil then storage.state = config.getParameter("defaultState", true) end

	self.interactive = config.getParameter("interactive", true)
	object.setInteractive(self.interactive)

	self.lightColor = config.getParameter("lightColor", {0, 0, 0})

	if config.getParameter("inputNodes") then
		processWireInput()
	end
end

function onNodeConnectionChange(args)
	processWireInput()
end

function onInputNodeChange(args)
	processWireInput()
end

function onInteraction(args)
	if not config.getParameter("inputNodes") or not object.isInputNodeConnected(0) then
    storage.state = not storage.state
		setPodState(storage.state)
	end
end

function processWireInput()
  if object.isInputNodeConnected(0) then
    object.setInteractive(false)
    storage.state = object.getInputNodeLevel(0)
    setPodState(storage.state)
  elseif self.interactive then
    object.setInteractive(true)
  end
end

function setPodState(newState)
	if newState then
		animator.setAnimationState("podState", "active")
		object.setLightColor(self.lightColor)
		object.setSoundEffectEnabled(true)
		if animator.hasSound("pod") then
			animator.playSound("pod", -1)
		end
	else
		animator.setAnimationState("podState", "off")
		object.setLightColor({0, 0, 0})
		object.setSoundEffectEnabled(false)
		if animator.hasSound("pod") then
			animator.stopAllSounds("pod")
		end
	end
end
