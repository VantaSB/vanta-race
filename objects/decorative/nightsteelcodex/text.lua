function init()
	self.configData = root.assetJson("/interface/scripted/papernote/papernotegui.config")
	self.configData.noteText = config.getParameter("noteText", "...")
end

function onInteraction()
	return {"ScriptPane", self.configData}
end
