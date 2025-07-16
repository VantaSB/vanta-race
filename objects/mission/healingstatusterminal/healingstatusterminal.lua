require "/scripts/rect.lua"
require "/scripts/util.lua"

function init()
  self.activationTime = config.getParameter("activationTime")

	if object.isInputNodeConnected(0) then
		if not object.getInputNodeLevel(0) then
			animator.setAnimationState("terminalState", "expire")
			storage.active = false
			storage.lastActive = false
			object.setInteractive(false)
		else
			animator.setAnimationState("terminalState", "active")
			storage.active = true
			storage.lastActive = false
			object.setInteractive(true)
		end
	else
		animator.setAnimationState("terminalState", "active")
	  storage.active = true
	  storage.lastActive = false
	  object.setInteractive(true)
	end
end

function onInteraction(args)
  if storage.active then
    use(args)
  end
end

function onNodeConnectionChange(args)
	if object.isInputNodeConnected(0) then
		object.setInteractive(object.isInputNodeConnected(0) and object.getInputNodeLevel(0))
	else
		object.setInteractive(true)
	end
end

function onInputNodeChange(args)
	if object.isInputNodeConnected(0) then
		if object.getInputNodeLevel(0) then
			activate()
		else
			object.setInteractive(false)
			animator.setAnimationState("terminalState", "expire")
		end
	else
		activate()
	end
end

function update(dt)
  if isTimeToActivate() then
    activate()
  end
end

function isTimeToActivate()
  return storage.lastActive and world.time() - storage.lastActive > self.activationTime
end

function use(args)
  if storage.active then
		storage.lastActive = world.time()
		if not world.terrestrial() then
			world.setPlayerStart(vec2.add(entity.position(), {0, 0}), true)
			animator.burstParticleEmitter("saveText")
			animator.playSound("use2")
		end
    deactivate()

    local level = world.threatLevel()
    local projectileOptions = {}
    for _, option in ipairs(config.getParameter("projectileOptions"), {}) do
      if option.levelRange == nil or (level >= option.levelRange[1] and level <= option.levelRange[2]) then
        projectileOptions[#projectileOptions + 1] = option
      end
    end

    if #projectileOptions > 0 then
      local projectile = projectileOptions[math.random(#projectileOptions)]
      world.spawnProjectile(projectile.projectileType, object.position(), entity.id(), args.source, false, projectile.projectileParams)
			world.sendEntityMessage(args.sourceId, "applyStatusEffect", "ex_savestation")
    else
      sb.logInfo("No status projectiles available at level %s", world.threatLevel())
    end
  end
end

function activate()
	animator.playSound("ready")
  animator.setAnimationState("terminalState", "active")
  storage.active = true
  storage.lastActive = false
  object.setInteractive(true)
end

function deactivate()
	animator.playSound("use")
  animator.setAnimationState("terminalState", "expire")
  storage.active = false
  object.setInteractive(false)
end
