function init()
  local noteText = config.getParameter("noteText", "")
  noteText = noteText:gsub("%^[#%a%x]+;", "")
  local codeImg = config.getParameter("codeImg")
  widget.setText("lblNoteText.text", noteText)
  widget.setImage("imgCodeImg", codeImg)
  sb.logInfo("Loaded code image: ", codeImg)
end
