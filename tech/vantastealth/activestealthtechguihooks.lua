preActiveStealthInit = init

function init()
	if contains(player.enabledTechs(), "activestealthtech") and not contains(player.enabledTechs(), "activestealthtechhead") then
	  player.makeTechAvailable("activestealthtechhead")
      player.enableTech("activestealthtechhead")
	end
	if contains(player.enabledTechs(), "activestealthtech") and not contains(player.enabledTechs(), "activestealthtechhead-agent") then
	  player.makeTechAvailable("activestealthtechhead-agent")
	end
	if contains(player.enabledTechs(), "activestealthtech") and not contains(player.enabledTechs(), "activestealthtechhead-assassin") then
	  player.makeTechAvailable("activestealthtechhead-assassin")
	end
	preActiveStealthInit()
end