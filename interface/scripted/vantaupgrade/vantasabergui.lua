require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  self.itemList = "itemScrollArea.itemList"

	self.nextUpgrade = config.getParameter("nextUpgrade")

  self.upgradeItem = {}
  self.selectedItem = nil
  populateItemList()
end

function update(dt)
  populateItemList()
end

function populateItemList(forceRepop)
	local upgradeableWeapon = player.itemsWithTag("vSaberUpgrade")
	for i = 1, #upgradeableWeapon do
		upgradeableWeapon[i].count = 1
	end

	if forceRepop or not compare(upgradeableWeapon, self.upgradeItem) then
		self.upgradeItem = upgradeableWeapon
		widget.clearListItems(self.itemList)
		widget.setButtonEnabled("btnUpgrade", false)

		local showEmptyLabel = true

		for i, item in pairs(self.upgradeItem) do
			local config = root.itemConfig(item)

			if (config.parameters.upgradeNum or config.config.upgradeNum) == self.nextUpgrade - 1 then
				showEmptyLabel = false

				local listItem = string.format("%s.%s", self.itemList, widget.addListItem(self.itemList))
				local name = config.parameters.shortdescription or config.config.shortdescription
				local upgradeNum = config.config.upgradeNum

				widget.setText(string.format("%s.itemName", listItem), name)
				widget.setItemSlotItem(string.format("%s.itemIcon", listItem), item)

				widget.setData(listItem,
					{
						index = i,
						upgradeNum = upgradeNum
					})
				--widget.setVisible(string.format("%s.unavailableoverlay", listItem), self.nextUpgrade > upgradeNum)
				widget.setVisible(string.format("%s.unavailableoverlay", listItem), false)
			end
		end

		self.selectedItem = nil
		showWeapon(nil)

		widget.setVisible("emptyLabel", showEmptyLabel)
	end
end

function showWeapon(item)
	local config = root.itemConfig(item)
	-- local upgradeLevel = self.nextUpgrade

	if item then
		local enableButton = self.nextUpgrade > (config.parameters.upgradeNum or config.config.upgradeNum)
		widget.setText("nextItem", string.format("%s", config.config.upgrades[self.nextUpgrade].shortdescription))
		widget.setButtonEnabled("btnUpgrade", enableButton)
	end
end

function itemSelected()
	local listItem = widget.getListSelected(self.itemList)
	self.selectedItem = listItem

	if listItem then
		local itemData = widget.getData(string.format("%s.%s", self.itemList, listItem))
		local weaponItem = self.upgradeItem[itemData.index]
		showWeapon(weaponItem, itemData.upgradeNum)
	end
end

function upgrade()
  if self.selectedItem then
    local selectedData = widget.getData(string.format("%s.%s", self.itemList, self.selectedItem))
    local upgradeItem = self.upgradeItem[selectedData.index]
    local config = root.itemConfig(upgradeItem)
    local currentUpgradeNum = config.parameters.upgradeNum or config.config.upgradeNum

    if upgradeItem then
      local consumedItem = player.consumeItem(upgradeItem, false, true)
      if consumedItem then
        local upgradedItem = copy(consumedItem)
        if currentUpgradeNum < self.nextUpgrade then
          local itemConfig = root.itemConfig(upgradedItem)
          if itemConfig.config.upgrades[self.nextUpgrade] then
            upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgrades[self.nextUpgrade])
          end
        end
        player.giveItem(upgradedItem)
				sb.logInfo("Upgraded item parameters: %s", upgradedItem)
      end
    end
    populateItemList(true)
  end
end
