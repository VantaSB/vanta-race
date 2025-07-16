-- yoinked from Ztarbound

function init()
	storage.state = storage.state or false
  self.persistent = config.getParameter("persistent", false)
	self.objectSayUnscanned = config.getParameter("objectSayUnscanned", nil)
	self.objectSayScanned = config.getParameter("objectSayScanned", nil)
  message.setHandler('scanInteraction', scanInteraction)

  if storage.state == false then
    output(config.getParameter("defaultSwitchState", false))
		animator.setAnimationState("switch", "off")
  else
    output(storage.state)
		animator.setAnimationState("switch", "on")
  end

	--Debug
	if config.getParameter("interactive") then
		object.setInteractive(true)
	end
end

function scanInteraction(_, _, playerID)
  if not self.scanned then
		if self.objectSayUnscanned ~= nil then
			object.say(self.objectSayUnscanned)
		end
    animator.setAnimationState("switch", "on")
    object.setAllOutputNodes(true)
    self.scanned = true
	else
		if self.objectSayScanned ~= nil then
			object.say(self.objectSayScanned)
		end
  end
end

function onNodeConnectionChange(args)
	if object.isInputNodeConnected(0) then
		onInputNodeChange({ level = object.getInputNodeLevel(0) })
	end
end

function onInputNodeChange(args)
	if args.level then
		storage.state = true
		output(storage.state)
	end
end

--Debug
function onInteraction()
  object.setInteractive(false)
  output(not storage.state)
end

function output(state)
  storage.state = state
  if state then
		self.scanned = true
    animator.setAnimationState("switch", "on")
    object.setAllOutputNodes(true)
  else
		self.scanned = false
    animator.setAnimationState("switch", "off")
    object.setAllOutputNodes(false)
  end
end
