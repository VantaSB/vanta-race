function init()
	effect.setParentDirectives(config.getParameter("directives", ""))
	world.sendEntityMessage(entity.id(), "queueRadioMessage", "radioactivezone")
  self.healthPercentage = config.getParameter("healthPercentage", 0.1)
end

function update(dt)
  status.setResourcePercentage("health", math.min(status.resourcePercentage("health"), self.healthPercentage))
end

function uninit()

end
