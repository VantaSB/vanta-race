function init()
  self.enabled = config.getParameter("enabled", true)
  if self.enabled == true then
    self.entry = config.getParameter("entry", "")
    self.combination = config.getParameter("combination")
    self.combinationLength = config.getParameter("combinationLength")
    self.statusLightImage = config.getParameter("statusLightImage")
    self.openCfg = config.getParameter("openCfg")

    self.flashTime = config.getParameter("flashTime")
    self.flashTimer = 0

    if not self.combination then
      setFlash({"red", "off"})
    else
      setFlash()
      sb.logInfo(self.combination)
    end

    updateEntry()
  end
end

function update(dt)
  if self.flashStates then
    self.flashTimer = self.flashTimer - dt
    if self.flashTimer <= 0 then
      self.flashTimer = self.flashTime
    end

    local flashFrame = (self.flashTimer / self.flashTime) > 0.5 and self.flashStates[1] or self.flashStates[2]
    widget.setImage("imgStatusLight", self.statusLightImage .. ":" .. flashFrame)
  else
    if tostring(self.entry) == tostring(self.combination) then
      if self.openCfg ~= nil then
        pane.dismiss()
      else
        widget.setImage("imgStatusLight", self.statusLightImage .. ":green")
      end
    else
      widget.setImage("imgStatusLight", self.statusLightImage .. ":yellow")
    end
  end
end

function enterDigit(widgetName, data)
  if #self.entry < self.combinationLength then
    self.entry = self.entry .. data
    updateEntry()
  end
end

function clear(widgetName, data)
  self.entry = ""
  updateEntry()
end

function updateEntry()
  if self.combination then
    world.sendEntityMessage(pane.sourceEntity(), "setKeypadEntry", self.entry)
  elseif #self.entry == self.combinationLength then
    world.sendEntityMessage(pane.sourceEntity(), "setKeypadCombination", self.entry)
    self.combination = self.entry
    self.entry = ""
    setFlash()
  end

  for i = 1, self.combinationLength do
    widget.setVisible("imgDigit" .. i, i <= #self.entry)
  end
end

function setFlash(flashStates)
  self.flashStates = flashStates
  self.flashTimer = self.flashTime
end

function checkCombination()
  return self.combination and self.combination == self.entry
end
