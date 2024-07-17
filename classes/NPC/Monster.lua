Monster = class("Monster")

function Monster:init(x, y)
    self.x, self.y = x, y
    self.w, self.h = 14, 10

    self.viewRadius = TILESIZE*5
    self.sqDistAbortPursuit = 5000

    self.status = "idle" --Search/IDLE TODO : distinct name with animationStatus

    self.playerTarget = nil --Target to attack
    self.lastPlayerTargetPos = nil
    self.goal = nil

    --Slime todo : subclasses
    self.velocity = 8
    self.spritesheet = love.graphics.newImage("assets/textures/characters/NPC/Slime.png")
    local spritesheetTileDim = 32
    self.offsetX, self.offsetY = spritesheetTileDim/2-self.w/2, spritesheetTileDim/2-self.h/2
    self.offsetX = self.offsetX%2==0 and self.offsetX+1 or self.offsetX
    self.offsetY = self.offsetY%2==0 and self.offsetY+1 or self.offsetY
    local grid = anim8.newGrid(spritesheetTileDim, spritesheetTileDim, self.spritesheet:getWidth(), self.spritesheet:getHeight())
    self.animationStatus = "idle"

    local function newAnimation(params) --In Utils ?
        speed = params.speed or 0.2
        return anim8.newAnimation(grid(params.cols or 1, params.row or 1), speed, params.callback or nil)
    end
    self.animations = {
        idle = newAnimation({cols="8-9"}),
        moving = newAnimation({cols="1-6", callback="rewind", speed=0.15})
    }
    self.currentAnimation = self.animations[self.animationStatus]

    self.changed = false

    self.currentMap = GameState:getState("InGame").map
    local widthMapPX, heightMapPX = self.currentMap.width*TILESIZE, self.currentMap.height*TILESIZE
    self.currentMap.bumpWorld:add(self, self.x, self.y, self.w, self.h)

    self.pathfinding = Pathfinding(widthMapPX, heightMapPX, TILESIZE/2,
    function(x, y) 
        --[[local notBorder = y > 0 and y < widthMapPX and x > 0 and x < heightMapPX
        local tileAvailable = false
        if notBorder then
            tileAvailable = self.currentMap.architecture[math.ceil(x/TILESIZE)][math.ceil(y/TILESIZE)] ~= 0
        end--]]

        if true--[[notBorder and tileAvailable--]] then
            local _, len = self.currentMap.bumpWorld:queryRect(x-self.w/2, y-self.h/2, self.w, self.h, 
            function(obj) 
                return obj.obstacle 
            end) 
            return len == 0
        else
            return false
        end
    end)

    self.timeLastPathFinding = 0
    self.delayPathFinding = 0.5 --in s
end

