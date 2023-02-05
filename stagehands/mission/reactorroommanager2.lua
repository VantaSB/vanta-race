require "/scripts/rect.lua"

function init()
  self.uniqueId = stagehand.setUniqueId("reactorroommanager2")
  self.broadcastArea = rect.translate(config.getParameter("broadcastArea", {-8, -8, 8, 8}), entity.position())
  self.reactorDestroyed = 0

  message.setHandler("reactorOn", function(...)
    local playerList = world.entityQuery(rect.ll(self.broadcastArea), rect.ur(self.broadcastArea), {includedTypes = {"player"} })

    for _, id in pairs(playerList) do
      world.sendEntityMessage(id, "reactorOn")
    end
  end)
end
