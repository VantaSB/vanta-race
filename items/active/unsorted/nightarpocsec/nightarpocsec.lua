function activate()
  local configData = root.assetJson("/interface/scripted/nightarpocsec/nightarpocsec.config")
  configData.noteText = config.getParameter("noteText")
  configData.codeSheet = config.getParameter("codeSheet")
  configData.codeImg = config.getParameter("codeImg")
  activeItem.interact("ScriptPane", configData)

  if config.getParameter("consumeOnUse", true) then
    item.consume(1)
  end
end
