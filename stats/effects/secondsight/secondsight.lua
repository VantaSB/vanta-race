require "/scripts/vec2.lua"

function init()
  self.enemyDetectRadius = config.getParameter("enemyDetectRadius")
  self.enemyDetectQueryParameters = {
    boundMode = "position",
    includedTypes = {"monster","npc"}
  }

  self.enemyDetectTypeNames = {}

  for _, name in ipairs(config.getParameter("enemyDetectTypeNames")) do
    self.enemyDetectTypeNames[name] = true
  end

  localAnimator.clearDrawables()
end

function update(dt)
  drawEnemyIndicators()
end

function drawEnemyIndicators()
  if self.enemyDetectRadius then
    local pos = entity.position()
    local enemiesNearby = world.entityQuery(entity.position(), self.enemyDetectRadius, self.enemyDetectQueryParameters)
    for _, eId in ipairs(enemiesNearby) do
      if world.entityCanDamage(eId, self.playerId) and self.enemyDetectTypeNames[string.lower(world.entityTypeName(eId))] then
        local enemyVec = world.distance(world.entityPosition(eId), pos)
        local dist = vec2.mag(enemyVec)
        if dist > 7 then
          local arrowAngle = vec2.angle(enemyVec)
          local arrowOffset = vec2.withAngle(arrowAngle, 6.5)
          localAnimator.addDrawable({
                image = "/scripts/deployment/enemyarrow.png",
                rotation = arrowAngle,
                position = arrowOffset,
                fullbright = true,
                centered = true,
                color = {255, 255, 255, 255 * (1 - dist / self.enemyDetectRadius)}
              }, "overlay")
        end
      end
    end
  end
end
