Item = class("Item")

function Item:init(name, spritesheet)
    self.name = name

    self.image = love.graphics.newImage(spritesheet.filePath)
    
    self.sprites = {}
    for _, sprite in ipairs(spritesheet.sprites) do
        local quad = love.graphics.newQuad(sprite.x, sprite.y, sprite.w, sprite.h, self.image)
        table.insert(self.sprites, {quad=quad, color=sprite.color})
    end
end

function Item:draw(x, y, size)
    local size = size or 3 
    for _, sprite in ipairs(self.sprites) do
        love.graphics.setColor(sprite.color)
        love.graphics.draw(self.image, sprite.quad, x, y, 0, size, 0)
    end
end


function Item:delete()
    self = nil
end