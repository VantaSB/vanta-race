function init()
  self.keycardType = config.getParameter("keycardType", "nightar")
  if self.keycardType == "nightar" then
    self.keycardPrefix = "keycard1_"
    self.labelText = "Nightar Keycard"
  else
    self.keycardPrefix = "keycard2_"
    self.labelText = "Vanta Keycard"
  end
  self.requiredLevel = config.getParameter("requiredLevel", 0)
  if self.requiredLevel == 0 then
    self.lvText = "Lv.0"
    self.textColor = {255, 255, 255}
  elseif self.requiredLevel == 1 then
    self.lvText = "Lv.1"
    self.textColor = {0, 127, 255}
  elseif self.requiredLevel == 2 then
    self.lvText = "Lv.2"
    self.textColor = {0, 255, 0}
  elseif self.requiredLevel == 3 then
    self.lvText = "Lv.3"
    self.textColor = {255, 255, 0}
  elseif self.requiredLevel == 4 then
    self.lvText = "Lv.4"
    self.textColor = {255, 0, 0}
  end

  self.neededKeycard = self.keycardPrefix .. tostring(self.requiredLevel)
  self.keycardText = self.labelText .. " " .. self.lvText
end

function update(dt)
  local current = player.hasItem(self.neededKeycard)
  widget.setText("itemLabel", self.keycardText)
  widget.setFontColor("itemLabel", self.textColor)
  widget.setButtonEnabled("activateButton", current)
  if current then
    widget.setText("costLabel", "[^#00FF00;O^reset;]")
  else
    widget.setText("costLabel", "[^#FF0000;X^reset;]")
  end
end

function activate()
  world.sendEntityMessage(pane.sourceEntity(), "activate")
  pane.dismiss()
end
