require "/scripts/rect.lua"

function init()
  self.containsPlayers = {}
  self.broadcastArea = rect.translate(config.getParameter("broadcastArea", {-8, -8, 8, 8}), entity.position())
  self.signalRegion = rect.translate(config.getParameter("signalRegion", {-8, -8, 8, 8}), entity.position())
  self.reactorDestroyed = 0

  -- Need to fix this for the mission itself
  message.setHandler("midpointSwitch", function(...)
    -- Matter Manipulator call function (important!)
    local beamaxeSearchArea = rect.translate({360, -10, 400, 10}, entity.position())
    world.objectQuery(rect.ll(beamaxeSearchArea), rect.ur(beamaxeSearchArea), {callScript = "showBeamaxe"})

    -- NPC Search; will likely remove this part
    --local npcSearchArea = rect.translate({200, -50, 360, 50}, entity.position())
    --world.npcQuery(rect.ll(npcSearchArea), rect.ur(npcSearchArea), {callScript = "status.setResource", callScriptArgs = {"health", 0}})

    -- Enable combat against enemy NPCs
    --world.setProperty("nonCombat", false)
  end)

  --[[message.setHandler("reactorDestroyed", function(...)
    self.reactorDestroyed = self.reactorDestroyed + 1
    if self.reactorDestroyed == 5 then
      --world.placeDungeon("reactorRoomDestroyed", {276, 163}, "vantaintro")
      world.sendEntityMessage(entity.id(), "timeToEscape")
    end
    sb.logInfo("Reactor at position %s destroyed", object.position())
  end)

  message.setHandler("setSpecies", function(_, _, species) self.species = species end)

  self.hasUpdatedShip = false]]

  --sb.logInfo("Initializing Vanta Intro manager with broadcastArea %s", self.broadcastArea)
end

function update(dt)
  world.loadRegion(self.signalRegion)
  queryPlayers()

  --[[if self.species and not self.hasUpdatedShip then
    local shipSearchArea = rect.translate({800, -50, 900, 50}, entity.position())
    local ships = world.objectQuery(rect.ll(shipSearchArea), rect.ur(shipSearchArea), {callScript = "setSpecies", callScriptArgs = {self.species}})
    self.hasUpdatedShip = #ships > 0
  end]]
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
