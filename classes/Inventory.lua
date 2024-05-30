Inventory = class("Inventory")

function Inventory:init()
    self.slots = { --TODO: put name as key
        {   id   = 1, --TODO: auto ID ?
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

function Inventory:update(inputs)
    local idSlot = self.selectedSlot.id
    if inputs.mouse.wheelmovedUp then
        if idSlot-1 == 0 then
            idSlot = #self.slots
        else
            idSlot = idSlot-1
        end
    elseif inputs.mouse.wheelmovedDown then
        if idSlot+1 > #self.slots then
            idSlot = 1
        else
            idSlot = idSlot+1
        end
    end
    self:setSelectedSlot(idSlot)

    --if self.GUIVisible then
        if self.selectedSlot.item and self.selectedSlot.item:instanceOf(Item) then
            local item = self.selectedSlot.item
            if inputs.actions.newPress.action then
                --Check item's type... or function action() for each type ?
                item:use()
                self:removeItemSlotId(self.selectedSlot.id)
            elseif inputs.actions.newPress.throw then
                item:delete()
            end
        end
    --end
end

function Inventory:setSelectedSlot(id)
    self.selectedSlot = self.slots[id]
end

function Inventory:add(item)
    if item and item:instanceOf(Consumable) then
        if self.slots[2].item == nil then
            self.slots[2].item = item
        elseif self.slots[3].item == nil then
            self.slots[3].item = item
        else
            print("No space left")
        end
    end --else...
end

function Inventory:use(item)
end

function Inventory:removeItemSlotId(slotId)
    self.slots[slotId].item = nil
end
