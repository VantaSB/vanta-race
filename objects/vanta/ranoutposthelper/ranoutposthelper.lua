-- My understanding of Lua is apparently out of sorts when it comes to the way SB handles things, evidently. As-is, this is going to throw a nil value exception for the player.callbacks for whatever reason.

require "/scripts/util.lua"

function init()
  object.setInteractive(true)
  message.setHandler("playerInteract", function(_, _, entityName, entityId)
    world.sendEntityMessage(entityId, 'playerInteraction', player.id())
  end)
end

function onInteraction(args)
  local chatOptions = config.getParameter("chatOptions", {}) -- luacheck: ignore 211
  local interactData = {
    config = "/interface/windowconfig/craftingmerchant.config",
    paneLayoutOverride = {
      windowtitle = {
        title = "Benzene",
        subtitle = "Sells various items, weapons, and blueprints"
      },
      imgPlayerMoneyIcon = { visible = false },
      lblPlayerMoney = { visible = false }
    },
    -- add filter conditionals for more opportunities later
    filter = { "benzenemerchant" }
  }

  --if player.hasCompletedQuest("destroyruin") then
    player.interact("OpenCraftingInterface", interactData, pane.sourceEntity()) pane.dismiss()
  --else
    --if #chatOptions > 0 then
      --object.say(chatOptions[math.random(1, #chatOptions)])
    --end
--  end
end
