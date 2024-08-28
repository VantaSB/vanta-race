require "/scripts/rect.lua"

function init()
  self.containsPlayers = {}
  self.broadcastArea = rect.translate(config.getParameter("broadcastArea", {-8, -8, 8, 8}), entity.position())
  self.signalRegion = rect.translate(config.getParameter("signalRegion", {-8, -8, 8, 8}), entity.position())

  -- Need to fix this for the mission itself
  message.setHandler("midpointSwitch", function(...)
		local npcSearchArea = rect.translate({-250, -250, 325, 250}, entity.position())
		world.npcQuery(rect.ll(npcSearchArea), rect.ur(npcSearchArea), {callScript = "status.setResource", callScriptArgs = {"health", 0}})
  end)

  --sb.logInfo("Initializing Vanta Intro manager with broadcastArea %s", self.broadcastArea)
end

function update(dt)
  world.loadRegion(self.signalRegion)
  queryPlayers()
end

function queryPlayers()
  local newPlayerList = world.entityQuery(rect.ll(self.broadcastArea), rect.ur(self.broadcastArea), {includedTypes = {"player"}})
  local newPlayers = {}
  for _, id in pairs(newPlayerList) do
    if not self.containsPlayers[id] then
      world.sendEntityMessage(id, "vantaintroManagerId", entity.id())
    end
    newPlayers[id] = true
  end
  self.containsPlayers = newPlayers
end