function Monster:serverUpdate(dt)
    local function filterPathIsClear(obj)
        return obj.obstacle
    end

    self.timeLastPathFinding = self.timeLastPathFinding + dt --To avoid too much calculations, min time between calcs

    local players = server.players
    local playersInZone = {}
    
    for _, player in pairs(players) do --Get the players in the view radius
        if Utils:inCircleRadius(player.x, player.y, self.x, self.y, self.viewRadius) then
            local _, len = self.currentMap.bumpWorld:querySegment(self.x, self.y, player.x, player.y, filterPathIsClear) --Is player visible ?
            if len == 0 then
                local distance = lume.distance(player.x, player.y, self.x, self.y, true)
                table.insert(playersInZone, {instance=player, distance=distance})
            end
        end
    end

    if #playersInZone > 0 then
        self.status = "pursuit"
        playersInZone = lume.sort(playersInZone, "distance") --Sort the players by distance
        self.playerTarget = playersInZone[1].instance --Get the closer one
    else
        self.status = "idle"
        self.playerTarget = nil
    end
    
    if self.status == "pursuit" then
        local map = GameState:getState("InGame").map

        local start = {x=lume.round(self.x), y=lume.round(self.y)} --Monster
        local goal = {x=self.playerTarget.x+self.playerTarget.w/2, y=self.playerTarget.y+self.playerTarget.h/2} --Player (middle of it)

        local function cbIsPathOK(goalX, goalY)
            local _, len = map.bumpWorld:queryRect(goalX, goalY, self.w, self.h, filterPathIsClear)
            return len == 0
        end

        local velRes = {vX=0, vY=0}

        if self.timeLastPathFinding >= self.delayPathFinding then --Delay elapsed
            self.timeLastPathFinding = 0
            if self.lastPlayerTargetPos == nil or self.lastPlayerTargetPos.x ~= self.playerTarget.x or self.lastPlayerTargetPos.y ~= self.playerTarget.y then --If the player moved
                --Depending on the monster's position relative to the player's one, query segments to check that the path is clear
                local clearPath = true
                if start.x < goal.x then --Check top right and bottom right
                    local _, lenTopRight = self.currentMap.bumpWorld:querySegment(start.x+self.w, start.y, goal.x, goal.y, filterPathIsClear) --top right
                    local _, lenBottomRight = self.currentMap.bumpWorld:querySegment(start.x+self.w, start.y+self.h, goal.x, goal.y, filterPathIsClear) --bottom right
                    clearPath = lenTopRight + lenBottomRight == 0
                elseif start.x > goal.x then --Check top left and bottom left
                    local _, lenTopLeft = self.currentMap.bumpWorld:querySegment(start.x, start.y, goal.x, goal.y, filterPathIsClear) --top left
                    local _, lenBottomLeft = self.currentMap.bumpWorld:querySegment(start.x, start.y+self.h, goal.x, goal.y, filterPathIsClear) --bottom left
                    clearPath = lenTopLeft + lenBottomLeft == 0
                end
                if start.y < goal.y then --Check bottom left and bottom right
                    local _, lenBottomLeft = self.currentMap.bumpWorld:querySegment(start.x, start.y+self.h, goal.x, goal.y, filterPathIsClear) --bottom left
                    local _, lenBottomRight = self.currentMap.bumpWorld:querySegment(start.x+self.w, start.y+self.h, goal.x, goal.y, filterPathIsClear) --bottom right
                    clearPath = lenBottomLeft + lenBottomRight == 0
                elseif start.y > goal.y then --Check top left and top right
                    local _, lenTopLeft = self.currentMap.bumpWorld:querySegment(start.x, start.y, goal.x, goal.y, filterPathIsClear) --top left
                    local _, lenBottomLeft = self.currentMap.bumpWorld:querySegment(start.x, start.y+self.h, goal.x, goal.y, filterPathIsClear) --bottom left
                    clearPath = lenTopLeft + lenBottomLeft == 0
                end
                --If path is clear
                if clearPath then
                    self.pathPoints = {goal} --Direct path
                else --Use pathfinding
                    self.pathPoints = self.pathfinding:getPath(start, goal)
                end

            end
            self.lastPlayerTargetPos = {x=self.playerTarget.x, y=self.playerTarget.y}
        end

        if self.pathPoints and self.pathPoints[1] then --If found route
            local posTarget = {x=self.pathPoints[1].x-self.w/2, y=self.pathPoints[1].y-self.h/2}
            
            if self.x > posTarget.x then -- left
                velRes.vX = -self.velocity*dt
            elseif self.x < posTarget.x then -- right
                velRes.vX = self.velocity*dt
            end
            if self.y > posTarget.y then -- up
                velRes.vY = -self.velocity*dt
            elseif self.y < posTarget.y then -- down 
                velRes.vY = self.velocity*dt
            end

            if velRes.vX ~= 0 or velRes.vY ~= 0 then
                local newPos = {x=self.x+velRes.vX, y=self.y+velRes.vY}
                self.changed = newPos.x ~= self.x or newPos.y ~= self.y
                self.x, self.y = newPos.x, newPos.y
    
                if lume.round(self.x) == posTarget.x and lume.round(self.y) == posTarget.y then
                    table.remove(self.pathPoints, 1)
                end    
            else
                self.changed = false
            end
  
        end

        if self.changed then
            self.animationStatus = "moving"
        end
    end
end

--[[function Monster:getNewPos(velX, velY)
    local posX, posY = self.x+velX, self.y+velY

    local actualX, actualY, cols = self.currentMap.bumpWorld:move(self, posX, posY,
    function(monster, other) --TODO : add in function (filter)
        if other.obstacle then
            return "slide"
        end
    end)

    return {
        x=actualX, 
        y=actualY, 
        dx=velX, 
        dy=velY,
        collisions=cols
    }
end--]]

function Monster:clientUpdate(dt)
    self.currentAnimation = self.animations[self.animationStatus]

    self.currentAnimation:update(dt)
end

function Monster:applyServerResponse(serializedMonster)
    self.x, self.y = serializedMonster.x, serializedMonster.y
    self.animationStatus = serializedMonster.animationStatus
end

function Monster:draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", lume.round(self.x), lume.round(self.y), self.w, self.h)
    love.graphics.setColor(1, 1, 1)
    self.currentAnimation:draw(self.spritesheet, lume.round(self.x), lume.round(self.y), 0, 1, 1, self.offsetX, self.offsetY)
end
