require "/scripts/vec2.lua"

function init()
  updateMaterialSpaces()
  object.setOutputNodeLevel(0, true)
end

function onInputNodeChange(args)
  updateMaterialSpaces()
end

function setupMaterialSpaces()

end

function updateMaterialSpaces()
  self.inactiveMaterialSpaces = config.getParameter("inactiveMaterialSpaces")
  if not self.inactiveMaterialSpaces then
    self.inactiveMaterialSpaces = {}
    local metamaterial = "metamaterial:lockedDoor"
    for _, space in ipairs(object.spaces()) do
      table.insert(self.inactiveMaterialSpaces, {space, metamaterial})
    end
  end
  self.activeMaterialSpaces = config.getParameter("activeMaterialSpaces", {})
  if object.isInputNodeConnected(0) then
    if object.getInputNodeLevel(0) then
      animator.setAnimationState("light", "on")
      object.setMaterialSpaces(self.activeMaterialSpaces)
    else
      animator.setAnimationState("light", "off")
      object.setMaterialSpaces(self.inactiveMaterialSpaces)
    end
  else
    animator.setAnimationState("light", "on")
    object.setMaterialSpaces(self.activeMaterialSpaces)
  end
end

function die(smash)
  if smash then
    world.spawnProjectile(config.getParameter("explosionProjectile", "explosivebarrel"), vec2.add(object.position(), config.getParameter("explosionOffset", {0,0})), entity.id(), {0,0})
  end
end
