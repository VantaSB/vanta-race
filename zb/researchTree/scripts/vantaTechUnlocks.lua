function newSphere(sphereTech)
  if sphereTech == "vantasphere" then
    player.makeTechAvailable("vantasphere")
    player.enableTech("vantasphere")
    player.equipTech("vantasphere")
  elseif sphereTech == "vantananosphere" then
    player.makeTechAvailable("vantananosphere")
    player.enableTech("vantananosphere")
    player.equipTech("vantananosphere")
    player.makeTechUnavailable("vantasphere")
  elseif sphereTech == "vantananosphere2" then
    player.makeTechAvailable("vantananosphere2")
    player.enableTech("vantananosphere2")
    player.equipTech("vantananosphere2")
    player.makeTechUnavailable("vantananosphere")
  end
end

function newDash(dashTech)
  if dashTech == "vantastealthsprint" then
    player.makeTechAvailable(dashTech)
  end
end
