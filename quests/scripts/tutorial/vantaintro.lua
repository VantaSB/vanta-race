require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")

function init()
  message.setHandler("enterMissionArea", function(_, _, areaName)
    enterMissionArea(areaName)
  end)

  message.setHandler("vantaintroManagerId", function(_, _, id)
    self.managerId = id
  end)

  message.setHandler("giveBeamaxe", function(...)
    if self.missionStage == 5 then
      quest.setObjectiveList({{config.getParameter("descriptions.return"), false}})
      setStage(6)
    end
  end)

  quest.setParameter("uniformLocker", {type = "item", item = "nightarstoragelocker"})
  quest.setParameter("beamaxe", {type = "item", item = "researchcontainerbeamaxe"})
	quest.setParameter("battleGear", {type = "item", item = "vantalockers2"})
  quest.setIndicators({})

  setPortraits()

  self.startingMusicTimer = config.getParameter("startingMusicTime")
  self.midpointMusicTimer = 0

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

  quest.setObjectiveList({{config.getParameter("descriptions.briefing"), false}})
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
-- 1 - start -> exit bed
-- 2 - barracks
-- 3 - full uniform equipped
-- 4 - go to ops deck
-- 5 - get MM & scanner
-- 6 - return to ops deck
-- 7 - alert cutscene
-- 8 - equip battle gear
-- 9 - enter combat
-- 10 - find ship -> finish

function setStage(newStage)
  if newStage ~= self.missionStage then
    if newStage == 1 then
      self.hasLounged = false
			player.radioMessage("vantaIntroExitBed", 1)
			quest.setObjectiveList({{config.getParameter("descriptions.briefing"), false}})

		elseif newStage == 2 then
			quest.setIndicators({"uniformLocker"})
			player.radioMessage("vantaIntroBarracks", 1)

		elseif newStage == 3 then
      quest.setIndicators({})

		elseif newStage == 4 then

    elseif newStage == 5 then

    elseif newStage == 6 then
			player.giveEssentialItem("beamaxe", "vantamanipulator")
      player.giveEssentialItem("inspectionTool", "vantascanmode")
      world.sendEntityMessage(entity.id(), "playCinematic", "/cinematics/vantabeamaxe.cinematic")
      quest.setIndicators({})

		elseif newstage == 7 then

		elseif newStage == 8 then

		elseif newStage == 9 then
			player.radioMessage("vantaIntroAlertScene02c", 1)
			quest.setIndicators({})

		elseif newStage == 10 then

		elseif newStage == 11 then

    end
    self.missionStage = newStage
  end
end

function updateStage(dt)
	if self.missionStage < 7 then
		mcontroller.controlModifiers({runningSuppressed = true})
	end

  if self.missionStage == 1 then
    if self.hasLounged == false then
      local loungeables = world.loungeableQuery(entity.position(), 10, {order = "nearest"})
      if #loungeables > 0 then
        self.hasLounged = player.lounge(loungeables[1])
      end
    end

    if self.hasLounged and not player.isLounging() then
      setStage(2)
    end

	elseif self.missionStage == 2 then
		if hasUniform() then
			setStage(3)
		end
	elseif self.missionStage == 3 then

	elseif self.missionStage == 4 then

  elseif self.missionStage == 5 then
		quest.setIndicators({"beamaxe"})
    quest.setObjectiveList({{config.getParameter("descriptions.matterManipulator"), false}})

	elseif self.missionStage == 6 then

	elseif self.missionStage == 7 then
		quest.setObjectiveList({{config.getParameter("descriptions.repel"), false}})

	elseif self.missionStage == 8 then
		if hasGear() then
			setStage(9)
		end

	elseif self.missionStage == 9 then

	elseif self.missionStage == 10 then

  elseif self.missionStage == 11 then
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
-- Barracks
-- Commons
-- Operations Deck
-- Research & Development
-- Main Annex
-- Exterior Docking Bays
-- Xenoresearch
-- Offices
-- Emergency Launch Bay

function enterMissionArea(areaName)
  if areaName == "commons" and self.missionStage == 3 then
		setStage(4)

	elseif areaName == "opsDeck" and self.missionStage == 4 then
		setStage(5)

	elseif areaName == "rnd" and self.missionStage == 6 then
		world.sendEntityMessage(self.managerId, "midpointSwitch")
		world.sendEntityMessage(entity.id(), "playAltMusic", nil, 1.0)
		self.midpointMusicTimer = config.getParameter("midpointMusicTime")
		world.sendEntityMessage(entity.id(), "playCinematic", config.getParameter("midpointCinematic"))
		player.radioMessage("vantaIntroAlertScene01", 1)
		setStage(7)

	elseif areaName == "mainAnnex1" and self.missionStage == 7 then
		setStage(8)
		player.radioMessage("vantaIntroAlertScene02a", 1)
		player.radioMessage("vantaIntroAlertScene02b", 1)

	elseif areaName == "mainAnnex2" and self.missionStage == 8 then
		player.radioMessage("vantaIntroAlertScene02c", 1)
		quest.setIndicators({"battleGear"})

	elseif areaName == "exteriorDockingBays" and self.missionStage == 9 then
		setStage(10)
		player.radioMessage("vantaIntroLooting", 1)

	elseif areaName == "xenoresearch01" and self.missionStage == 10 then
		player.radioMessage("vantaIntroAlertScene03a", 1)
		player.radioMessage("vantaIntroAlertScene03b", 1)
		player.radioMessage("vantaIntroAlertScene03c", 1)
		player.radioMessage("vantaIntroAlertScene03d", 1)
		player.radioMessage("vantaIntroAlertScene03e", 1)
		player.radioMessage("vantaIntroAlertScene03f", 1)
		quest.setObjectiveList({{config.getParameter("descriptions.escape"), false}})

  elseif areaName == "ship" then
    setStage(11)
    self.missionCompleteTimer = 2.0
    world.sendEntityMessage(entity.id(), "playCinematic", config.getParameter("endpointCinematic"))
  end
end

function hasUniform()
	return player.hasItem("vantaflagofficerchest") and player.hasItem("vantaflagofficerlegs")
end

function hasGear()
	return player.hasItem("vantaintroenvirosuitchest") and player.hasItem("vantaintroenvirosuitpants")
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
