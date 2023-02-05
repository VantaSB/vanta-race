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

  local prevValue = root.evalFunction("weaponTransmuteValue", itemConfig.parameters.level or itemConfig.config.level or 1)
  local newValue = root.evalFunction("weaponTransmuteValue", itemConfig.parameters.maxLevel or itemConfig.config.maxLevel or 10)

  return math.floor(newValue - prevValue)
end

function populateItemList(forceRepop)
  local upgradeableItems = player.itemsWithTag("vantaUpgrade")
  for i = 1, #upgradeableItems do
    upgradeableItems[i].count = 1
  end

  --local playerEssence = player.currency("essence")
  local transmuteCost = player.hasItem("vantatransmutecore")

  if forceRepop or not compare(upgradeableItems, self.upgradeableItems) then
    self.upgradeableItems = upgradeableItems
    widget.clearListItems(self.itemList)
    widget.setButtonEnabled("btnUpgrade", false)

    local showEmptyLabel = true

    for i, item in pairs(self.upgradeableItems) do
      local config = root.itemConfig(item)
      if config then
        showEmptyLabel = false

        local listItem = string.format("%s.%s", self.itemList, widget.addListItem(self.itemList))
        local name = config.config.upgradeMatrixParameters.shortdescription

        widget.setText(string.format("%s.itemName", listItem), name)
        widget.setItemSlotItem(string.format("%s.itemIcon", listItem), item)

        --local price = upgradeCost(config)
        local price = config.config.price
        widget.setData(listItem,
          {
            index = i,
            price = price
          })
        widget.setVisible(string.format("%s.unavailableoverlay", listItem), price >= player.hasCountOfItem("vantatransmutecore", price))
      end
    end

    self.selectedItem = nil
    showItem(nil)

    widget.setVisible("emptyLabel", showEmptyLabel)
  end
end

function showItem(item, price)
  local transmuteCost = player.hasCountOfItem("vantatransmutecore", price)
  local enableButton = false

  if item then
    enableButton = transmuteCost >= price
    local directive = enableButton and "^green;" or "^red;"
    widget.setText("transmuteCost", string.format("%s%s / %s", directive, transmuteCost, price))
  else
    widget.setText("transmuteCost", string.format("%s / --", transmuteCost))
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
  local equipHead = false
  local equipHeadCosmetic = false
  local equipChest = false
  local equipChestCosmetic = false
  local equipLegs = false
  local equipLegsCosmetic = false
  local equipBack = false
  local equipBackCosmetic = false

  if self.selectedItem then
    if player.equippedItem("head") == self.selectedItem then
      equipHead = true
    elseif player.equippedItem("headCosmetic") == self.selectedItem then
      equipHeadCosmetic = true
    elseif player.equippedItem("chest") == self.selectedItem then
      equipChest = true
    elseif player.equippedItem("chestCosmetic") == self.selectedItem then
      equipChestCosmetic = true
    elseif player.equippedItem("legs") == self.selectedItem then
      equipLegs = true
    elseif player.equippedItem("legsCosmetic") == self.selectedItem then
      equipLegsCosmetic = true
    elseif player.equippedItem("back") == self.selectedItem then
      equipBack = true
    elseif player.equippedItem("backCosmetic") == self.selectedItem then
      equipBackCosmetic = true
    end

    local selectedData = widget.getData(string.format("%s.%s", self.itemList, self.selectedItem))
    local upgradeItem = self.upgradeableItems[selectedData.index]
    local config = root.itemConfig(upgradeItem)
    if upgradeItem then
      local consumedItem = player.consumeItem(upgradeItem, false, true)
      if consumedItem then
        local upgradeCostItem = player.consumeItem("vantatransmutecore", true, true)
        local upgradedItem = config.config.upgradeMatrixParameters.nextItem
        if upgradeCostItem then
          player.giveItem(upgradedItem)
          if equipHead then
            player.setEquippedItem("head", upgradedItem)
          elseif equipHeadCosmetic then
            player.setEquippedItem("headCosmetic", upgradedItem)
          elseif equipChest then
            player.setEquippedItem("chest", upgradedItem)
          elseif equipChestCosmetic then
            player.setEquippedItem("chestCosmetic", upgradedItem)
          elseif equipLegs then
            player.setEquippedItem("legs", upgradedItem)
          elseif equipLegsCosmetic then
            player.setEquippedItem("legsCosmetic", upgradedItem)
          elseif equipBack then
            player.setEquippedItem("back", upgradedItem)
          elseif equipBackCosmetic then
            player.setEquippedItem("backCosmetic", upgradedItem)
          end
        end
      end
    end
    populateItemList(true)
  end
end
