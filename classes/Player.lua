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
    self.animationStatus = "idle"
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

    self.velocity = 60*FIXED_DT
    self.arc = -35
    self.angle = 180

    self.insideRoom = nil
    self.lookingRoom = nil
    
    self.currentMap = GameState:getState("InGame").map
    self.body = Body:new(self.currentMap.lightWorld)
    self:setPosition(x, y)

    --self.clientX, self.clientY = x, y

    self.inventory = Inventory()

    self.inventory:add(GameState:getState("InGame").items.healthpotion)

    self.bodyStatus = { -- 0: fine 1: partially damaged 2: fully damaged
        head = {status = 2, effect = nil},
        leftArm = {status = 0, effect = nil},
        rightArm = {status = 0, effect = nil},
        torso = {status = 0, effect = nil},
        leftLeg = {status = 0, effect = nil},
        rightLeg = {status = 0, effect = nil}
    }

    --if fromServer then
        self.currentMap.bumpWorld:add(self, self.x-8, self.y-8, self.w, self.h)
    --else
        self:createLights()
        self.interface = Interface(self)
    --end

    self.input = input.state

    self.predictedPositions = {}
end




function Player:clientUpdate(dataInput)
    local inputState = dataInput or input.state --To rename 
    local newPos = self:getNewPos(inputState)

    --setPos()
    self.x, self.y = newPos.x, newPos.y
    
    self.angle = Utils:calcAngleBetw2Pts(halfWidthWindow, halfHeightWindow, self.input.mouse.x, self.input.mouse.y) --use lume function
    self.direction = self:getDirection(self.angle)
    self.animationStatus = (newPos.dx ~= 0 or newPos.dy ~= 0) and "walk" or "idle"

    --Inventory TODO : recreate update function
    local inventory = self.inventory
    local idSlot = inventory.selectedSlot.id
    if inputState.mouse.wheelmovedUp then
        if idSlot-1 == 0 then
            idSlot = #inventory.slots
        else
            idSlot = idSlot-1
        end
    elseif inputState.mouse.wheelmovedDown then
        if idSlot+1 > #inventory.slots then
            idSlot = 1
        else
            idSlot = idSlot+1
        end
    end
    self.inventory:setSelectedSlot(idSlot)
end

function Player:applyServerResponse(player)
    if player.isCurrentPlayer then --If current player, do corrections
        local posSaved = client.inputsNotServProcessed[player.lastRequestProcessedID].pos --Get the old pos that corresponds with the response received
        if player.x ~= posSaved.x or player.y ~= posSaved.y then --Check if differents
            local newState = {x=player.x, y=player.y} --Create a new state and recalculate the pos with the new starting pos
            
            for i=player.lastRequestProcessedID+1, client.lastRequestID do
                local newPos = self:getNewPos(client.inputsNotServProcessed[i].input, newState.x, newState.y)
                newState.x, newState.y = newPos.x, newPos.y
            end
            --Compare with current position
            if newState.x ~= self.goalX then
                self.goalX = newState.x
                self.x = lume.round(lume.lerp(self.x, newState.x, 0.5), 0.1)
            end
            if newState.y ~= self.goalY then
                self.goalY = newState.y
                self.y = lume.round(lume.lerp(self.y, newState.y, 0.5), 0.1)
            end
        end
    else --Otherwise, no need correction
        if player.x then
            self.x = player.x
        end
        if player.y then
            self.y = player.y
        end
    end

    self.animationStatus = player.animationStatus

    if player.angle then
        self:setAngle(player.angle)

        self.direction = self:getDirection(player.angle)
    end

    if player.inventory then
        for _, slot in ipairs(self.inventory.slots) do
            local serverInvSlot = player.inventory[slot.id]
            local clientInvSlot = self.inventory.slots[slot.id]
            if serverInvSlot then
                clientInvSlot.item = GameState:getState("InGame").items[serverInvSlot]
            else
                clientInvSlot.item = nil
            end
        end

    end

    if player.bodyStatus then
        self.bodyStatus = player.bodyStatus
        self.interface.GUIItems.bodyStatus.bodyStatus = self.bodyStatus --?
    end
