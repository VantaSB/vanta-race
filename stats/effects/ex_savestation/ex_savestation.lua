function init()
	self.healingRate = config.getParameter("healAmount", 30) / effect.duration()
	effect.setParentDirectives("fade=6eff2a;0.5?border=2;31613175;00000000")
end

function update(dt)
	status.modifyResource("health", self.healingRate * dt)
end

function uninit()

end
