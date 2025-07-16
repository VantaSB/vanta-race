function init()
	effect.setParentDirectives("multiply=00000025")
	animator.setParticleEmitterActive("sparks", false)
	script.setUpdateDelta(5)
end

function update(dt)
	if mcontroller.groundMovement() then
		animator.setParticleEmitterActive("sparks", true)
	else
		animator.setParticleEmitterActive("sparks", false)
	end
end

function uninit()

end