end

function Player:serverUpdate()
    local prevX, prevY, prevAngle, oldStatus = self.x, self.y, self.angle, self.animationStatus

    local newPos = self:getNewPos(self.input)

    --setPos()
    self.x, self.y = lume.round(newPos.x), lume.round(newPos.y)
    
    self.angle = self.input.mouse.angle
    --self.direction = self:getDirection(self.angle)
    self.animationStatus = (newPos.dx ~= 0 or newPos.dy ~= 0) and "walk" or "idle"

    local inventory = self.inventory
    for _, col in ipairs(newPos.collisions) do
        local item = col.other
        if class.isInstance(item) and item:instanceOf(Item) then
            inventory:add(item)
        end
    end

    --Create a function
    local inputActions = self.input.actions

    --print(inventory.selectedSlot.name, inventory.selectedSlot.item)

    local inventoryUpdated = false
    if inventory.selectedSlot.item and inventory.selectedSlot.item:instanceOf(Item) then
        local item = inventory.selectedSlot.item
        if inputActions.newPress.action then
            item:use()
            inventory:removeItemSlotId(inventory.selectedSlot.id)
            inventoryUpdated = true
        elseif inputActions.newPress.throw then
            inventory:removeItemSlotId(inventory.selectedSlot.id)
            inventoryUpdated = true
        end
    end

    self.changed = self.input.keyReleased or self.x ~= prevX or self.y ~= prevY or self.angle ~= prevAngle or self.animationStatus ~= oldStatus or inventoryUpdated
end

function Player:getNewPos(input, startX, startY)
    local dx, dy = 0, 0
    
    if input.actions.right then
        dx = self.velocity
    elseif input.actions.left then
        dx = -self.velocity
    end

    if input.actions.up then
        dy = -self.velocity
    elseif input.actions.down then
        dy = self.velocity
    end

    local x, y = startX or self.x, startY or self.y
    local posX, posY = lume.round(x+dx, 0.1), lume.round(y+dy, 0.1)

    local actualX, actualY, cols = self.currentMap.bumpWorld:move(self, posX, posY,
    function(player, otherItem) --manageCollisions()
        if otherItem.obstacle then
            return "slide"
        elseif class.isInstance(otherItem) and otherItem:instanceOf(Item) then
            return "cross"
        end
    end)

    return {
        x=actualX, 
        y=actualY, 
        dx=dx, 
        dy=dy,
        collisions=cols
    }
end

function Player:smoothMove()
    if self.goalX == self.x then
        self.goalX = nil
    end
    if self.goalY == self.y then
        self.goalY = nil
    end
    if self.goalX and self.x ~= self.goalX then
        self.x = lume.round(lume.lerp(self.x, self.goalX, 0.8), 0.1)
    end
    if self.goalY and self.y ~= self.goalY then
        self.y = lume.round(lume.lerp(self.y, self.goalY, 0.8), 0.1)
    end
end



function Player:draw()
    self.currentAnimation:draw(self.spritesheet, lume.round(self.x), lume.round(self.y), 0, 1, 1, 8, 8)
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
    self.currentAnimation = self.animations[self.direction][self.animationStatus]

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

function Player:interpolatePosition(dt)

end

function Player:setAngle(angle)
    self.angle = angle
    self.flashlight:SetAngle(self.angle)
    if self.current then
        self.haloLight:SetAngle(self.angle-180)
    end
end


function Player:heal(qt)
    local damagedBodyParts = lume.filter(self.bodyStatus, function(damagedPart) return damagedPart.status > 0 end)
    if #damagedBodyParts > 0 then
        local bodyPartToHeal = lume.randomchoice(damagedBodyParts)
        bodyPartToHeal.status = bodyPartToHeal.status-1
    end
end