ExCrit = {}

function ExCrit:setCritDamage(damage)
	local critChance = config.getParameter("critChance", 1) + status.stat("critChance")
	local critBonus = config.getParameter("critBonus", 0) + status.stat("critBonus")
	local critDamage = status.stat("critDamage")
	local heldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand())

	if heldItem and root.itemHasTag(heldItem, "magnorb") then
		critChance = critChance + 1
	end

	local crit = (math.random(100) <= critChance) -- Chance out of 100
	damage = crit and (damage * (1.5 + critDamage + (critBonus / 100.0))) or damage

	if crit then
		if heldItem then
			if not root.itemHasTag(heldItem, "mininggun") or root.itemHasTag(heldItem, "bugnet") then
				local stunRoll = (math.random(100)) + status.stat("stunChance") + config.getParameter("stunChance",0)
				local params = {power = 1, damageKind = "default"}
				if stunRoll > 99 and root.itemHasTag(heldItem, "dagger") then
					params.speed = 14
					world.spawnProjectile("excritdagger", mcontroller.position(), activeItem.ownerEntityId(), ExCrit.aimVectorSpecial(self), true, params)
					--world.spawnItem("skillpoint", world.entityPosition(player.id()), math.random(masteryRange[1], masteryRange[2]))
				end
				if stunRoll > 99 and root.itemHasTag(heldItem, "spear") then
					params.speed = 55
					world.spawnProjectile("excritspear", mcontroller.position(), activeItem.ownerEntityId(), ExCrit.aimVectorSpecial(self), false, params)
					--world.spawnItem("skillpoint", world.entityPosition(player.id()), math.random(masteryRange[1], masteryRange[2]))
				end
				if stunRoll > 99 and root.itemHasTag(heldItem, "shortsword") or root.itemHasTag(heldItem, "vsaber") then
					params.speed = 30
					world.spawnProjectile("excritshortsword", mcontroller.position(), activeItem.ownerEntityId(), ExCrit.aimVectorSpecial(self), false, params)
					--world.spawnItem("skillpoint", world.entityPosition(player.id()), math.random(masteryRange[1], masteryRange[2]))
				end
				if stunRoll > 99 and (root.itemHasTag(heldItem, "fist") or root.itemHasTag(heldItem, "hammer") or root.itemHasTag(heldItem, "axe") or root.itemHasTag(heldItem, "greatsword")) then
					params.speed = 35
					world.spawnProjectile("excritstun", mcontroller.position(), activeItem.ownerEntityId(), ExCrit.aimVectorSpecial(self), false, params)
				end
			end
		end
	end

	return damage
end

function ExCrit:aimVectorSpecial()
	local aimVector = vec2.rotate({1, 0}, self.aimAngle)
	aimVector[1] = aimVector[1] * self.aimDirection
	return aimVector
end
