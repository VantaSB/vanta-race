function init()
  self.interactData = config.getParameter("interactData")
  self.combinationLength = config.getParameter("combinationLength")
  --storage.persistent = config.getParameter("persistent", false)
  self.openCfg = config.getParameter("openCfg")
  storage.combination = config.getParameter("combination")
  storage.entry = ""
  self.timer = 0
  self.interval = config.getParameter("interval")

  message.setHandler("setKeypadCombination", function(_, _, newCombination)
    if type(newCombination) == "string" and #newCombination == self.combinationLength then
      storage.combination = newCombination
      clearEntry()
    end
  end)

  message.setHandler("setKeypadEntry", function(_, _, newEntry)
    storage.entry = newEntry
    checkCombination()
  end)

  object.setInteractive(true)
end

function onInteraction(args)
  self.interactData.combination = storage.combination
  self.interactData.entry = storage.entry
  self.interactData.combinationLength = self.combinationLength
  self.interactData.openCfg = self.openCfg
  return {"ScriptPane", self.interactData}
end

function update(dt)
  if self.timer > 0 then
    object.setInteractive(false)
    self.timer = self.timer - 1
    if self.timer == 0 then
      clearEntry()
      object.setInteractive(true)
    end
  end
end

function checkCombination()
  if tostring(storage.entry) == tostring(storage.combination) then
    if self.openCfg == "delay" then
      self.timer = self.interval
    elseif self.openCfg == "persistent" then
      object.setInteractive(false)
    end
    object.setOutputNodeLevel(0, true)
  else
    object.setOutputNodeLevel(0, false)
  end
end

function clearEntry()
  storage.entry = ""
  checkCombination()
end
