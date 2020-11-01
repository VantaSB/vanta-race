function activate(fireMode, shiftHeld)
--ZB Quest Pane
  if fireMode == "primary" and not shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/corvexquestwindow/questList.config")
  end

--Research Tree
  if fireMode == "primary" and shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/research/researchTree.config")
  end

--Mech Assembly
  if fireMode == "alt" and not shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/mechassembly/mechassemblygui.config")
  end

--Techs Window
  if fireMode == "alt" and shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/techupgrade/techupgradegui.config")
  end
end

function update()
  activeItem.setArmAngle(-0.5)
end
