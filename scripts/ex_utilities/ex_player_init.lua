local origInit = init
local origUninit = uninit
--local checkingMod = "ztarbound"

-- Prevent the script from being called twice if it was patched into the player more than once for some reason
exInited = false
exUninited = false

function init()
	origInit()
	if exInited then return end
	exInited = true

	--sb.logInfo("----- ex_utilities player init -----")
	--[[status.setStatusProperty("ex_updatewindow_error", nil)

	-- popping up the update window in a safe enviorment so everything else runs as it should in case of errors with the versioning file
	local passed, err = pcall(updateInfoWindow)
	if not passed then
		sb.logError("Pop-up window:\n%s", err)
		status.setStatusProperty("ex_updatewindow_error", checkingMod)
		player.interact("ScriptPane", "/interface/scripted/updateswindow/updateswindow_error.config", player.id())
	end]]

	-- Add the scan interaction handler if its missing
	if not player.hasQuest("ex_scaninteraction") then
		sb.logInfo("Readded 'ex_scaninteraction' quest")
		player.startQuest("ex_scaninteraction")
	end

	 require "/ex/ex_util.lua"
	 exutil.DeepPrintTable(player)

	--sb.logInfo("")
end

--[[function updateInfoWindow()
	--[[status.setStatusProperty("ex_updatewindow_pending", nil)
	local data = root.assetJson("/ex/updateInfoWindow/data.config")
	local versions = status.statusProperty("ex_updatewindow_versions", {})
	local world = world.type()
	local pending = {}

	for _, instance in ipairs(data.Data.ignoredInstances) do
		if world == instance then return end
	end

	--[[sb.logInfo("Mods using update info window and their versions:")
	for mod, modData in pairs(data) do
		checkingMod = mod
		if mod ~= "Data" then
			local text = root.assetJson(modData.file)
			sb.logInfo("-- %s   [%s]", mod, text.version)
			if text.version ~= versions[mod] then
				table.insert(pending, mod)
			end
		end
	end

	-- Version values are updated in the pane

	if #pending > 0 then
		status.setStatusProperty("ex_updatewindow_pending", pending)
		status.setStatusProperty("ex_updatewindow_versions", versions)
		player.interact("ScriptPane", "/ex/updateInfoWindow/updateInfoWindow.config")
	else
		status.setStatusProperty("ex_updatewindow_pending", nil)
	end
end]]

function uninit()
	origUninit()
	if exUninited then return end
	exUninited = true

	world.sendEntityMessage(player.id(), "stopAltMusic", 2.0)
end
