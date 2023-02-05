require "/scripts/stagehandutil.lua"

function init()
  self.containsPlayers = {}
  animator.setAnimationState("light", "default", false)
  self.dialog = root.assetJson("/objects/decorative/nightsteelmonitor/dialogoptions.config:" .. config.getParameter("dialog"))

  self.uniqueId = config.getParameter("uniqueId")
  if self.uniqueId then object.setUniqueId(self.uniqueId) end

  self.unlockId = config.getParameter("unlockId")
  self.radioMessages = config.getParameter("exRadioMessages") or {config.getParameter("exRadioMessage")}

  if self.dialog then
    object.setInteractive(true)
  else
    sb.logWarn("Dialog parameter not set for nightsteelmonitor at %s; disabling interactivity.", object.Position())
    object.setInteractive(false)
    animator.setAnimationState("light", "comm", false)
  end
end

function onInteraction(args)
  if not storage.used then
    animator.setAnimationState("light", "comm", false)
    sayNext(args.sourceId)
  end
end

function sayNext(id)
  self.dialogInterval = 8.0
  if self.dialog and #self.dialog > 0 then
    if #self.dialog > 0 then
      local options = {
        drawMoreIndicator = true
      }
      self.dialogTimer = self.dialogInterval
      if #self.dialog == 1 then
        options.drawMoreIndicator = false
        self.dialogTimer = 0.0
        if self.unlockId and not storage.used then
          world.sendEntityMessage(self.unlockId, "openDoor")
          for _, message in ipairs(self.radioMessages) do
            world.sendEntityMessage(id, "queueRadioMessage", message)
          end
        end
      end

      object.sayPortrait(self.dialog[1][1], self.dialog[1][2], nil, options)
      table.remove(self.dialog, 1)

      return true
    end
  else
    self.dialog = nil
    return false
  end
end

function update(dt)
  if self.dialogTimer then
    self.dialogTimer = math.max(self.dialogTimer - dt, 0.0)
    if self.dialogTimer == 0 and not sayNext() then
      self.dialogTimer = nil
      storage.used = true
    end
  end
end
