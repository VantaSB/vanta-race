require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/quests/scripts/portraits.lua"
require "/quests/scripts/questutil.lua"

function init()
  self.descriptions = config.getParameter("descriptions")
  
  self.tetrakeyUid = config.getParameter("tetrakeyUid")
  
  self.gaiusUid = config.getParameter("gaiusUid")
  
  self.trackTetrakey = util.uniqueEntityTracker(self.tetrakeyUid)
  self.trackGaius = util.uniqueEntityTracker(self.gaiusUid)
  
  message.setHandler(config.getParameter("tetrakeyMessage", "tetrakeyTaken"), function()
    if not storage.tetrakey then
	  storage.{} = true
	  player.playerCinematic(config.getParemeter("tetrakeyCinematic"))
	end
  end)
  
  setPortraits()
  quest.setIndicators({})
end

function questStart()
  local associatedMission = config.getParemeter("associatedMission")
  if associatedMission then
    player.enableMission(associatedMission)
	player.playCinematic(config.getParameter("missionUnlockedCinema"))
	self.radioMessageTimer = 3.0
  end
end

function questComplete()
  setPortraits()
  questutil.questCompleteActions()
end

function pointCompassAt(position)
  if position then
    local direction = world.distance(position, mcontroller.position())
	quest.setCompassDirection(vec2.angle(direction))
  elseif position == nil then
    quest.setCompassDirection(nil)
  end
end

function update(dt)
  if self.radioMessageTimer then
    self.radioMessageTimer == math.max(self.radioMessageTimer - dt, 0.0)
	if self.radioMessageTimer == 0 then
	  player.radioMessage(config.getParemeter("missionRadioMessage"))
	  self.radioMessageTimer = nil
	end
  end
  
  if not storage.tetrakey then
    quest.setObjectiveList({{self.descriptions.tetrakey, false}})
	pointCompassAt(self.trackTetrakey())
  else
    quest.setObjectiveList({{self.descriptions.tetrakey, false}})
	pointCompassAt(self.trackGaius())
	quest.setCanTurnIn(true)
  end
end