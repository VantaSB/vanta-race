require "/scripts/util.lua"
require "/scripts/messageutil.lua"

function init()
  setDirection(storage.doorDirection or object.direction())

  storage.locked = config.getParameter("locked", false) or (object.isInputNodeConnected(1) and object.getInputNodeLevel(1))

  self.uniqueId = config.getParameter("uniqueId")
  if self.uniqueId then
    object.setUniqueId(self.uniqueId)
  end

  self.sensorConfig = config.getParameter("sensorConfig")
  if self.sensorConfig then
    self.sensorConfig.detectEntityTypes = self.sensorConfig.detectEntityTypes or {"Player", "Npc"}
    self.sensorConfig.detectBoundMode = self.sensorConfig.detectBoundMode or "CollisionArea"
    self.sensorConfig.detectDuration = self.sensorConfig.detectDuration or 3
    self.sensorConfig.detectTimer = 0
    local detectArea = self.sensorConfig.detectArea
    local pos = object.position()
    if not detectArea or detectArea == "horizontal" then
      local bb = object.boundBox()
      self.sensorConfig.detectArea = {
        {bb[1] - 1, bb[2] + 0},
        {bb[3] + 1, bb[4] - 0}
      }
    elseif detectArea == "vertical" then
      local bb = object.boundBox()
      self.sensorConfig.detectArea = {
        {bb[1] + 1, bb[2] - 4},
        {bb[3] - 1, bb[4] + 4}
      }
    elseif type(detectArea[2]) == "number" then
      --center and radius
      self.sensorConfig.detectArea = {
        {pos[1] + detectArea[1][1], pos[2] + detectArea[1][2]},
        detectArea[2]
      }
    elseif type(detectArea[2]) == "table" and #detectArea[2] == 2 then
      --rect corner1 and corner2
      self.sensorConfig.detectArea = {
        {pos[1] + detectArea[1][1], pos[2] + detectArea[1][2]},
        {pos[1] + detectArea[2][1], pos[2] + detectArea[2][2]}
      }
    end
  end

  if storage.locked == nil or false then
    if storage.locked then animator.setAnimationState("doorState", "locked") end
  end

  if storage.state == nil then
    if config.getParameter("defaultState") == "open" then
      openDoor()
    else
      closeDoor()
    end
  else
    animator.setAnimationState("doorState", storage.state and "open" or "closed")
  end

  updateCollisionAndWires()
  updateInteractive()
  updateLight()

  message.setHandler("unlockDoor", function() unlockDoor() sb.logInfo("Message was received.") end)
  message.setHandler("openDoor", function() openDoor() end)
  message.setHandler("closeDoor", function() closeDoor() end)
  message.setHandler("lockDoor", function() lockDoor() end)
end

function update(dt)
	if config.getParameter("requiresCompletedQuest") ~= nil then
		promises:update()

		local players = world.playerQuery(object.position(), config.getParameter("queryRange", 8))
		if #players > 0 then
			for _, playerId in pairs (players) do
				promises:add(
					world.sendEntityMessage(playerId, "player.hasCompletedQuest", config.getParameter("requiresCompletedQuest")),
					function(canBeOpened)
						if canBeOpened and not storage.locked then
							object.setInteractive(true)
						else
							object.setInteractive(false)
						end
				end)
			end
		else
			if not storage.locked then
				object.setInteractive(true)
			else
				object.setInteractive(false)
			end
		end
	end



  if self.sensorConfig then
    self.sensorConfig.detectTimer = math.max(0, self.sensorConfig.detectTimer - dt)

    if not storage.locked and not object.isInputNodeConnected(0) then
      local entityIds = world.entityQuery(self.sensorConfig.detectArea[1], self.sensorConfig.detectArea[2], {
          withoutEntityId = entity.id(),
          includedTypes = self.sensorConfig.detectEntityTypes,
          boundMode = self.sensorConfig.detectBoundMode
        })

      if #entityIds > 0 then
        self.sensorConfig.detectTimer = self.sensorConfig.detectDuration
      end

      if self.sensorConfig.detectTimer > 0 then
        openDoor()
      else
        closeDoor()
      end
    end
  end
end

