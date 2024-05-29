Consumable = Item:extend("Consumable")

function Consumable:init(name, spritesheet, effectCallback)
    Consumable.super.init(self, name, spritesheet)

    self.effectCallback = effectCallback
end

function Consumable:use()
    self.effectCallback()
    self:delete()
end