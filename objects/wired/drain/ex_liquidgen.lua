--[[
  Liquid IDs:

  1 - Water
  2 - Lava
  3 - Poison
  5 - Liquid Oil
  7 - Milk
  11 - Fuel
  12 - Swamp Water
  13 - Slime Liquid
  17 - Jelly Liquid

  230 - Liquid Ceruleum
]]


function init()
  self.liquidGen = config.getParameter("liquidGen", 1)
end

function update(dt)
  if not object.isInputNodeConnected(0) or object.getInputNodeLevel(0) then
    world.spawnLiquid(object.position(), self.liquidGen, 1.0)
  end
end
