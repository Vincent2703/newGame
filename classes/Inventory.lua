Inventory = class("Inventory")

function Inventory:init()
    self.slots = {
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

    self.GUIVisible = false
end

function Inventory:setSelectedSlot(id)
    self.selectedSlot = self.slots[id]
end

function Inventory:pick(item)
end

function Inventory:use(item)
end

function Inventory:throw(item)
end
