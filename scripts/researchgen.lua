require "/scripts/util.lua"

researchgen = {}
disabled = false
researchgen.itemTypes = nil

function update(dt)
  if not deltaTime or (deltaTime > 1) then
    deltaTime = 0
    researchgen.loadSelfContainer()
  else
    deltaTime = deltaTime + dt
  end
end

function researchgen.loadSelfContainer()
  storage.containerId = entity.id()
  researchgen.unloadSelfContainer()
  storage.inContainers[storage.containerId] = storage.position
  storage.outContainers[storage.containerId] = storage.position
end

function researchgen.unloadSelfContainer()
  storage.inContainers = {}
  storage.outContainers = {}
end
