require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")

function init()
  self.reactorDestroyed = 0
  message.setHandler("enterMissionArea", function(_, _, areaName)
    stageEnterArea(areaName)
  end)

  message.setHandler("vantaintroManagerId", function(_, _, id)
    self.managerId = id
    world.sendEntityMessage(self.managerId, "setSpecies", world.entitySpecies(entity.id()))
  end)

  message.setHandler("giveBeamaxe", function(...)
    if self.missionStage == 4 then
      quest.setIndicators({})
      quest.setObjectiveList({{config.getParameter("descriptions.findEngineering"), false}})
      setStage(5)
    end
  end)

  message.setHandler("reactorsDestroyed", function(...)
    player.radioMessage("vantaintroPowerDownAlert")
    self.midpointTransitionTimer = 2.0
    self.midpointMusicTimer = config.getParameter("midpointMusicTime")
    world.sendEntityMessage(entity.id(), "playAltMusic", nil, 1.0)
    quest.setObjectiveList({{config.getParameter("descriptions.escape"), false}})
    setStage(6)
  end)

  quest.setParameter("beamaxe", {type = "item", item = "researchcontainerbeamaxe"})
  --quest.setParameter("reactors", {type = "item", item = "nightarreactor"})
  quest.setIndicators({})

  setPortraits()

  self.startingMusicTimer = config.getParameter("startingMusicTime")
  self.midpointMusicTimer = 0

  self.pesterTimer = 0

  setStage(1)

  status.setPersistentEffects("vantaintroProtection", {
    --Need to have multiple stats here due to the different types of attacks from enemies; phyiscal resistance set to near-max since death in the intro mission will
    { stat = "breathProtection", amount = 1.0 },
    { stat = "physicalResistance", amount = 1.0 },
    { stat = "fireResistance", amount = 1.0 },
    { stat = "iceResistance", amount = 1.0 },
    { stat = "electricResistance", amount = 1.0 },
    { stat = "poisonResistance", amount = 1.0 },
    { stat = "fireStatusImmunity", amount = 1.0 },
    { stat = "iceStatusImmunity", amount = 1.0 },
    { stat = "electricStatusImmunity", amount = 1.0 },
    { stat = "poisonStatusImmunity", amount = 1.0 },
    { stat = "fallDamageMultiplier", effectiveMultiplier = 0.0 }
  })
end

function questStart()
  player.giveEssentialItem("inspectiontool", "inspectionmode")

  if player.introComplete() then
    for _, item in pairs(config.getParameter("skipIntroItems", {})) do
      player.giveItem(item)
    end
    player.giveEssentialItem("beamaxe", "vantamanipulator")
    player.giveEssentialItem("inspectionTool", "vantascanmode")
    quest.complete()
    return
  end

  storage.starterChest = player.equippedItem("chest")
  storage.starterLegs = player.equippedItem("legs")
end

function questComplete()
  player.setIntroComplete(true)

  questutil.questCompleteActions()

  player.startQuest("bootship")
end

function update(dt)
  if self.startingMusicTimer > 0 then
    self.startingMusicTimer = self.startingMusicTimer - dt
    if self.startingMusicTimer <= 0 then
      world.sendEntityMessage(entity.id(), "playAltMusic", config.getParameter("startingMusicTracks"))
    end
  end

  if self.midpointMusicTimer > 0 then
    self.midpointMusicTimer = self.midpointMusicTimer - dt
    if self.midpointMusicTimer <= 0 then
      world.sendEntityMessage(entity.id(), "playAltMusic", config.getParameter("midpointMusicTracks"))
    end
  end

  updateStage(dt)

  updatePester(dt)
end

function uninit()
  status.clearPersistentEffects("vantaintroProtection")

  if quest.state() == "Active" then
    -- player hasn't finished the mission
    -- confiscate any items the collected during this attempt
    for _, item in pairs(config.getParameter("confiscateItems", {})) do
      player.consumeItem(item, true)
    end
    player.consumeItem(storage.starterChest)
    player.consumeItem(storage.starterLegs)

    player.removeEssentialItem("beamaxe")
    player.giveEssentialItem("inspectiontool", "inspectionmode")

    -- cleanup and sort inventory to put default clothes back into slots as well as melee fists
    player.cleanupItems()
    player.giveItem(storage.starterChest)
    player.giveItem(storage.starterLegs)
  end
end

-- MISSION STAGES
-- 1 - start -> leave cryopod
-- 2 - cryobay
-- 3 - left cryobay
-- 4 - r&d room
-- 5 - has MM & ScanMode
-- 6 - destroyed reactors
-- 7 - ops deck
-- 8 - hangar entrance
-- 9 - find ship => finish

