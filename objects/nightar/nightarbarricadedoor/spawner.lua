require "/scripts/util.lua"

function init()
	animator.setAnimationState("doorState", "closed")
	self = config.getParameter("spawner")
	if not self then
		sb.logError("NPC Spawner at %s is missing configuration", object.position())
		return
	end

	object.setInteractive(false)
	self.position = object.toAbsolutePosition(self.position)
	storage.cooldown = storage.cooldown or util.randomInRange(self.frequency or {0, 0})
	storage.stock = storage.stock or self.stock

	message.setHandler('scanInteraction', scanInteraction)

	storage.triggered = false
end

function update(dt)
	if storage.stock ~= 0 then storage.cooldown = storage.cooldown - dt end

	if storage.cooldown <= 0 and ((not self.trigger) or (self.trigger == "wire" and object.getInputNodeLevel(0))) then
		spawn()
		storage.cooldown = util.randomInRange(self.frequency or {0, 0})
	end
end

function scanInteraction(_, _, playerId)
	if config.getParameter("verboseOnlyScan") then
		object.say(config.getParameter("verboseOnlyScan"))
	end
end

function onInputNodeChange(args)
	if object.getInputNodeLevel(0) and not storage.triggered then
		animator.playSound("alarm", 5)
		storage.triggered = true
	end
end

function spawn()
	animator.setAnimationState("doorState", "open")
	local attempts = 10
	while attempts > 0 do
		local spawnPosition = {}
		for i, val in ipairs(self.positionVariance) do
			if val == 0 then
				spawnPosition[i] = self.position[i]
			else
				spawnPosition[i] = self.position[i] + math.random(val) - (val / 2)
			end
		end

		if not self.outOfSight or not world.isVisibleToPlayer({spawnPosition[1] - 3, spawnPosition[2] - 3, spawnPosition[1] + 3, spawnPosition[2] + 3}) then
			local npcId = world.spawnNpc(spawnPosition, self.species, self.typeName, world.threatLevel(), sb.makeRandomSource():randu32(), self.parameterOptions or {})
			if npcId ~= 0 then
				storage.stock = storage.stock - 1
				if storage.stock == 0 then
					animator.setAnimationState("doorState", "closing")
				end
				return
			end
		end
		attempts = attempts - 1
	end
end
