function init()
	object.setConfigParameter("breakDropPool", "empty")

	self.relicItem = config.getParameter("relicItem")

	storage.claimed = storage.claimed or config.getParameter("defaultState", false)

	if config.getParameter("uniqueId") then
		object.setUniqueId(config.getParameter("uniqueId"))
	end

	if storage.claimed then
		for parameter, value in pairs(config.getParameter("pickedUpParameters")) do
	    object.setConfigParameter(parameter, value)
	  end
		animator.setAnimationState("relicStatue", "claimed", true)
		object.setInteractive(false)
		object.setAllOutputNodes(true)
		object.setLightColor({0, 0, 0})
	else
		animator.setAnimationState("relicStatue", "unclaimed", true)
		object.setInteractive(true)
		object.setAllOutputNodes(false)
		object.setLightColor({7, 86, 89})
	end

	message.setHandler("claimed", function()
		pickupRelic()
	end)
end

function pickupRelic()
	for parameter, value in pairs(config.getParameter("pickedUpParameters")) do
    object.setConfigParameter(parameter, value)
  end

	storage.claimed = true
	animator.setAnimationState("relicStatue", "claiming", true)
	world.spawnItem(self.relicItem, entity.position(), 1)

	if animator.hasSound("obtained") then
		animator.playSound("obtained")
	end

	object.setInteractive(false)
	object.setAllOutputNodes(true)
	object.setLightColor({0, 0, 0})
end

function onInteraction(args)
	if not storage.claimed then
		pickupRelic()
	end
end
