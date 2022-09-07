require "/scripts/rect.lua"

function init()
  self.broadcastArea = rect.translate(config.getParameter("broadcastArea", {-8, -8, 8, 8}), entity.position())
  self.zoneType = config.getParameter("zoneType", "ex_airlesszone")
  if self.zoneType == "ex_airlesszone" then
    world.setDungeonId(self.broadcastArea, 1)
    world.setTileProtection(1, true)
    world.setDungeonBreathable(1, false)
  end
end

function update(dt)
  local playerList = world.entityQuery(rect.ll(self.broadcastArea), rect.ur(self.broadcastArea), {includedTypes = {"player"} })
  for _, id in pairs(playerList) do
    world.sendEntityMessage(id, "ex.temperaturezone", self.zoneType)
  end
end
