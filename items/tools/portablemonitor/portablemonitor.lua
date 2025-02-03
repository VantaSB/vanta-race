function activate(fireMode, shiftHeld)
--Tech Config GUI
  if fireMode == "primary" and not shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/techupgrade/techupgradegui.config")
  end

--Mech Assembly
  if fireMode == "primary" and shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/mechassembly/mechassemblygui.config")
  end

--Custom Codex
  if fireMode == "alt" and not shiftHeld then
    activeItem.interact("ScriptPane", "/interface/scripted/hfcodex/xcodexui.config")
  end

--Vanta Research Tree
  if fireMode == "alt" and shiftHeld then
    activeItem.interact("scriptPane", "/interface/scripted/ex_research/researchTree.config")
  end
end

function update()
  activeItem.setArmAngle(-0.5)
end
