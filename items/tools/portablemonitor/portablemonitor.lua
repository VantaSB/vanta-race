function activate(fireMode, shiftHeld)
--ZB Quest Pane
  if fireMode == "primary" and not shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/corvexquestwindow/questList.config")
  end

--Mech Assembly
  if fireMode == "primary" and shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/mechassembly/mechassemblygui.config")
  end

--Techs Window
  if fireMode == "alt" and not shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/techupgrade/techupgradegui.config")
  end

--Integrated codex
  if fireMode == "alt" and shiftHeld then
    activeItem.interact("scriptPane", "/interface/scripted/hfcodex/xcodexui.config")
  end
end

function update()
  activeItem.setArmAngle(-0.5)
end
