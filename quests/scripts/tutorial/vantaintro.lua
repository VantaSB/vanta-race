require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")

function init()
  message.setHandler("enterMissionArea", function(_, _, areaName)
    enterMissionArea(areaName)
  end)

  message.setHandler("vantaintroManagerId", function(_, _, id)
    self.managerId = id
    world.sendEntityMessage(self.managerId, "setSpecies", world.entitySpecies(entity.id()))
  end)

  message.setHandler("giveStarterContents", function(...)
    world.sendEntityMessage(entity.id(), "playCinematic", "/cinematics/intro/ex_equipgear.cinematic")
    player.consumeItem(storage.starterChest)
    player.consumeItem(storage.starterLegs)
    player.giveItem("vantaemgpistol")
    player.giveItem("brokennoxcalibur")
    player.giveItem(storage.starterChest)
    player.giveItem(storage.starterLegs)
    player.radioMessage("vantaIntroEquipment1")
    player.radioMessage("vantaIntroEquipment2")
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

  quest.setParameter("starterGear", {type = "item", item = "nightarcachepod"})
  quest.setParameter("beamaxe", {type = "item", item = "researchcontainerbeamaxe"})
  quest.setIndicators({})

  setPortraits()

  self.startingMusicTimer = config.getParameter("startingMusicTime")
  self.midpointMusicTimer = 0

  self.navRoomDelayTrigger1 = 0
  self.navRoomDelayTrigger2 = 0

  self.pesterTimer = 0

  setStage(1)

  player.playCinematic(config.getParameter("introCinematic"))

  status.setPersistentEffects("vantaintroProtection", {
    --Need to have multiple stats here due to the different types of attacks from enemies; phyiscal resistance set to near-max since death in the intro mission will result in getting beamed back to the ship with no way to restart the mission.
    { stat = "breathProtection", amount = 1.0 },
    { stat = "physicalResistance", amount = 0.9 },
    { stat = "fireResistance", amount = 0.9 },
    { stat = "iceResistance", amount = 0.9 },
    { stat = "electricResistance", amount = 0.9 },
    { stat = "poisonResistance", amount = 0.9 },
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

  quest.setObjectiveList({{config.getParameter("descriptions.exitSolitary"), false}})
end

function questComplete()
  player.setIntroComplete(true)

  questutil.questCompleteActions()
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

  if self.navRoomDelayTrigger1 > 0 then
    self.navRoomDelayTrigger1 = self.navRoomDelayTrigger1 - dt
    if self.navRoomDelayTrigger1 <= 0 then
      world.sendEntityMessage("navRoom1Door", "unlock")
    end
  end

  if self.navRoomDelayTrigger2 > 0 then
    self.navRoomDelayTrigger2 = self.navRoomDelayTrigger2 - dt
    if self.navRoomDelayTrigger2 <= 0 then
      world.sendEntityMessage("navRoom1Door", "unlock")
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
      player.consumeItem(item, true, false)
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
-- 2 - restricted hall
-- 3 - acquired gear
-- 4 - manipulator room
-- 5 - have MM & scan mode
-- 6 - find ship => finish

function setStage(newStage)
  if newStage ~= self.missionStage then
    if newStage == 1 then
      self.hasLounged = false
    elseif newStage == 2 then
      player.radioMessage("vantaIntroExitPod", 1)
      setPester("vantaIntroConfinementPester", 40)
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
      quest.setObjectiveList({{config.getParameter("descriptions.exitSolitary"), false}})
    end

  elseif self.missionStage == 4 then
    quest.setIndicators({"beamaxe"})
    quest.setObjectiveList({{config.getParameter("descriptions.matterManipulator"), false}})

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
-- Confinement Room
-- Restricted Hall
-- Biotech 1
-- Weapons Cache
-- Elevator A
-- Manipulator Research
-- Data Vault
-- Nav Room 1
-- Elevator B
-- Biotech 2
-- Commons
-- Nav Room 2
-- Outer Plaza
-- Ship Platform

function enterMissionArea(areaName)
  if areaName == "detentionHall" and self.missionStage == 2 then
    setStage(3)
    player.radioMessage("vantaIntroDetentionHall1")
    player.radioMessage("vantaIntroDetentionHall2")
  elseif areaName == "bioTech1" then
    player.radioMessage("vantaIntroBioTech")
    quest.setObjectiveList({{config.getParameter("descriptions.findGear"), false}})
  elseif areaName == "bioTech2" then
    player.radioMessage("vantaIntroMedkit")
  elseif areaName == "bioTech3" then
    player.radioMessage("vantaIntroCacheHall")
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
