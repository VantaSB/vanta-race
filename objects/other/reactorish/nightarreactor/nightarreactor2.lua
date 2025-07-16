function init()
  storage.state = storage.state or false

  if config.getParameter("inputNodes") then
    processWireInput()
  end

  setPowerState(storage.state)
end

function onNodeConnectionChange(args)
  processWireInput()
end

function onInputNodeChange(args)
  processWireInput()
end

function processWireInput()
  if object.isInputNodeConnected(0) then
		if object.getInputNodeLevel(0) then
    	storage.state = true
		else
			storage.state = false
		end
	end
	setPowerState(storage.state)
end

function setPowerState(newState)
  if newState then
    object.setAllOutputNodes(true)
    animator.setAnimationState("base", "active")
    animator.setAnimationState("orb", "active")
    object.setSoundEffectEnabled(true)
    if animator.hasSound("on") then
      animator.playSound("on");
    end
    --world.sendEntityMessage("reactorroommanager", "reactorOn")
  else
    object.setAllOutputNodes(false)
    animator.setAnimationState("base", "inactive")
    animator.setAnimationState("orb", "inactive")
    object.setSoundEffectEnabled(false)
    if animator.hasSound("off") then
      animator.playSound("off");
    end
  end
end
