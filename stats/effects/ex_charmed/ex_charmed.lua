function init()
	effect.setParentDirectives("fade=b368b1=0.15")

	for _,particleEmitter in ipairs(config.getParameter("particleEmitters")) do
		animator.setParticleEmitterActive(particleEmitter, true)
	end

	script.setUpdateDelta(5)
	local protection = status.stat("protection")
	effect.addStatModifierGroup({
		{stat = "jumpModifier", amount = -0.15},
		{stat = "protection", amount = protection*0.65},
		{stat = "powerMultiplier", effectiveMultiplier = 0.65}
	})
end

function update(dt)
	mcontroller.controlModifiers({
		speedModifier = 0.75,
		airJumpModifier = 0.85,
		runningSuppressed = true
	})
end

function uninit()

end
