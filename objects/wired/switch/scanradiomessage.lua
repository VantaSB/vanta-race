function init()
  message.setHandler('scanInteraction', scanInteraction)

  self.radioMessages = config.getParameter("exRadioMessages") or {config.getParameter("exRadioMessage")}

  if storage.triggered == nil then
    storage.triggered = false
  end

  if storage.rescannable == nil then
    storage.rescannable = config.getParameter("rescannable", true)
  end
end

function scanInteraction(_, _, playerId)
  if not storage.triggered then
    if config.getParameter("exRadioMessage") ~= nil then
      world.sendEntityMessage(playerId, "ex.radioMessage", self.radioMessage)
      storage.triggered = true
    else return end
  end

  if storage.triggered and storage.rescannable then
    for _, message in ipairs(self.radioMessages) do
      world.sendEntityMessage(playerId, "ex.radioMessage", message)
    end
  end
end
