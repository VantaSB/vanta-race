require "/scripts/vec2.lua"

function init()
	local duration = effect.duration()
	self.dest = {}
	self.worldSize = world.size()
	for str in string.gmatch(tostring(duration), "([^.]+)") do
		table.insert(self.dest, tonumber(str))
	end

	self.destLengthY = string.len(tostring(self.dest[2]))
	self.worldSizeY = string.len(tostring(self.worldSize[2]))

	self.dest[2] = string.sub(tostring(self.dest[2]), 1, self.worldSizeY)
	if tonumber(self.dest[2]) > self.worldSize[2] then
		self.dest[2] = tonumber(self.dest[2] / 10)
	end
end

function update()
  local finalDest = vec2.add(self.dest, {2.5, 2.5})
	world.sendEntityMessage(effect.sourceEntity(), "openDoor")
	mcontroller.setPosition(finalDest)
	effect.expire()
end
