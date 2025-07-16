require "/scripts/stagehandutil.lua"

function init()
  self.containsPlayers = {}
  self.useRadioMessages = config.getParameter("useRadioMessages", false)
	self.itemSpawn = config.getParameter("itemSpawn")
  self.persistent = config.getParameter("persistent", false)

	if config.getParameter("radioMessages") then
		self.radioMessages = config.getParameter("radioMessages") or config.getParameter({"radioMessage"})
		self.useRadioMessages = true
	end

	if config.getParameter("lockedRadioMessages") then
		self.lockedRadioMessage = config.getParameter("lockedRadioMessages")
		self.useRadioMessages = true
	end

	object.setInteractive(config.getParameter("interactive", true))
  storage.messagesSent = nil
	storage.lockedMessagesSent = nil

	if storage.state == nil then
    output(config.getParameter("defaultSwitchState", false))
  end

  storage.messagesSent = false
	storage.lockedMessagesSent = false

	if object.isInputNodeConnected(0) then
		if not object.getInputNodeLevel(0) then
			storage.locked = true
			animator.setAnimationState("switchState", "locked")
		else
			storage.locked = false
			if storage.state then
				animator.setAnimationState("switchState", "on")
			else
				animator.setAnimationState("switchState", "off")
			end
		end
	else
		if storage.state then
			animator.setAnimationState("switchState", "on")
		else
			animator.setAnimationState("switchState", "off")
		end
	end
end

function onNodeConnectionChange(args)
  if object.isInputNodeConnected(0) then
		if not object.getInputNodeLevel(0) then
			storage.locked = true
			animator.setAnimationState("switchState", "locked")
		else
			storage.locked = false
			animator.setAnimationState("switchState", "off")
		end
	end
end

function onInputNodeChange(args)
	if object.isInputNodeConnected(0) then
		if not object.getInputNodeLevel(0) then
			storage.locked = true
			animator.setAnimationState("switchState", "locked")
		else
			storage.locked = false
			animator.setAnimationState("switchState", "off")
		end
	end
end

function state()
  return storage.state
end

function onInteraction(args)
	if storage.locked then
		animator.playSound("error")
		if self.useRadioMessages then
			if self.lockedRadioMessage then
				world.sendEntityMessage(args.sourceId, "queueRadioMessage", self.lockedRadioMessage)
			end
		end
	else
		output(not storage.state)
		if self.persistent == true then
			object.setInteractive(false)
		end
		if self.useRadioMessages and not storage.messagesSent then
			for _, message in pairs(self.radioMessages) do
				world.sendEntityMessage(args.sourceId, "queueRadioMessage", message)
			end
			storage.messagesSent = true
    end
		if self.itemSpawn ~= nil then
			world.spawnItem(self.itemSpawn, object.position())
		end
  end
end

function output(state)
  storage.state = state
  if state then
    animator.setAnimationState("switchState", "on")
    if not (config.getParameter("alwaysLit")) then object.setLightColor(config.getParameter("lightColor", {0, 0, 0, 0})) end
    object.setSoundEffectEnabled(true)
    animator.playSound("on")
    object.setAllOutputNodes(true)
  else
    animator.setAnimationState("switchState", "off")
    if not (config.getParameter("alwaysLit")) then object.setLightColor({0, 0, 0, 0}) end
    object.setSoundEffectEnabled(false)
    animator.playSound("off")
    object.setAllOutputNodes(false)
  end
end
