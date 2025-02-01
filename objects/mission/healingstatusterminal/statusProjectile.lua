function init()
  self.activationTime = config.getParameter("activationTime")

  if storage.active == nil then activate() end

  animator.setAnimationState("terminalState", storage.active and "active" or "expire")
end

function onInteraction(args)
  if storage.active then
    use(args)
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
  storage.lastActive = world.time()
  object.setInteractive(false)
end
