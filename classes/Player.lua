Player = class("Player")

function Player:init(x, y)
    self.x, self.y = x, y
    self.radius = 10
    self.velocity = 140
    self.arc = -35
    self.angle = 180

    self.insideRoom = nil
    
    self.flashlightRadius = 150
    self.flashlight = Light:new(level.lightWorld, self.flashlightRadius)
    self.flashlight.Blur = false
    self.flashlight.Arc = self.arc
    self.flashlight:SetAngle(self.angle)
    --self.flashlight:SetColor(255, 255, 255, 255)
    self.flashlight:SetPosition(0, 0) --utile ? je ne pense pas

    self.haloLight = Light:new(level.lightWorld, 20)
    self.haloLight.Blur = false
    self.haloLight.Arc = 35
    self.haloLight:SetAngle(180-self.angle)
    self.haloLight:SetPosition(0, 0)

    level.bumpWorld:add(self, self.x, self.y, self.radius, self.radius)
end

function Player:update(dt)
    local dx, dy = 0, 0
    local velocity = self.velocity*dt

    if input.state.actions.right then
        dx = velocity
    elseif input.state.actions.left then
        dx = -velocity
    end

    if input.state.actions.up then
        dy = -velocity
    elseif input.state.actions.down then
        dy = velocity
    end

    local posX, posY = self.x+dx, self.y+dy

    local actualX, actualY = level.bumpWorld:move(self, posX, posY)

    if self.x ~= actualX or self.y ~= actualY then
        self.insideRoom = level:getRoomAtPos(actualX, actualY)
    end

    self.x, self.y = actualX, actualY
    self.flashlight:SetPosition(self.x, self.y)
    self.angle = lume.round(math.deg(math.atan2(input.state.mouse.y - halfHeightWindow, input.state.mouse.x - halfWidthWindow)))+180
    self.flashlight:SetAngle(self.angle)

    self.haloLight:SetPosition(self.x, self.y)
    self.haloLight:SetAngle(self.angle-180)

end

function Player:draw()
--    love.graphics.translate(self.x+halfWidthWindow-self.radius*2, self.y+halfHeightWindow-self.radius*2)
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1)
end

--setpos et setangle