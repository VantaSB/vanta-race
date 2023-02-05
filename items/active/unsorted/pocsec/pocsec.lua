function activate()
  self.theme = config.getParameter("theme", "default")
  local configData = root.assetJson("/interface/scripted/pocsec/" .. self.theme .. "pocsec.config")
  configData.noteText = config.getParameter("noteText")
  configData.codeImg = "/interface/scripted/pocsec/codes/" .. config.getParameter("codeImg", "blank") .. ".png"
  activeItem.interact("ScriptPane", configData)

  if config.getParameter("consumeOnUse", true) then
    item.consume(1)
  end
end
