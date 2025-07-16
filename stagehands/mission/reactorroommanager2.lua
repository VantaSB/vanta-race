require "/scripts/rect.lua"

function init()
	if config.getParameter("uniqueId") and config.getParameter("messageHandlerType") then
  	self.uniqueId = stagehand.setUniqueId(config.getParameter("uniqueId"))
  	self.broadcastArea = rect.translate(config.getParameter("broadcastArea", {-8, -8, 8, 8}), entity.position())
		if config.getParameter("qRadioMessages") or config.getParameter({"qRadioMessage"}) then
			self.radioMessages = config.getParameter("qRadioMessages") or config.getParameter({"qRadioMessage"})
		end
		self.cellCount = config.getParameter("cellCount")
  	message.setHandler(config.getParameter("messageHandlerType"), function(...)
			self.cellCount = self.cellCount - 1
			if self.cellCount == 0 then
				if self.radioMessages then
    			local playerList = world.entityQuery(rect.ll(self.broadcastArea), rect.ur(self.broadcastArea), {includedTypes = {"player"} })

    			for _, id in pairs(playerList) do
						for _, radioMessage in pairs(self.radioMessages) do
      				world.sendEntityMessage(id, "queueRadioMessage", radioMessage)
						end
					end
				end
    	end
  	end)
	else
		sb.logInfo("Stagehand 'reactorroommanager2' at %s does not have a uniqueId and/or a messageHandlerType configured - no messages will be handled.", entity.position())
	end
end
