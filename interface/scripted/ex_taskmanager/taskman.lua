canvas = nil

function init()
	if player.species() ~= "vanta" then
		widget.setVisible("hfCodex", false)
		widget.setVisible("quests", false)
		widget.setVisible("research", false)
		widget.setVisible("tech", false)
		widget.setVisible("mech", false)
		widget.setVisible("radio", false)

		widget.setVisible("lblDisabledText", true)
		widget.setText("lblDisabledText", "UNAUTHORIZED USER")
		widget.setFontColor("lblDisabledText", "#ff5e66f0")
	else
		widget.setVisible("lblDisabledText", false)
		widget.setButtonEnabled("hfCodex", true)
		widget.setFontColor("hfCodex", "#ffffffff")

		widget.setVisible("quests", true)
		widget.setButtonEnabled("quests", false)
		widget.setFontColor("quests", "#ff5e66f0")

		widget.setVisible("research", true)
		widget.setButtonEnabled("research", false)
		widget.setFontColor("research", "#ff5e66f0")

		widget.setVisible("tech", true)
		widget.setButtonEnabled("tech", false)
		widget.setFontColor("tech", "#ff5e66f0")

		widget.setVisible("mech", true)
		widget.setButtonEnabled("mech", false)
		widget.setFontColor("mech", "#ff5e66f0")

		widget.setVisible("radio", true)
		widget.setButtonEnabled("radio", true)
		widget.setFontColor("mech", "#ffffff")


		if player.hasCompletedQuest("vantatutorial3") then
			widget.setButtonEnabled("quests", true)
			widget.setFontColor("quests", "#ffffff")

			widget.setButtonEnabled("research", true)
			widget.setFontColor("research", "#ffffff")
		end

		if player.hasCompletedQuest("techscientist2") then
			widget.setButtonEnabled("tech", true)
			widget.setFontColor("tech", "#ffffff")
		end

		if player.hasCompletedQuest("mechunlock_vanta") then
			widget.setButtonEnabled("mech", true)
			widget.setFontColor("mech", "#ffffff")
		end
	end

	--Debug
	--[[widget.setButtonEnabled("hfCodex", true)
	widget.setFontColor("hfCodex", "#ffffff")

	widget.setButtonEnabled("quests", true)
	widget.setFontColor("quests", "#ffffff")

	widget.setButtonEnabled("research", true)
	widget.setFontColor("research", "#ffffff")

	widget.setButtonEnabled("tech", true)
	widget.setFontColor("tech", "#ffffff")

	widget.setButtonEnabled("mech", true)
	widget.setFontColor("mech", "#ffffff")

	widget.setVisible("hfCodex", true)
	widget.setVisible("quests", true)
	widget.setVisible("research", true)
	widget.setVisible("tech", true)
	widget.setVisible("mech", true)
	widget.setVisible("lblDisabledText", false)]]
end

function hfCodex()
	player.interact("ScriptPane", "/interface/scripted/hfcodex/xcodexui.config")
	pane.dismiss()
end

function quests()
	player.interact("ScriptPane", "/interface/scripted/ex_questwindow/questList.config")
	pane.dismiss()
end

function research()
	player.interact("ScriptPane", "/interface/scripted/ex_research/researchTree.config")
	pane.dismiss()
end

function tech()
	player.interact("ScriptPane", "/interface/scripted/techupgrade/techupgradegui.config")
	pane.dismiss()
end

function mech()
	player.interact("ScriptPane", "/interface/scripted/mechassembly/mechassemblygui.config")
	pane.dismiss()
end

function radio()
	player.interact("ScriptPane", "/interface/scripted/fm_musicplayer/fm_musicplayer.config")
	pane.dismiss()
end