function setStage(newStage)
  if newStage ~= self.missionStage then
    if newStage == 1 then
      self.hasLounged = false
    elseif newStage == 2 then
      player.radioMessage("vantaintroExitBed", 1)
      setPester("vantaintroCryoBayPester", 40)
    elseif newStage == 3 then
      quest.setIndicators({})
    elseif newStage == 4 then
      --
    elseif newStage == 5 then
      player.giveEssentialItem("beamaxe", "vantamanipulator")
      player.giveEssentialItem("inspectionTool", "vantascanmode")
      world.sendEntityMessage(entity.id(), "playCinematic", "/cinematics/vantabeamaxe.cinematic")
      quest.setIndicators({})
    elseif newstage == 6 then
      --
    elseif newstage == 7 then
      --
    elseif newstage == 8 then
      --
    elseif newstage == 9 then
      world.sendEntityMessage(entity.id(), "playAltMusic", nil, 1.0)
    end
    self.missionStage = newStage
  end
end

function updateStage(dt)
  if self.missionStage == 1 then
    if self.hasLounged == false then
      local loungeables = world.loungeableQuery(entity.position(), 10, {order = "nearest"})
      if #loungeables > 0 then
        self.hasLounged = player.lounge(loungeables[1])
      end
    end

    if self.hasLounged and not player.isLounging() then
      setStage(2)
      quest.setObjectiveList({{config.getParameter("descriptions.leaveCryoBay"), false}})
    end

  elseif self.missionStage == 4 then
    quest.setIndicators({"beamaxe"})
    quest.setObjectiveList({{config.getParameter("descriptions.getMM"), false}})

  elseif self.missionStage == 9 then
    if self.missionCompleteTimer > 0 then
      self.missionCompleteTimer = self.missionCompleteTimer - dt
      if self.missionCompleteTimer <= 0 then
        player.warp("ownship")
        quest.complete()
      end
    end
  end
end

-- MISSION AREAS
-- crypobay
-- cryobay access
-- navigation room
-- weapons lab
-- engineering access
-- escape hall
-- ops deck
-- aux room 1
-- hangar
-- ship

function stageEnterArea(areaName)
  if areaName == "cryobay" then
    player.radioMessage("vantaintroCryoBayTutorial01")
    player.radioMessage("vantaintroCryoBayTutorial02")
  elseif areaName == "cryoBayAccess" and self.missionStage == 2 then
    setStage(3)
    quest.setObjectiveList({{config.getParameter("descriptions.explore"), false}})
    player.radioMessage("vantaintroCryoBayAccessTutorial")
  elseif areaName == "navigationRoom" then
    player.radioMessage("vantaintroNavigationRoom01")
    player.radioMessage("vantaintroNavigationRoom02")
    player.radioMessage("vantaintroNavigationRoom03")
  elseif areaName == "weaponsLab" then
    setStage(4)
    player.radioMessage("vantaintroLabAlert")
    player.radioMessage("vantaintroWeaponsLab01")
    player.radioMessage("vantaintroWeaponsLab02")
  elseif areaName == "scanSwitch" then
    player.radioMessage("vantaintroWeaponsLab03")
    player.radioMessage("vantaintroWeaponsLab04")
  elseif areaName == "engineeringAccess" then
    player.radioMessage("vantaintroEngineeringAccess")
    quest.setObjectiveList({{config.getParameter("descriptions.reactorRoom"), false}})
  elseif areaName == "escapeHall01" then
    player.radioMessage("vantaintroEscape01")
  elseif areaName == "adminElevators" then
    player.radioMessage("vantaintroEscape02")
  elseif areaName == "opsRoomElevators" then
    --
  elseif areaName == "opsRoom" and self.missionStage == 6 then
    player.radioMessage("vantaintroEscape03")
    setStage(7)
  elseif areaName == "auxRoom01" then
    player.radioMessage("vantaintroEscape04")
  elseif areaName == "auxRoom02" and self.missionStage == 7 then
    player.radioMessage("vantaintroEscape05")
    setStage(8)
  elseif areaName == "hangar" then
    player.radioMessage("vantaintroHangar")
  elseif areaName == "ship" then
    setStage(9)
    self.missionCompleteTimer = 2.0
    world.sendEntityMessage(entity.id(), "playCinematic", config.getParameter("endpointCinematic"))
  end
end



function setPester(messageId, timeout)
  self.pesterMessage = messageId
  self.pesterTimer = timeout or 0
end

function updatePester(dt)
  if self.pesterTimer > 0 then
    self.pesterTimer = self.pesterTimer - dt
    if self.pesterTimer <= 0 then
      player.radioMessage(self.pesterMessage)
    end
  end
end
