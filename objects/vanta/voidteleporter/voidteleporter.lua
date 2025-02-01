require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
	storage.state = storage.state or false
	self.sourceId = nil
	self.networked = nil
	self.locked = true
	self.interval = config.getParameter("interval", 30)
	storage.timer = 0

	message.setHandler("openDoor", function()
		if animator.animationState("doorState") == "closed" or animator.animationState("doorState") == "closing" or animator.animationState("doorState") == "locked" or animator.animationState("doorState") == "locking" then
			if self.locked then
				animator.setAnimationState("doorState", "lockOpen")
			else
				animator.setAnimationState("doorState", "opening")
			end
			animator.playSound("open")
			storage.timer = self.interval
		end
	end)

	object.setInteractive(true)
	animator.setAnimationState("doorState", "locked")
end

function update(dt)
	if not self.networked then
		checkNodes()
	end
	if storage.timer > 0 then
		storage.timer = storage.timer - 1
		if storage.timer == 10 and self.sourceId ~= nil then
			world.sendEntityMessage(self.sourceId, "applyStatusEffect", "ex_orbwarp", 0.1, self.networked)
		end
		if storage.timer == 0 then
			if self.locked then
				animator.setAnimationState("doorState", "locking")
			else
				animator.setAnimationState("doorState", "closing")
			end
			animator.playSound("close")
			self.sourceId = nil
		end
	end
end

function onInteraction(args)
	self.sourceId = args.sourceId
	if self.locked then
    animator.playSound("locked")
  else
		if self.networked then
			animator.setAnimationState("doorState", "opening")
			animator.playSound("open")
			storage.timer = self.interval
			world.loadUniqueEntity(self.networked)
			world.sendEntityMessage(self.networked, "openDoor")
			world.sendEntityMessage(self.sourceId, "playCinematic", "/cinematics/teleport/ex_doorwarp.cinematic")
		end
	end
end

function onNodeConnectionChange(args)
	checkNodes()
end

function onInputNodeChange(args)
	checkNodes()
end

function checkNodes()
	if object.isOutputNodeConnected(0) then
    for id,_ in pairs(object.getOutputNodeIds(0)) do
      if world.entityExists(id) then
        self.networked = id
				object.setOutputNodeLevel(0, true)
        if object.isInputNodeConnected(0) then
          if object.getInputNodeLevel(0) then
            self.locked = false
          else
            self.locked = true
          end
        else
          self.locked = false
        end
      end
    end
  else
    self.networked = nil
    self.locked = true
  end
end

function setLocked(args)
  if not args then
    animator.setAnimationState("doorState", "closed")
  else
    animator.setAnimationState("doorState", "locked")
  end
end
