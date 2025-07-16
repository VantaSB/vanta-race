function init()
  self.armRotation = 0
  self.rotations = 3
  self.rotationTime = 0.15
  self.jumpDuration = 0.2
  self.energyUsage = 20
  self.groundJump = false
  self.flipTimer = 0
	self.jumpTimer = self.jumpDuration
	self.flipTime = self.rotations * self.rotationTime
	self.fadeTimer = 0.1
end

function reinit()
	if self.groundJump then
		animator.playSound("multiJumpStopSound")
	end
	self.flipTimer = 0
	self.groundJump = false
	self.jumpTimer = self.jumpDuration
	animator.setParticleEmitterActive("multiJumpParticles", false)
  mcontroller.setRotation(0)
	status.clearPersistentEffects("movementAbility")
	status.clearAllPersistentEffects("jumpgrit")
	tech.setParentState()
	tech.setParentDirectives("")
	tech.setToolUsageSuppressed(false)
end

function uninit()
  reinit()
end

function update(args)
  local jumpActivated = args.moves["jump"] and not self.lastJump
  self.lastJump = args.moves["jump"]

  if self.groundJump then
    if mcontroller.onGround() then
      reinit()
    else
			tech.setParentState("sit")
      tech.setToolUsageSuppressed(true)
			animator.setParticleEmitterActive("multiJumpParticles", true)
      if mcontroller.xVelocity() < 0 then
				animator.setFlipped(true)
			else
				animator.setFlipped(false)
			end
			status.setPersistentEffects("jumpgrit", {{stat = "grit", amount = 1}})
			flip(args.dt)
    end
  end

  if jumpActivated then
    local yVel = mcontroller.yVelocity()
    if mcontroller.onGround() and not status.statPositive("activeMovementAbilities") and not mcontroller.liquidMovement() and math.abs(mcontroller.xVelocity()) > 2 then
			self.groundJump = true
			animator.playSound("multiJumpSound")
    else
      if canMultiJump() and self.groundJump and (yVel < 10 and yVel > -45) then
        doMultiJump()
      end
    end
  end
end

function flip(dt)
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
	self.flipTimer = self.flipTimer + dt
	tech.setParentDirectives("?fade=c78fc5;0.4")
	if self.jumpTimer > 0 then
		self.jumpTimer = self.jumpTimer - dt
		tech.setParentDirectives("?fade=b368b1;0.4")
	end

  mcontroller.setRotation(-math.pi * 2 * mcontroller.facingDirection() * (self.flipTimer / self.rotationTime))
  mcontroller.controlParameters({collisionPoly = { {-1.8, -1.8},  {1.8, -1.8}, {1.8, 1.8}, {-1.8, 1.8} }  })
end

function canMultiJump()
  return not mcontroller.jumping()
    and not mcontroller.canJump()
    and not mcontroller.liquidMovement()
    and self.groundJump
    and status.overConsumeResource("energy", self.energyUsage)
end

function doMultiJump()
	animator.playSound("multiJumpLoopSound")
  mcontroller.controlJump(true)
  mcontroller.setYVelocity(math.max(0, mcontroller.yVelocity()))
end
