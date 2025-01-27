function init()

end

function update(dt)
  if iHaveStealthPatched then return nil end
	iHaveStealthPatched = true
	if type(world) == "table" then
		originalWorldQueries = {
			entityQuery = world.entityQuery,
			entityLineQuery = world.entityLineQuery,
			monsterQuery = world.monsterQuery,
			npcQuery = world.npcQuery,
			npcLineQuery = world.npcLineQuery,
			playerQuery = world.playerQuery,
			entityExists = world.entityExists,
			entityType = world.entityType
		}
		--sb.logInfo("world table altered")
		function world.entityQuery(a1,a2,a3, ignoreStealth) -- luacheck: ignore 122
			local originalReturns = originalWorldQueries["entityQuery"](a1, a2, a3)
			local newReturns = {}
			for _,id in ipairs(originalReturns) do
				--sb.logInfo("entity["..tostring(id).."]Stealthed: %s", tostring(world.getProperty("entity["..tostring(id).."]Stealthed")))
				if ignoreStealth or not world.getProperty("entity["..tostring(id).."]Stealthed") then
					table.insert(newReturns, id)
				else
					--sb.logInfo("Stealthed target ignored: %s", id)
				end
			end
			return newReturns
		end
		function world.entityLineQuery(a1,a2,a3, ignoreStealth) -- luacheck: ignore 122
			local originalReturns = originalWorldQueries["entityLineQuery"](a1, a2, a3)
			local newReturns = {}
			for _,id in ipairs(originalReturns) do
				if ignoreStealth or not world.getProperty("entity["..tostring(id).."]Stealthed") then
					table.insert(newReturns, id)
				end
			end
			return newReturns
		end
		function world.npcQuery(a1,a2,a3, ignoreStealth) -- luacheck: ignore 122
			local originalReturns = originalWorldQueries["npcQuery"](a1, a2, a3)
			local newReturns = {}
			for _,id in ipairs(originalReturns) do
				if ignoreStealth or not world.getProperty("entity["..tostring(id).."]Stealthed") then
					table.insert(newReturns, id)
				end
			end
			return newReturns
		end
		function world.npcLineQuery(a1,a2,a3, ignoreStealth) -- luacheck: ignore 122
			local originalReturns = originalWorldQueries["npcLineQuery"](a1, a2, a3)
			local newReturns = {}
			for _,id in ipairs(originalReturns) do
				if ignoreStealth or not world.getProperty("entity["..tostring(id).."]Stealthed") then
					table.insert(newReturns, id)
				end
			end
			return newReturns
		end
		function world.playerQuery(a1,a2,a3, ignoreStealth) -- luacheck: ignore 122
			local originalReturns = originalWorldQueries["playerQuery"](a1, a2, a3)
			local newReturns = {}
			for _,id in ipairs(originalReturns) do
				if ignoreStealth or not world.getProperty("entity["..tostring(id).."]Stealthed") then
					table.insert(newReturns, id)
				else
					--sb.logInfo("Stealthed target ignored: %s", id)
				end
			end
			return newReturns
		end
		function world.monsterQuery(a1,a2,a3, ignoreStealth) -- luacheck: ignore 122
			local originalReturns = originalWorldQueries["monsterQuery"](a1, a2, a3)
			local newReturns = {}
			for _,id in ipairs(originalReturns) do
				if ignoreStealth or not world.getProperty("entity["..tostring(id).."]Stealthed") then
					table.insert(newReturns, id)
				end
			end
			return newReturns
		end

		function world.entityExists(a1, ignoreStealth) -- luacheck: ignore 122
			local originalReturn = originalWorldQueries["entityExists"](a1)
			local newReturn = originalReturn and (ignoreStealth or not world.getProperty("entity["..tostring(a1).."]Stealthed"))
			return newReturn
		end

		function world.entityType(a1, ignoreStealth) -- luacheck: ignore 122
			local originalReturn = originalWorldQueries["entityType"](a1)
			local newReturn = originalReturn
			if world.getProperty("entity["..tostring(ai).."]Stealthed") and not ignoreStealth then
				newReturn = "none"
			end
			return newReturn
		end

		function world.stealthQuery(a1,a2,a3) -- luacheck: ignore 122
			local originalReturns = originalWorldQueries["entityQuery"](a1, a2, a3)
			local newReturns = {}
			for _,id in ipairs(originalReturns) do
				if world.getProperty("entity["..tostring(id).."]Stealthed") then
					table.insert(newReturns, id)
				end
			end
			return newReturns
		end
	end
	if type(entity) == "table" then
		originalEntityQueries = {
		closestValidTarget = entity.closestValidTarget,
		isValidTarget = entity.isValidTarget,
		entityInSight = entity.entityInSight
		}
		--sb.logInfo("entity table altered")
		function entity.closestValidTarget(a1, ignoreStealth) -- luacheck: ignore 122
			local originalReturn = originalEntityQueries["closestValidTarget"](a1)
			local newReturn = originalReturn
			if world.getProperty("entity["..tostring(originalReturn).."]Stealthed") and not ignoreStealth then
				newReturn = 0
			end
			return newReturn
		end
		function entity.isValidTarget(a1, ignoreStealth) -- luacheck: ignore 122
			local originalReturn = originalEntityQueries["isValidTarget"](a1)
			local newReturn = originalReturn and (ignoreStealth or not world.getProperty("entity["..tostring(a1).."]Stealthed"))
			return newReturn
		end
		function entity.entityInSight(a1, ignoreStealth) -- luacheck: ignore 122
			local originalReturn = originalEntityQueries["entityInSight"](a1)
			local newReturn = originalReturn and (ignoreStealth or not world.getProperty("entity["..tostring(a1).."]Stealthed"))
			return newReturn
		end
	end
end

function uninit()

end
