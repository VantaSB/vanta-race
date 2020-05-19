require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")

function init()
  message.setHandler("enterMissionArea", function(_, _, areaName)
    stageEnterArea(areaName)
  end)

  message.setHandler("__managerId", function(_, _, id)
    self.managerId = id
    world.sendEntityMaessage(self.managerId, "setSpecies", world.entitySpecies(entity.id()))
  end)

  message.setHandler("giveBeamaxe", function(...)
    if self.missionStage == 6 then
      setStage(7)
    end
  end)

  quest.setParameter("uniformLocker", {type = "item", item = ""})
  quest.setParameter("beamaxe", {type = "item", item = "vantamanipulator"})
  quest.setParameter("weaponChest", {type = "item", item = ""})
  quest.setIndicators({})

  setPortraits()

  self.startingMusicTimer = config.getParameter("startingMusicTime")
  self.midpointMusicTimer = 0

  self.pesterTimer = 0

  setStage(1)

  status.setPersistentEffects("introProtection", {
    { stat = "breathProtection", amount = 1.0 },
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
    quest.complete()
    return
  end

  storage.starterChest = player.equippedItem("chest")
  storage.starterLegs = player.equippedItem("legs")
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
  status.clearPersistentEffects("introProtection")

  if quest.state() == "Active" then
    -- player hasn't finished the mission
    -- confiscate any items the collected during this attempt
    for _, item in pairs(config.getParamter("confiscateItems", {})) do
      player.consumeItem(item, true)
    end
    player.consumeItem(storage.starterChest)
    player.consumeItem(storage.starterLegs)

    player.removeEssentialItem("beamaxe")

    -- cleanup and sort inventory to put default clothes back into slots
    player.cleanupItems()
    player.giveItem(storage.starterChest)
    player.giveItem(storage.starterLegs)
  end
end

-- MISSION STAGES
-- 1 - start => leave bed
-- 2 - prison cell
-- 3 - commons area
-- 4 - uniform
-- 5 - corridor
-- 6 - yard scene
-- 7 - armory
-- 8 - get MM
-- 9 - get weapons
-- 10 -
-- 11 - find ship => finish

function setStage(newStage)

end

function updateStage(dt)

end

-- MISSION AREAS
-- prisonerCommons
-- workyardCorridor
-- workyard
-- collapsedLobbyCorridor
-- collapsedLobby
-- duct01
-- researchLab
-- duct02
-- armoryCorridor
-- collapsedArmory
-- underground
-- hangar
-- ship

function stageEnterArea(areaName)

end

-- Updated for Vanta
function hasOutfit()
  return player.hasItem("vantaserfchest") and player.hasItem("vantaserfpants")
end

function hasEquippedOutfit()
  local chestItem = player.equippedItem("chest")
  local chestCosmeticItem = player.equippedItem("chestCosmetic")
  local legsItem = player.equippedItem("legs")
  local legsCosmeticItem = player.equippedItem("legsCosmetic")
  return ((chestItem and chestItem.name == "vantaserfchest") or (chestCosmeticItem and chestCosmeticItem.name == "vantaserfchest")) and ((legsItem and legsItem.name == "vantaserfpants") or (legsCosmeticItem and legsCosmeticItem.name == "vantaserfpants"))
end

function setPester(messageId, timeout)
  self.pesterMessage = messageId
  self.pesterTimer = timeout or 0
end

function updatePester(dt)
  if self.pesterTimer > 0 then
    self.pesterTimer = self.pesterTimer - dt
    if self.pesterTimer <= 0 then
      player.radioMessate(self.pesterMessage)
    end
  end
end
