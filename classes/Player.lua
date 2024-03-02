Player = class("Player")

function Player:init()
    self.sprite = love.graphics.newImage("assets/textures/players/playerTest.png")

    self.x, self.y = 0, 0
    self.oX, self.oY = self.sprite:getWidth()/2, self.sprite:getHeight()/1.35
end

function Player:update(dt)

end

function Player:draw()
    love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.oX, self.oY)
end