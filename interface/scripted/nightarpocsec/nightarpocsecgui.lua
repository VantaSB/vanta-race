function init()
  local noteText = config.getParameter("noteText", "")
  self.codeSheet = "/interface/scripted/nightarpocsec/codes.png"
  self.codeImg = config.getParameter("codeImg")
  noteText = noteText:gsub("%^[#%a%x]+;", "")
  widget.setText("lblNoteText", noteText)
  widget.setImage("imgCodeImg", self.codeSheet .. ":" .. self.codeImg)

  sb.logInfo(self.codeSheet .. ":" .. self.codeImg)
end
