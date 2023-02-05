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

--Left here for legacy purposes
--[[function upgradeCost(itemConfig)
  if itemConfig == nil then return 0 end

  local prevValue = root.evalFunction("weaponEssenceValue", itemConfig.parameters.level or itemConfig.config.level or 1)
  if prevValue < 1 then prevValue = 1 end
  local newValue = root.evalFunction("weaponEssenceValue", itemConfig.parameters.maxLevel or itemConfig.config.maxLevel or 10)

  return math.floor(newValue - prevValue)
end]]

function populateItemList(forceRepop)
  local upgradeableItems = player.itemsWithTag("vantaUpgrade")
  for i = 1, #upgradeableItems do
    upgradeableItems[i].count = 1
  end

  local transmuteCores = player.hasCountOfItem("vantatransmutecore")

  if forceRepop or not compare(upgradeableItems, self.upgradeableItems) then
    self.upgradeableItems = upgradeableItems
    widget.clearListItems(self.itemList)
    widget.setButtonEnabled("btnUpgrade", false)

    local showEmptyLabel = true

    for i, item in pairs(self.upgradeableItems) do
      local config = root.itemConfig(item)
      local level = config.parameters.level or config.config.level or 0
      if level < (config.parameters.maxLevel or config.config.maxLevel) then
        showEmptyLabel = false

        local listItem = string.format("%s.%s", self.itemList, widget.addListItem(self.itemList))
        local name = config.config.shortdescription

        widget.setText(string.format("%s.itemName", listItem), name)
        widget.setItemSlotItem(string.format("%s.itemIcon", listItem), item)

        local price = config.config.price
        widget.setData(listItem,
          {
            index = i,
            price = price
          })
        widget.setVisible(string.format("%s.unavailableoverlay", listItem), price >= transmuteCores)
      end
    end

    self.selectedItem = nil
    showItem(nil)

    widget.setVisible("emptyLabel", showEmptyLabel)
  end
end

function showItem(item)
  local transmuteCores = player.hasCountOfItem("vantatransmutecore")
  local enableButton = false
  local config = root.itemConfig(item)

  if item then
    enableButton = transmuteCores >= 1
    local currentLevel = config.config.level
    local maxLevel = config.config.maxLevel
    local nextItemName = nil
    if currentLevel < maxLevel then
      if currentLevel == 0 then
        nextItemName = config.config.upgradeMatrixParameters.level1.shortdescription
      elseif currentLevel == 1 then
        nextItemName = config.config.upgradeMatrixParameters.level2.shortdescription
      elseif currentLevel == 2 then
        nextItemName = config.config.upgradeMatrixParameters.level3.shortdescription
      elseif currentLevel == 3 then
        nextItemName = config.config.upgradeMatrixParameters.level4.shortdescription
      elseif currentLevel == 4 then
        nextItemName = config.config.upgradeMatrixParameters.level5.shortdescription
      elseif currentLevel == 5 then
        nextItemName = config.config.upgradeMatrixParameters.level6.shortdescription
      elseif currentLevel == 6 then
        nextItemName = config.config.upgradeMatrixParameters.level7.shortdescription
      elseif currentLevel == 7 then
        nextItemName = config.config.upgradeMatrixParameters.level8.shortdescription
      elseif currentLevel == 8 then
        nextItemName = config.config.upgradeMatrixParameters.level9.shortdescription
      elseif currentLevel == 9 then
        nextItemName = config.config.upgradeMatrixParameters.level10.shortdescription
      end
    end

    widget.setText("nextItem", nextItemName)
  else
    widget.setText("nextItem", "--")
  end

  widget.setButtonEnabled("btnUpgrade", enableButton)
end

function itemSelected()
  local listItem = widget.getListSelected(self.itemList)
  self.selectedItem = listItem

  if listItem then
    local itemData = widget.getData(string.format("%s.%s", self.itemList, listItem))
    local item = self.upgradeableItems[itemData.index]
    showItem(item)
  end
end

function upgrade()
  if self.selectedItem then
    local selectedData = widget.getData(string.format("%s.%s", self.itemList, self.selectedItem))
    local upgradeItem = self.upgradeableItems[selectedData.index]
    local config = root.itemConfig(upgradeItem)
    local currentLevelNum = config.parameters.level or config.config.level or 0
    local maxLevelNum = config.parameters.maxLevel or config.config.maxLevel
    if upgradeItem then
      local consumedItem = player.consumeItem(upgradeItem, false, true)
      if consumedItem then
        local consumedTransmuteCore = player.consumeItem("vantatransmutecore")
        local upgradedItem = copy(consumedItem)
        if consumedTransmuteCore then
          if currentLevelNum < maxLevelNum then
            local itemConfig = root.itemConfig(upgradedItem)
            if currentLevelNum == 0 then
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
            player.giveItem(upgradedItem)
          end
        end
      end
    end
    populateItemList(true)
  end
end
