function init()
  self.interactData = config.getParameter("interactData")
  self.combinationLength = config.getParameter("combinationLength")
  storage.persistent = config.getParameter("persistent", false)
  storage.combination = config.getParameter("combination")
  storage.entry = ""
  storage.timer = 0
  self.interval = config.getParameter("interval")

  message.setHandler("setKeypadEntry", function(_, _, newEntry)
    storage.entry = newEntry
    checkCombination()
    if tostring(storage.entry) == tostring(storage.combination) then
      object.setOutputNodeLevel(0, true)
      object.setInteractive(false)
      storage.timer = self.interval
    end
  end)

  object.setInteractive(true)
end

function onInteraction(args)
  self.interactData.combination = storage.combination
  self.interactData.entry = storage.entry
  self.interactData.combinationLength = self.combinationLength
  return {"ScriptPane", self.interactData}
end

function update(dt)
  if not storage.persistent then
    if storage.timer > 0 then
      storage.timer = storage.timer - 1
      if storage.timer == 0 then
        clearEntry()
        object.setOutputNodeLevel(0,false)
        object.setInteractive(true)
      end
    end
  end
end

function checkCombination()
  object.setOutputNodeLevel(0, storage.entry == storage.combination)
end

function clearEntry()
  storage.entry = ""
  checkCombination()
end
