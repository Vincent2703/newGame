Player = class("Player")

function Player:init(x, y, connectId, peerId, fromServer, current)
    self.connectId = connectId
    self.peerId = peerId

    self.current = current or false
    
    self.spritesheet = love.graphics.newImage("assets/textures/players/Character-Base.png")
    local spritesheetTileDim = 32
    self.spritesheetTileHalfDim = spritesheetTileDim/2
    local grid = anim8.newGrid(spritesheetTileDim, spritesheetTileDim, self.spritesheet:getWidth(), self.spritesheet:getHeight())
    self.w, self.h = 16, 16

    self.direction = "backward"
    self.status = "idle"
    local function newAnimation(cols, row, speed)
        speed = speed or 0.2
        return anim8.newAnimation(grid(cols, row), speed)
    end
    self.animations = {
        backward = {
            idle = newAnimation("1-2", 1),
            walk = newAnimation("2-3", 1),
        },
        backwardRight = {
            idle = newAnimation("1-2", 2),
            walk = newAnimation("2-3", 2),
        },
        right = {
            idle = newAnimation("1-2", 3),
            walk = newAnimation("2-3", 3),
        },
        forwardRight = {
            idle = newAnimation("1-2", 4),
            walk = newAnimation("2-3", 4),
        },
        forward = {
            idle = newAnimation("1-2", 5),
            walk = newAnimation("2-3", 5),
        },
        forwardLeft = {
            idle = newAnimation("1-2", 6),
            walk = newAnimation("2-3", 6),
        },
        left = {
            idle = newAnimation("1-2", 7),
            walk = newAnimation("2-3", 7),
        },
        backwardLeft = {
            idle = newAnimation("1-2", 8),
            walk = newAnimation("2-3", 8),
        }
    }
    self.currentAnimation = self.animations[self.direction].idle

    self.velocity = 140
    self.arc = -35
    self.angle = 180

    self.insideRoom = nil
    self.lookingRoom = nil
    
    self.currentMap = GameState:getState("InGame").map
    self.body = Body:new(self.currentMap.lightWorld)
    self:setPosition(x, y)

    if fromServer then
        self.currentMap.bumpWorld:add(self, self.x-8, self.y-8, self.w, self.h)
    else
        self:createLights()
    end

    self.input = input.state
end


function Player:updateFromServer(dt)
    local oldX, oldY, oldAngle, oldStatus = self.x, self.y, self.angle, self.status

    local dx, dy = 0, 0
    local velocity = self.velocity*dt

    self.angle = Utils:calcAngleBetw2Pts(halfWidthWindow, halfHeightWindow, self.input.mouse.x, self.input.mouse.y) --use lume function

    self.direction = self:getDirection(self.angle)

    if self.input.actions.right then
        dx = velocity
    elseif self.input.actions.left then
        dx = -velocity
    end

    if self.input.actions.up then
        dy = -velocity
    elseif self.input.actions.down then
        dy = velocity
    end
    
    if dx ~= 0 or dy ~= 0 then
        self.status = "walk"
    else
        self.status = "idle"
    end

    local posX, posY = self.x+dx, self.y+dy

    local actualX, actualY = self.currentMap.bumpWorld:move(self, posX, posY)
    actualX = lume.round(actualX)
    actualY = lume.round(actualY)

    if self.x ~= actualX or self.y ~= actualY then
        self.insideRoom = self.currentMap:getRoomAtPos(actualX+8, actualY+8)
    end

    self.x, self.y = actualX, actualY

    self.changed = self.x ~= oldX or self.y ~= oldY or self.angle ~= oldAngle or self.status ~= oldStatus
end

function Player:updateFromClient(data)
    self:setPosition(data.x, data.y)

    self:setAngle(data.angle)
    self.direction = data.direction

    self.status = data.status
    self.insideRoom = data.insideRoom
end


function Player:draw()
    self.currentAnimation:draw(self.spritesheet, self.x, self.y, 0, 1, 1, 8, 8)
end

function Player:getDirection(angle)
    if angle >= 67.5 and angle < 112.5 then
        return "forward" 
    elseif angle >= 112.5 and angle < 157.5 then
        return "forwardRight"
    elseif angle >= 157.5 and angle < 202.5 then
        return "right"
    elseif angle >= 202.5 and angle < 247.5 then
        return "backwardRight"
    elseif angle >= 247.5 and angle < 292.5  then
        return "backward"
    elseif angle >= 292.5 and angle < 337.5 then
        return "backwardLeft"
    elseif angle >= 337.5 or angle < 22.5 then
        return "left"
    elseif angle >= 22.5 and angle < 67.5 then
        return "forwardLeft"
    end
end

function Player:manageAnimations(dt)
    self.currentAnimation = self.animations[self.direction][self.status]

    self.currentAnimation:update(dt)
end

function Player:createLights()
    self.flashlightRadius = 140
    self.flashlight = Light:new(self.currentMap.lightWorld, self.flashlightRadius)
    self.flashlight:GetTransform():SetParent(self.currentMap.lightWorld:TrackBody(self.body))
    self.flashlight.Blur = true
    self.flashlight.player = self
    self.flashlight.GradientEffect = true
    self.flashlight.Arc = self.arc
    self.flashlight:SetAngle(self.angle)
    self.flashlight.displayWalls = true


    if self.current then
        self.haloLightRadius = self.flashlightRadius/2
        self.haloLight = Light:new(self.currentMap.lightWorld, self.haloLightRadius)
        self.haloLight:GetTransform():SetParent(self.currentMap.lightWorld:TrackBody(self.body))
        --self.haloLight.Blur = true
        self.haloLight.A = 150
        self.haloLight:SetAngle(180-self.angle)
    end

end

function Player:setPosition(x, y)
    self.x, self.y = x, y
    self.body:SetPosition(x+8, y+8)
end

function Player:setAngle(angle)
    self.angle = angle
    self.flashlight:SetAngle(self.angle)
    if self.current then
        self.haloLight:SetAngle(self.angle-180)
    end
end