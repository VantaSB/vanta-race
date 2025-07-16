function init()
	if config.getParameter("scanType") then
		self.scanType = config.getParameter("scanType")
		message.setHandler('scanInteraction', scanInteraction)
	end

	if self.scanned == nil then
		self.scanned = false
	end
end

function scanInteraction(_, _, playerId)
	if self.scanType == "logbook" then
		self.theme = config.getParameter("theme", "default")
		local configData = root.assetJson("/interface/scripted/pocsec/" .. self.theme .. "pocsec.config")
		configData.noteText = config.getParameter("logText")
		configData.codeImg = "/interface/scripted/pocsec/codes/" .. config.getParameter("codeImg", "blank") .. ".png"
		world.sendEntityMessage(playerId, "ex.openLogbook", configData)
	end
end
