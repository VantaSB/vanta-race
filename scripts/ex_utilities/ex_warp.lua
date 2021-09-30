-- Old method, kept as historical reference/fallback method in case EX Player Init fails

function init()
  self.dCoord = config.getParameter("dCoord")
  self.dLabel = config.getParameter("dLabel")
  if self.dCoord == nil or self.dLabel == nil then
    widget.setText("message", "Door configured incorrectly, click any button to exit dialog.")
  else
    widget.setText("message", "Move to " .. self.dLabel .. "?")
  end
end

function enterDoor()
  if self.dCoord ~= nil and self.dLabel ~= nil then
    player.warp(self.dCoord)
  end
  pane.dismiss()
end

function walkAway()
  pane.dismiss()
end
