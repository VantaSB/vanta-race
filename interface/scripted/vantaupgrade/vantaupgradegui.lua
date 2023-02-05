require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  self.itemList = "itemScrollArea.itemList"

  self.upgradeableItems = {}
  self.selectedItem = nil
  populateItemList()
end

function update(dt)
  populateItemList()
end

function upgradeCost(itemConfig)
  if itemConfig == nil then return 0 end

  local prevValue = root.evalFunction("weaponEssenceValue", itemConfig.parameters.level or itemConfig.config.level or 1)
  local newValue = root.evalFunction("weaponEssenceValue", itemConfig.parameters.maxLevel or itemConfig.config.maxLevel or 10)

  return math.floor(newValue - prevValue)
end

function populateItemList(forceRepop)
  local upgradeableItems = player.itemsWithTag("vantaUpgrade")
  for i = 1, #upgradeableItems do
    upgradeableItems[i].count = 1
  end

  local playerEssence = player.currency("essence")

  if forceRepop or not compare(upgradeableItems, self.upgradeableItems) then
    self.upgradeableItems = upgradeableItems
    widget.clearListItems(self.itemList)
    widget.setButtonEnabled("btnUpgrade", false)

    local showEmptyLabel = true

    for i, item in pairs(self.upgradeableItems) do
      local config = root.itemConfig(item)

      if (config.parameters.level or config.config.level or 1) < (config.parameters.maxLevel or config.config.maxLevel) then
        showEmptyLabel = false

        local listItem = string.format("%s.%s", self.itemList, widget.addListItem(self.itemList))
        local name = config.config.shortdescription

        widget.setText(string.format("%s.itemName", listItem), name)
        widget.setItemSlotItem(string.format("%s.itemIcon", listItem), item)

        local price = upgradeCost(config)
        widget.setData(listItem,
          {
            index = i,
            price = price
          })
        widget.setVisible(string.format("%s.unavailableoverlay", listItem), price > playerEssence)
      end
    end

    self.selectedItem = nil
    showItem(nil)

    widget.setVisible("emptyLabel", showEmptyLabel)
  end
end

function showItem(item, price)
  local playerEssence = player.currency("essence")
  local enableButton = false

  if item then
    enableButton = playerEssence >= price
    local directive = enableButton and "^green;" or "^red;"
    widget.setText("essenceCost", string.format("%s%s / %s", directive, playerEssence, price))
  else
    widget.setText("essenceCost", string.format("%s / --", playerEssence))
  end

  widget.setButtonEnabled("btnUpgrade", enableButton)
end

function itemSelected()
  local listItem = widget.getListSelected(self.itemList)
  self.selectedItem = listItem

  if listItem then
    local itemData = widget.getData(string.format("%s.%s", self.itemList, listItem))
    local item = self.upgradeableItems[itemData.index]
    showItem(item, itemData.price)
  end
end

function upgrade()
  if self.selectedItem then
    local selectedData = widget.getData(string.format("%s.%s", self.itemList, self.selectedItem))
    local upgradeItem = self.upgradeableItems[selectedData.index]
    local config = root.itemConfig(upgradeItem)
    local currentLevelNum = config.parameters.level or config.config.level
    local maxLevelNum = config.parameters.maxLevel or config.config.maxLevel
    --sb.logInfo("Current Level: %s   |   Max Level: %s", currentLevelNum, maxLevelNum)

    if upgradeItem then
      local consumedItem = player.consumeItem(upgradeItem, false, true)
      if consumedItem then
        local consumedCurrency = player.consumeCurrency("essence", selectedData.price)
        local upgradedItem = copy(consumedItem)
        if consumedCurrency then
          if currentLevelNum < maxLevelNum then
            local itemConfig = root.itemConfig(upgradedItem)
            if currentLevelNum == 0 or nil then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.level1)
            elseif currentLevelNum == 1 then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.level2)
            elseif currentLevelNum == 2 then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.level3)
            elseif currentLevelNum == 3 then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.level4)
            elseif currentLevelNum == 4 then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.level5)
            elseif currentLevelNum == 5 then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.level6)
            elseif currentLevelNum == 6 then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.level7)
            elseif currentLevelNum == 7 then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.level8)
            elseif currentLevelNum == 8 then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.leve9)
            elseif currentLevelNum == 9 then
              upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeMatrixParameters.level10)
            end
          end
        end
        player.giveItem(upgradedItem)
      end
    end
    populateItemList(true)
  end
end
