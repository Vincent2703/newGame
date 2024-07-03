BodyStatusGUI = class("BodyStatusGUI")

function BodyStatusGUI:init(bodyStatus)
    self.x, self.y = 30, 30
    self.bodyStatus = bodyStatus
    self.spritesheet = love.graphics.newImage("assets/textures/GUI/bodyStatus.png")
    local width, height = 14, 14
    self.sprites = {
        body = love.graphics.newQuad(0, 0, width, height, self.spritesheet),
        leftArm = love.graphics.newQuad(width, 0, width, height, self.spritesheet),
        rightArm = love.graphics.newQuad(width*2, 0, width, height, self.spritesheet),
        leftLeg = love.graphics.newQuad(width*3, 0, width, height, self.spritesheet),
        rightLeg = love.graphics.newQuad(width*4, 0, width, height, self.spritesheet),
        torso = love.graphics.newQuad(width*5, 0, width, height, self.spritesheet),
        head = love.graphics.newQuad(width*6, 0, width, height, self.spritesheet)
    }
end


function BodyStatusGUI:draw()
    local startingOpacity = 0.7

    love.graphics.setColor(1, 1, 1, startingOpacity)
    love.graphics.draw(self.spritesheet, self.sprites.body, self.x, self.y, 0, 4)

    for name, bodyPart in pairs(self.bodyStatus) do
        local status = bodyPart.status
        if status > 0 then
            local color = status == 1 and {1, 0.36, 0, startingOpacity} or {0.73, 0, 0, startingOpacity}
            love.graphics.setColor(color)
            love.graphics.draw(self.spritesheet, self.sprites[name], self.x, self.y, 0, 4)
            love.graphics.setColor(1, 1, 1)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end