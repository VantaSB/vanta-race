require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
	object.setInteractive(true)
	storage.timer = 0
	storage.position = object.position()
	storage.statusDuration = string.format("%g.%g", storage.position[1], storage.position[2])

	self.networkedDoor = nil
	self.locked = false
	self.interval = config.getParameter("interval", 30)
	self.openLightColor = config.getParameter("openLight")

	message.setHandler("openDoor", function(_, _, playerId)
		storage.sourceId = playerId
		if self.locked then
			animator.setAnimationState("doorState", "lockOpen")
		else
			animator.setAnimationState("doorState", "open")
		end
		object.setLightColor(self.openLightColor)
		animator.setLightActive("doorLight", true)
		storage.timer = self.interval
	end)
end

function update(dt)
	if not self.networkedDoor then
		checkNodes()
	end

	if object.isInputNodeConnected(1) then
		if object.getInputNodeLevel(1) then
			self.locked = false
		else
			self.locked = true
		end
	end

	if storage.timer > 0 then
		storage.timer = storage.timer - 1
		if storage.timer == 10 and storage.sourceId ~= nil then
			world.sendEntityMessage(storage.sourceId, "applyStatusEffect", "ex_propdoorwarp", tonumber(storage.statusDuration))
		elseif storage.timer == 0 then
			if self.locked then
				animator.setAnimationState("doorState", "locking")
			else
				animator.setAnimationState("doorState", "closing")
			end
			animator.playSound("close")
			storage.sourceId = nil
		end
	end

	world.debugText("Lock: " .. sb.printJson(self.doorLocked), vec2.add(entity.position(), {0,1}), "orange")
  world.debugText("Link ID: " .. sb.printJson(self.connectedDoor), vec2.add(entity.position(), {0,0}), "orange")
end

function onInteraction(args)
	storage.sourceId = args.sourceId
	if self.networkedDoor then
		if self.locked then
			animator.playSound("locked")
		else
			animator.playSound("open")
			animator.setAnimationState("doorState", "open")
			storage.timer = self.interval
			world.sendEntityMessage(self.networkedDoor, "openDoor", storage.sourceId)
			world.sendEntityMessage(storage.sourceId, "playCinematic", "/cinematics/teleport/ex_doorwarp.cinematic")
			storage.sourceId = nil
		end
	else
		animator.playSound("locked")
	end
end

function onNodeConnectionChange(args)
	checkNodes()
end

function checkNodes()
	self.networkedDoor = nil
	animator.setAnimationState("doorState", "locked")
	object.setOutputNodeLevel(0, false)

	for id, _ in pairs(object.getOutputNodeIds(0)) do
		self.networkedDoor = id
		object.setOutputNodeLevel(0, true)
		animator.setAnimationState("doorState", "closed")
		object.setLightColor(self.openLightColor)
	end
end
