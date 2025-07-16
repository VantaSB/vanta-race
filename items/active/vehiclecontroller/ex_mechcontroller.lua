function init()
	self.timer = 0
	self.mechState = false
end

function update(dt)
	if self.mechState then
		if self.timer > 0 then
			self.timer = self.timer - 1
		else
			world.sendEntityMessage(entity.id(), "deployMech")
			self.timer = 0
		end
	end
end

function activate(fireMode, shiftHeld)
	if fireMode == "primary" then
		self.mechState = true
		self.timer = 1.1
		update(self.timer)
	end
end

-- world.sendEntityMessage(entity.id(), "deployMech")
