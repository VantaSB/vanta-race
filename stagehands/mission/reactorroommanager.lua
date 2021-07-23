require "/scripts/rect.lua"

function init()
  self.uniqueId = stagehand.setUniqueId("reactorroommanager")
  self.broadcastArea = rect.translate(config.getParameter("broadcastArea", {-8, -8, 8, 8}), entity.position())
  self.reactorDestroyed = 0

  message.setHandler("reactorDestroyed", function(...)
    self.reactorDestroyed = self.reactorDestroyed + 1
    if self.reactorDestroyed == 5 then
      local playerList = world.entityQuery(rect.ll(self.broadcastArea), rect.ur(self.broadcastArea), {includedTypes = {"player"} })

      for _, id in pairs(playerList) do
        world.sendEntityMessage(id, "reactorsDestroyed")
      end
    end
  end)
end
