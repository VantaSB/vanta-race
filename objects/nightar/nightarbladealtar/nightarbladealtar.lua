function init()
  self.configData = root.assetJson("/interface/scripted/vantaupgrade/vantaupgradegui.config")
	self.configData.nextUpgrade = config.getParameter("nextUpgrade", 10)
end

function onInteraction()
	return { "ScriptPane", self.configData }
end
