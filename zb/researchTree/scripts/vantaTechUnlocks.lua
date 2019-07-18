function newSphere(sphereTech)
  if sphereTech == "vantasphere" then
    player.makeTechAvailable(sphereTech)
    player.enableTech(sphereTech)
    player.equipTech(sphereTech)
  elseif sphereTech == "vantananosphere" then
    player.makeTechAvailable(sphereTech)
    player.enableTech(spheretech)
    player.equipTech(sphereTech)
    player.makeTechUnavailable("vantasphere")
  elseif sphereTech == "vantananosphere2" then
    player.makeTechAvailable(sphereTech)
    player.enableTech(spheretech)
    player.equipTech(sphereTech)
    player.makeTechUnavailable("vantananosphere")
  end
end

function newDash(dashTech)
  if dashTech == "vantastealthsprint" then
    player.makeTechAvailable(dashTech)
  end
end
