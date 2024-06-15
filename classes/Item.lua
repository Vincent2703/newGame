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

function Item:draw(x, y, size) --remove size ?
    local size = size or 1
    for _, sprite in ipairs(self.sprites) do
        love.graphics.setColor(sprite.color)
        love.graphics.draw(self.image, sprite.quad, x, y, 0, size)
    end
    love.graphics.setColor(1, 1, 1, 1)
end


function Item:delete()
    self = nil
end

function Item:getItemInTableByName(table, name)
    for _, item in ipairs(table) do
        if item.name == name then
            return item
        end
    end
end