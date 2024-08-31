require "/scripts/stagehandutil.lua"

function init()
  self.containsPlayers = {}
  self.useRadioMessages = config.getParameter("useRadioMessages", false)
  self.persistent = config.getParameter("persistent", false)
  self.interactive = config.getParameter("interactive", true)
  object.setInteractive(self.interactive)
  storage.messagesSent = nil
	storage.lockedMessagesSent = nil
  if storage.state == nil then
    output(config.getParameter("defaultSwitchState", false))
  else
    output(storage.state)
  end
  if self.useRadioMessages then
    self.radioMessages = config.getParameter("radioMessages") or {config.getParameter("radioMessage")}
		self.lockedRadioMessages = config.getParameter("lockedRadioMessages")
    storage.messagesSent = false
		storage.lockedMessagesSent = false
  end

	if storage.locked == nil then
		storage.locked = false
	end
end

function update(dt)
	if object.isInputNodeConnected(0) then
		if object.getInputNodeLevel(0) and storage.locked then
			storage.locked = false
			if storage.state then
				animator.setAnimationState("switchState", "on")
			else
				animator.setAnimationState("switchState", "off")
			end
		else--if not storage.locked and not object.getInputNodeLevel(0) then
			storage.locked = true
			animator.setAnimationState("switchState", "locked")
		end
	else
		storage.locked = false
	end
end

function state()
  return storage.state
end

function onInteraction(args)
	local newPlayers = broadcastAreaQuery({includedTypes = {"player"}})
	local oldPlayers = table.concat(self.containsPlayers, ",")
	if storage.locked then
		animator.playSound("error")
		for _, id in pairs(newPlayers) do
			if not string.find(oldPlayers, id) then
				world.sendEntityMessage(id, "queueRadioMessage", "vantamissions_consolelockedgeneric")
				if self.useRadioMessages and not storage.lockedMessagesSent then
					for _, message in ipairs(self.lockedRadioMessages) do
						world.sendEntityMessage(id, "queueRadioMessage", message)
						storage.lockedMessagesSent = true
					end
				end
			end
		end
	else
  	output(not storage.state)
  	if self.persistent == true then
    	object.setInteractive(false)
  	end
  	if self.useRadioMessages and not storage.messagesSent then
    	for _, id in pairs(newPlayers) do
      	if not string.find(oldPlayers, id) then
        	for _, message in ipairs(self.radioMessages) do
          	world.sendEntityMessage(id, "queueRadioMessage", message)
          	storage.messagesSent = true
					end
        end
      end
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
