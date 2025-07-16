require "/scripts/vec2.lua"

function init()
	storage.active = storage.active or false
	object.setAllOutputNodes(config.getParameter("inverse", false))
	updateCollisionAndWires()
end

function update(dt)
	if not storage.active then
		object.setHealth(9999)
	end
end

function onNodeConnectionChange(args)
	updateCollisionAndWires()
end

function onInputNodeChange(args)
	updateCollisionAndWires()
end

function updateCollisionAndWires()
	if object.isInputNodeConnected(0) then
    if object.getInputNodeLevel(0) then
      animator.setAnimationState("light", "on")
			animator.playSound("powerOn")
			object.setLightColor({169, 27, 27})
			object.setConfigParameter("smashable", true)
			object.setHealth(1)
			script.setUpdateDelta(0)
			storage.active = true
    else
      animator.setAnimationState("light", "off")
			object.setLightColor({0, 0, 0})
			object.setConfigParameter("smashable", false)
			script.setUpdateDelta(config.getParameter("scriptDelta", 5))
			storage.active = false
    end
  else
    animator.setAnimationState("light", "on")
		animator.playSound("powerOn")
		object.setLightColor({169, 27, 27})
		object.setConfigParameter("smashable", true)
		object.setHealth(1)
		script.setUpdateDelta(0)
		storage.active = true
  end
	sb.logInfo("Parameter 'smashable' set to: %s", config.getParameter("smashable"))
end
