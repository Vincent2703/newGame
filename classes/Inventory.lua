Inventory = class("Inventory")

function Inventory:init()
    self.slots = { --TODO: put name as key
        {   id   = 1,
            name = "hands",
            item = nil
        },

        {   id   = 2,
            name = "pocket1",
            item = nil
        },   

        {   id   = 3,
            name = "pocket2",
            item = nil
        },

        {   id   = 4,
            name = "backpack",
            item = nil
        }, 
        
        --ammo/food/etc ?
    }
    self.selectedSlot = self.slots[1]
end

function Inventory:setSelectedSlot(id)
    self.selectedSlot = self.slots[id]
end

function Inventory:add(item, slotID)
    if item and item:instanceOf(Consumable) then
        if slot and self.slots[slotID] == nil then
            self.slots[slotID] = item
        else
            if self.slots[2].item == nil then
                self.slots[2].item = item
            elseif self.slots[3].item == nil then
                self.slots[3].item = item
            else
                return false
            end
        end
        return true
    end 
end

function Inventory:removeItemSlotId(slotID)
    self.slots[slotID].item = nil
end


function Inventory:update()
    local inputMouse = input.state.mouse
    local idSlot = self.selectedSlot.id
    local wheelUp, wheelDown = inputMouse.wheelmovedUp, inputMouse.wheelmovedDown

    if wheelDown then
        if idSlot-1 == 0 then
            idSlot = #self.slots
        else
            idSlot = idSlot-1
        end
    elseif wheelUp then
        if idSlot+1 > #self.slots then
            idSlot = 1
        else
            idSlot = idSlot+1
        end
    end

    if wheelUp or wheelDown then
        self:setSelectedSlot(idSlot)
    end
end