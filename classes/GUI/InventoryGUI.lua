InventoryGUI = class("InventoryGUI")

function InventoryGUI:init(inventory)
    self.inventory = inventory
end


function InventoryGUI:draw()
    local dimSlot = 50
    local margin = 25
    local centerScreen = widthWindow/2
    local height = heightWindow-dimSlot-15

    love.graphics.setLineWidth(2)
    love.graphics.setColor(0.8, 0.8, 0.8)

    selectedSlot = self.inventory.selectedSlot.name
    --hands
    if selectedSlot == "hands" then
        love.graphics.rectangle("line", centerScreen-dimSlot*2-margin, height, dimSlot, dimSlot)
    end
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", centerScreen-dimSlot*2-margin+1, height+1, dimSlot-2, dimSlot-2)
    love.graphics.setColor(0.8, 0.8, 0.8)

    --pocket1
    if selectedSlot == "pocket1" then
        love.graphics.rectangle("line", centerScreen-dimSlot, height, dimSlot, dimSlot)
    end
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", centerScreen-dimSlot+1, height+1, dimSlot-2, dimSlot-2)
    love.graphics.setColor(0.8, 0.8, 0.8)

    --pocket2
    if selectedSlot == "pocket2" then
        love.graphics.rectangle("line", centerScreen+margin, height, dimSlot, dimSlot)
    end
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", centerScreen+margin+1, height+1, dimSlot-2, dimSlot-2)
    love.graphics.setColor(0.8, 0.8, 0.8)

    --backpack
    if selectedSlot == "backpack" then
        love.graphics.rectangle("line", centerScreen+dimSlot+margin*2, height, dimSlot, dimSlot)
    end
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", centerScreen+dimSlot+margin*2+1, height+1, dimSlot-2, dimSlot-2)
    love.graphics.setColor(0.8, 0.8, 0.8)

    love.graphics.setLineWidth(1)
end