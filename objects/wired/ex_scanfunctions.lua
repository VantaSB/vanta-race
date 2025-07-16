function init()
	if config.getParameter("scanFunctions") then
		self.scanFunctions = config.getParameter("scanFunctions")
		if type(self.scanFunctions) ~= "table" then
			self.scanFunctions = {self.scanFunctions}
		end
		if self.scanned == nil then
			self.scanned = false
		end

		if self.itemGiven == nil then
			self.itemGiven = false
		end
		message.setHandler('scanInteraction', scanInteraction)
	end

	storage.state = config.getParameter("defaultSwitchState", false)

	if not storage.state then
		animator.setAnimationState("switchState", "off")
	else
		animator.setAnimationState("switchState", "on")
	end

	object.setInteractive(config.getParameter("interactive", true))
end

function scanInteraction(_, _, playerId)
	for _, scanType in pairs(self.scanFunctions) do
		if scanType == "logbook" then logScan(playerId)
		elseif scanType == "verboseOnly" then verboseScan()
		elseif scanType == "switch" then switchScan()
		elseif scanType == "radioMessage" then
			queueRadioMessage(playerId)
		elseif scanType == "giveItem" then itemScan(playerId, config.getParameter("spawnItem"))
		end
	end
end

function logScan(playerId)
	self.theme = config.getParameter("theme", "default")
	local configData = root.assetJson("/interface/scripted/pocsec/" .. self.theme .. "pocsec.config")
	configData.noteText = config.getParameter("logText")
	configData.codeImg = "/interface/scripted/pocsec/codes/" .. config.getParameter("codeImg", "blank") .. ".png"
	world.sendEntityMessage(playerId, "ex.openLogbook", configData)
end

function switchScan()
	if not self.scanned then
		if config.getParameter("objectSayUnscanned") then
			object.say(config.getParameter("objectSayUnscanned"))
		end
		self.scanned = true
		storage.state = true
		output(storage.state)
	else
		if config.getParameter("objectSayScanned") then
			object.say(config.getParameter("objectSayScanned"))
		end
  end
end

function verboseScan()
	if config.getParameter("verboseOnlyScan") then
		object.say(config.getParameter("verboseOnlyScan"))
	end
end

function itemScan(playerId, item)
	if self.itemGiven == nil or false then
		world.sendEntityMessage(playerId, "ex.giveItem", item)
		self.itemGiven = true
	end
end

function queueRadioMessage(playerId)
	self.radioMessages = config.getParameter("radioMessages") or {config.getParameter("radioMessage")}
	for _, i in pairs(self.radioMessages) do
		world.sendEntityMessage(playerId, "queueRadioMessage", i)
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

function onInteraction(args)
	if config.getParameter("persistent") then
		object.setInteractive(false)
	end
	output(not storage.state)
end

function output(state)
	storage.state = state
	if state then
		self.scanned = true
		animator.setAnimationState("switchState", "on")
		object.setAllOutputNodes(true)
	else
		self.scanned = false
		animator.setAnimationState("switchState", "off")
		object.setAllOutputNodes(false)
	end
end
