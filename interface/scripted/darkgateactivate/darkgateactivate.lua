function init()
  --self.activateItem = config.getParameter("activateItem")
  --self.required = config.getParameter("requiredCount")

  update()
end

function update(dt)
  local current = player.getProperty("ex_keyItem_darkgatekey")
	if not current then
		widget.setText("costLabel", "NOT ACQUIRED")
		widget.setFontColor("costLabel", {255, 0, 0})
		widget.setButtonEnabled("activateButton", false)
	else
		widget.setText("costLabel", "ACQUIRED")
		widget.setFontColor("costLabel", {0, 255, 0})
		widget.setButtonEnabled("activateButton", true)
	end
  --widget.setText("costLabel", string.format("%s / %s", current, self.required))
  --widget.setFontColor("costLabel", current >= self.required and {0, 255, 0} or {255, 0, 0})
  --widget.setButtonEnabled("activateButton", current >= self.required)
end

function activate()
  --if player.consumeItem({name = self.activateItem, count = self.required}) then
    world.sendEntityMessage(pane.sourceEntity(), "activate")
    pane.dismiss()
  --end
end
