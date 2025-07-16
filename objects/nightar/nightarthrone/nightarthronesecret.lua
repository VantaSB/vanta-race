function init()
	if object.isInputNodeConnected(0) then
		object.setInteractive(false)
	else
		object.setInteractive(true)
	end
  if storage.state == nil then
    output(config.getParameter("defaultState", false))
  else
    output(storage.state)
  end
end

function state()
  return storage.state
end

function onInteraction(args)
  output(not storage.state)
end

function output(state)
  storage.state = state
  if state then
    animator.setAnimationState("doorState", "opening")
    object.setSoundEffectEnabled(true)
    animator.playSound("open");
    object.setAllOutputNodes(true)
  else
    animator.setAnimationState("doorState", "closing")
    object.setSoundEffectEnabled(false)
    animator.playSound("close");
    object.setAllOutputNodes(false)
  end
end

function onNodeConnectionChange(args)
	updateInteractive()
  if object.isInputNodeConnected(0) then
    onInputNodeChange({ level = object.getInputNodeLevel(0) })
		object.setInteractive(false)
  end
end

function onInputNodeChange(args)
  output(args.level)
end

function updateInteractive()
	if object.isInputNodeConnected(0) then
		object.setInteractive(false)
	else
		object.setInteractive(true)
	end
end
