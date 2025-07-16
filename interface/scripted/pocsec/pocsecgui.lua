function init()
  local noteText = config.getParameter("noteText", "")
  noteText = noteText:gsub("%^[#%a%x]+;", "")
  local codeImg = config.getParameter("codeImg")
  widget.setText("scrollArea.lblNoteText", noteText)
  widget.setImage("scrollArea.imgCodeImg", codeImg)
  --sb.logInfo("Loaded code image: ", codeImg)
end
