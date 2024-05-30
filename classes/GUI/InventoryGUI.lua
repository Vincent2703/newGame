InventoryGUI = class("InventoryGUI")

function InventoryGUI:init(inventory)
    self.inventory = inventory
end


function InventoryGUI:draw()
    local dimSlot = 50
    local margin = 25
    local centerScreen = widthWindow/2
    local height = heightWindow-dimSlot-15
    local bgColor = {0.8, 0.8, 0.8}
    local textColor = {1, 1, 1, 0.65}
    local lineWidth = 2

    love.graphics.setLineWidth(lineWidth)

    local slots = self.inventory.slots
    local selectedSlotID = self.inventory.selectedSlot.id

    for i, slot in ipairs(slots) do
        love.graphics.setColor(bgColor)

        local itemSlot = slot.item
        local hasItem = itemSlot and itemSlot:instanceOf(Item)
        local isSelectedSlot = selectedSlotID == slot.id

        local x = centerScreen - dimSlot*(3-i) - margin*(2-i)

        if isSelectedSlot then
            love.graphics.rectangle("line", x, height, dimSlot, dimSlot)
            if hasItem then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setColor(textColor)
                local itemName = slot.item.name
                local limit = dimSlot*2+margin*2
                local lineHeight = Utils:getTextHeight(itemName, limit, 0.5)
                love.graphics.printf(itemName, x-lume.round(margin/2), height-lineHeight, limit, "center", 0, 0.5)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", x+1, height+1, dimSlot-2, dimSlot-2)
        if hasItem then
            itemSlot:draw(x+1, height+1, 3)
        end

        if isSelectedSlot then
            love.graphics.setColor(1, 1, 1, 0.4)
            love.graphics.printf(slot.name, x-lume.round(margin/2), height+dimSlot+lineWidth+1, dimSlot*2+margin*2, "center", 0, 0.5)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setLineWidth(1)
end