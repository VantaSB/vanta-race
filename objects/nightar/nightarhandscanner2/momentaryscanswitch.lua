-- yoinked from Ztarbound

function init()
	object.setInteractive(true)
	if storage.state == nil then
		storage.state = config.getParameter("defaultSwitchState", false)
	end

  if not storage.state then
		animator.setAnimationState("switchState", "on")
	else
		animator.setAnimationState("switchState", "off")
  end
  self.interval = config.getParameter("interval", 15)
  storage.timer = 0

	message.setHandler('scanInteraction', scanInteraction)
end

function update(dt)
	if storage.timer > 0 then
		storage.timer = storage.timer - 1

		if storage.timer == 0 then
			object.setAllOutputNodes(false)
		end
	end
end

function scanInteraction(_, _, playerID)
	if not self.scanned then
		self.scanned = true
	end

	if config.getParameter("objectScanSay") then
		object.say(config.getParameter("objectScanSay"))
	end

	animator.setAnimationState("switchState", "off")
	animator.playSound("interact")
  object.setAllOutputNodes(true)
  storage.timer = self.interval
end

function onInputNodeChange(args)
	if object.getInputNodeLevel(0) then
		self.scanned = true
		animator.setAnimationState("switchState", "off")
	end
end

function onInteraction(args)
	if self.scanned then
		animator.playSound("interact")
	  object.setAllOutputNodes(true)
	  storage.timer = self.interval
	else
		animator.playSound("error")
	end
end
