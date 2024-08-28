require "/scripts/rect.lua"
require "/scripts/stagehandutil.lua"

function init()
	self.active = true
	self.uniqueId = config.getParameter("uniqueId", nil)
	stagehand.setUniqueId(self.uniqueId)
  self.broadcastArea = rect.translate(config.getParameter("broadcastArea", {-8, -8, 8, 8}), entity.position())
  self.zoneType = config.getParameter("zoneType", "ex_airlesszone")

	message.setHandler("toggle", function()
		if self.active then
			self.active = false
			if self.zoneType == "ex_airlesszone" then toggleAirless(self.active) end
		elseif not self.active then
			self.active = true
			if self.zoneType == "ex_airlesszone" then toggleAirless(self.active) end
		end
	end)

	if self.zoneType == "ex_airlesszone" then
		world.setDungeonId(self.broadcastArea, 1)
    world.setTileProtection(1, true)
		toggleAirless(self.active)
	end
end

function update(dt)
	if self.active then
  	local playerList = world.entityQuery(rect.ll(self.broadcastArea), rect.ur(self.broadcastArea), {includedTypes = {"player"} })
  	for _, id in pairs(playerList) do
    	world.sendEntityMessage(id, "ex.temperaturezone", self.zoneType)
		end
  end
end

function toggleAirless(newState)
	if newState then
    world.setDungeonBreathable(1, false)
	else
		world.setDungeonBreathable(1, true)
	end
end
