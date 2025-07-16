data = nil

function init()
	data = root.assetJson("/interface/scripted/keycardreader/keycards.config")
	self.keycardType = config.getParameter("keycardType")
	update()
end

function update(dt)
	local keycard = player.getProperty("ex_keyItem_"..self.keycardType)
	widget.setText("costDescription", data.keycardText[self.keycardType])

	if not keycard then
		widget.setText("costLabel", "NOT ACQUIRED")
		widget.setFontColor("costLabel", {255, 0, 0})
	else
		widget.setText("costLabel", "ACQUIRED")
		widget.setFontColor("costLabel", {0, 255, 0})
	end
	widget.setButtonEnabled("activateButton", keycard)
end

function activate()
	world.sendEntityMessage(pane.sourceEntity(), "activate")
	pane.dismiss()
end