function onNodeConnectionChange(args)
  updateInteractive()
  updateCollisionAndWires()
  if object.isInputNodeConnected(0) then
    onInputNodeChange({ level = object.getInputNodeLevel(0) })
  end

	if object.isInputNodeConnected(1) then
		updateInteractive()
	end
end

function onInputNodeChange(args)
  if object.isInputNodeConnected(0) then
		if args.level then
    	openDoor(storage.doorDirection)
  	else
    	closeDoor()
		end
  end

	if object.isInputNodeConnected(1) then
		if args.level then
			unlockDoor()
			updateInteractive()
		else
			lockDoor()
			updateInteractive()
		end
	end
end

function onInteraction(args)
  if storage.locked then
    animator.playSound("locked")
  else
    if not storage.state then
      openDoor(args.source[1])
    else
      closeDoor()
    end
  end
end

function updateLight()
  if not storage.state then
    object.setLightColor(config.getParameter("closedLight", {0,0,0}))
  else
    object.setLightColor(config.getParameter("openLight", {0,0,0}))
  end
end

function updateInteractive()
	if object.isInputNodeConnected(0) and not object.isInputNodeConnected(1) then
  	object.setInteractive(false)
	else
		object.setInteractive(true)
	end

	if object.isInputNodeConnected(1) and not object.isInputNodeConnected(0) then
		if object.getInputNodeLevel(1) then
			object.setInteractive(true)
			unlockDoor()
		else
			object.setInteractive(false)
			lockDoor()
		end
	end
end

function updateCollisionAndWires()
  setupMaterialSpaces()
  object.setMaterialSpaces(storage.state and self.openMaterialSpaces or self.closedMaterialSpaces)
  object.setAllOutputNodes(storage.state)
end

function setupMaterialSpaces()
  self.closedMaterialSpaces = config.getParameter("closedMaterialSpaces")
  if not self.closedMaterialSpaces then
    self.closedMaterialSpaces = {}
    local metamaterial = "metamaterial:door"
    if object.isInputNodeConnected(0) then
      metamaterial = "metamaterial:lockedDoor"
    end
    for _, space in ipairs(object.spaces()) do
      table.insert(self.closedMaterialSpaces, {space, metamaterial})
    end
  end
  self.openMaterialSpaces = config.getParameter("openMaterialSpaces", {})
end

function setDirection(direction)
  storage.doorDirection = direction
  animator.setGlobalTag("doorDirection", direction < 0 and "Left" or "Right")
end

function hasCapability(capability)
  if capability == 'lockedDoor' then
    return storage.locked
  elseif object.isInputNodeConnected(0) or storage.locked or self.sensorConfig then
    return false
  elseif capability == 'door' then
    return true
  elseif capability == 'closedDoor' then
    return not storage.state
  elseif capability == 'openDoor' then
    return storage.state
  else
    return false
  end
end

function doorOccupiesSpace(position)
  local relative = {position[1] - object.position()[1], position[2] - object.position()[2]}
  for _, space in ipairs(object.spaces()) do
    if math.floor(relative[1]) == space[1] and math.floor(relative[2]) == space[2] then
      return true
    end
  end
  return false
end

function lockDoor()
  if not storage.locked then
    storage.locked = true
    --updateInteractive()
    if storage.state then
      -- close door before locking
      storage.state = false
      animator.playSound("close")
      animator.setAnimationState("doorState", "locking")
      updateCollisionAndWires()
    else
      animator.setAnimationState("doorState", "locked")
    end
    return true
  end
end

function unlockDoor()
  if storage.locked then
    storage.locked = false
    --updateInteractive()
    animator.setAnimationState("doorState", "closed")
  end
end

function closeDoor()
  if storage.state ~= false then
    storage.state = false
    updateInteractive()
    animator.playSound("close")
    animator.setAnimationState("doorState", "closing")
    updateCollisionAndWires()
    updateLight()
    for _, space in ipairs(object.spaces()) do
      world.forceDestroyLiquid(space)
    end
  end
end

function openDoor(direction)
  if not storage.state then
    storage.state = true
    storage.locked = false -- make sure we don't get out of sync when wired
    updateInteractive()
    setDirection((direction == nil or direction * object.direction() < 0) and -1 or 1)
    animator.playSound("open")
    animator.setAnimationState("doorState", "open")
    updateCollisionAndWires()
    updateLight()
  end
end
