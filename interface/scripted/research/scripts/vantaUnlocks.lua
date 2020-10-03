function giveEssentialItem(item)
  if item == "vantamanipulator" then
    player.giveEssentialItem("beamaxe", "vantamanipulator")
  end
end

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
  if dashTech == "vantastealth1" then
    player.makeTechAvailable("vantastealth1")
    player.enableTech("vantastealth1")
    player.equipTech("vantastealth1")
  elseif dashTech == "vantastealth2" then
    player.makeTechAvailable("vantastealth2")
    player.enableTech("vantastealth2")
    player.equipTech("vantastealth2")
    player.makeTechUnavailable("vantastealth1")
  elseif dashTech == "vantastealth3" then
    player.makeTechAvailable("vantastealth3")
    player.enableTech("vantastealth3")
    player.equipTech("vantastealth3")
    player.makeTechUnavailable("vantastealth2")
  end
end
