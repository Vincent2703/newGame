Consumable = Item:extend("Consumable")

function Consumable:init(name, spritesheet, effectCallback)
    Consumable.super.init(self, name, spritesheet)

    self.effectCallback = effectCallback
end

function Consumable:use(player) --Use on player
    self.effectCallback(player)
    self:delete()
end