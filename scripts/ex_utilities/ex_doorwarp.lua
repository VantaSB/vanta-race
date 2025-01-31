require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
	storage.state = storage.state or false
  self.sourceId = nil
  self.networkedDoor = nil
  self.locked = true
  self.interval = config.getParameter("interval", 30)
  storage.timer = 0

  message.setHandler("openDoor", function()
    if animator.animationState("doorState") == "closed" or animator.animationState("doorState") == "closing" or animator.animationState("doorState") == "locked" or animator.animationState("doorState") == "locking" then
      if self.locked then
        animator.setAnimationState("doorState", "lockOpen")
      else
        animator.setAnimationState("doorState", "open")
      end
      animator.playSound("open")
      animator.setLightActive("doorLight", true)
      storage.timer = self.interval
    end
  end)

  object.setInteractive(true)
  animator.setLightColor("doorLight", config.getParameter("openLight"))
  animator.setAnimationState("doorState", "locked")
  animator.setLightActive("doorLight", false)
end

function update(dt)
  if not self.networkedDoor then
    checkNodes()
  end
  if storage.timer > 0 then
    storage.timer = storage.timer - 1
    if storage.timer == 10 and self.sourceId ~= nil then
      world.sendEntityMessage(self.sourceId, "applyStatusEffect", "ex_propdoorwarp", 0.1, self.networkedDoor)
    end
    if storage.timer == 0 then
      if self.locked then
        animator.setAnimationState("doorState", "locking")
        animator.setLightActive("doorLight", false)
      else
        animator.setAnimationState("doorState", "closing")
        animator.setLightActive("doorLight", true)
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
    if self.networkedDoor then
      animator.setAnimationState("doorState", "open")
      animator.playSound("open")
      storage.timer = self.interval
			world.loadUniqueEntity(self.networkedDoor)
      world.sendEntityMessage(self.networkedDoor, "openDoor")
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
        self.networkedDoor = id
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
    self.networkedDoor = nil
    self.locked = true
  end
  setLocked(self.locked)
end

function setLocked(args)
  if not args then
    --self.locked = false
    animator.setAnimationState("doorState", "closed")
    animator.setLightActive("doorLight", true)
  else
    --self.locked = true
    animator.setAnimationState("doorState", "locked")
    animator.setLightActive("doorLight", false)
  end
end
