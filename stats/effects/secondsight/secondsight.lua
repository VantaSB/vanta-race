require "/scripts/vec2.lua"

function init()
  self.enemyDetectRadius = 80
  self.enemyDetectQueryParameters = {
    boundMode = "position",
    includedTypes = {"monster","npc"}
  }

  self.enemyDetectTypeNames = {
    "crustoise", "iguarmor", "oculob", "pulpin", "snaggler", "tentacrawler", "tintic", "triplod", "apexmutant", "glitchknight", "glitchspider", "po", "pogolem", "sewerfly", "swarpion", "agrobat", "batong", "bobfae", "monopus", "parasprite",
    "paratail", "pteropod", "scandroid", "tentaclebomb", "tentaclegnat", "tentaclespawner", "erchiusghost", "gosmet", "ignome", "lumoth", "nautileech", "pyromantle", "skimbus", "spookit", "squeem", "tentacleghost", "wisper", "ballista", "helicultist", "ixoling",
    "kluexsentry", "kluextotem", "minidrone", "moontant", "anglure", "bobot", "bulbop", "capricoat", "crabcano", "crutter", "fennix", "gleap", "hemogoblin", "hemogoblinbutt", "hemogoblinhead", "hypnare", "kingnutmidgeling", "lilodon", "mandraflora", "miasmop",
    "narfin", "nutmidge", "nutmidgeling", "oogler", "orbide", "peblit", "petricub", "pipkin", "poptop", "punchy", "quagmutt", "rex", "ringram", "scaveran", "smoglin", "snaunt", "snuffish", "sporgus", "tank", "taroni",
    "tentaclebarrier", "tentacleclam", "toumingo", "trictus", "voltip", "yokat", "fish", "smallfish", "largebiped", "largequadruped", "smallbiped", "smallquadruped"
  }

  for _, name in ipairs(self.enemyDetectTypeNames) do
    self.enemyDetectTypeNames[name] = true
  end

  self.playerId = entity.id()
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
