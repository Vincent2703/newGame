Monster = class("Monster")

function Monster:init(x, y)
    self.x, self.y = x, y
    self.w, self.h = 14, 10

    self.viewRadius = TILESIZE*3
    self.sqViewRadius = self.viewRadius*self.viewRadius
    self.sqMaxDistAttack = 100

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
        idle = newAnimation({row=2, cols="1-2"}),
        moving = newAnimation({cols="1-6", callback="rewind", speed=0.15}),
        dying = newAnimation({row=3, cols="1-5", speed=0.1}),
        attacking = newAnimation({row=4, cols="1-3", speed=0.15})
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

    self.timeLastAttack = 0
    self.delayAttack = 2
end

function Monster:serverUpdate(dt)
    local oldX, oldY, oldAnimationStatus = self.x, self.y, self.animationStatus --To know if changed

    local function filterPathIsClear(obj)
        return obj.obstacle
    end

    self.timeLastPathFinding = self.timeLastPathFinding + dt --To avoid too much calculations, min time between calcs
    self.timeLastAttack = self.timeLastAttack + dt

    local players = server.players

    local function getNearestPlayerInView()
        local closestDist = math.huge
        local nearestPlayer = nil
        for _, player in pairs(players) do
            if Utils:inCircleRadius(player.x, player.y, self.x, self.y, self.viewRadius) then --In radius
                local _, lenObstacles = self.currentMap.bumpWorld:querySegment(self.x, self.y, player.x, player.y, filterPathIsClear)
                if lenObstacles == 0 then --Si le joueur est visible, pas caché par un obstacle
                    local distance = lume.distance(player.x, player.y, self.x, self.y, true) --Distance entre le monstre et le joueur
                    if distance < closestDist then
                        closestDist = distance
                        nearestPlayer = player
                    end
                end
            end
        end
        return nearestPlayer
    end
    

    if self.playerTarget == nil then --Si on a pas de cible
        local nearestPlayer = getNearestPlayerInView()
        if nearestPlayer then --Si on trouve un joueur à poursuivre
            self.playerTarget = nearestPlayer
            self.status = "pursuit" --On le poursuit
        end
    else --Si on a déjà une cible
        local distance = lume.distance(self.playerTarget.x+self.playerTarget.w/2, self.playerTarget.y+self.playerTarget.h/2, self.x+self.w/2, self.y+self.h/2, true) --Distance entre le joueur et le monstre
        if distance <= self.sqMaxDistAttack then --Si on est à distance d'attaque
            self.pathPoints = nil --Plus besoin d'avancer
            if self.timeLastAttack >= self.delayAttack then --Si l'attaque est rechargée
                self.status = "attack" --On attaque
                self.timeLastAttack = 0 --On remet le compteur à 0
                self.playerTarget:takeDamage(1, {"leftLeg", "rightLeg"})
            else --Si l'attaque n'est pas rechargée
                self.status = "idle" --On ne bouge pas
            end 
        else --Si on est trop loin pour attaquer
            if distance <= self.sqViewRadius then --Si on est pas trop loin pour abandonner la poursuite
                self.status = "pursuit"
            else -- Si on est trop loin pour continuer à poursuivre
                self.pathPoints = nil --On ne bouge plus
                self.status = "idle" 
                self.playerTarget = nil --A l'update suivante, on recherchera un joueur
            end
        end
    end

    
    if self.status == "pursuit" then
        local map = GameState:getState("InGame").map

        local start = {x=lume.round(self.x), y=lume.round(self.y)} --Monster
        local goal = {x=self.playerTarget.x+self.playerTarget.w/2, y=self.playerTarget.y+self.playerTarget.h/2} --Player (middle of it)

        local function cbIsPathOK(goalX, goalY)
            local _, len = map.bumpWorld:queryRect(goalX, goalY, self.w, self.h, filterPathIsClear)
            return len == 0
        end

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
            local velRes = {vX=0, vY=0}

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
                self.x, self.y = newPos.x, newPos.y
                if lume.round(self.x) == posTarget.x and lume.round(self.y) == posTarget.y then
                    table.remove(self.pathPoints, 1)
                end                    
            end
        end
    end

    local isNewPos = oldX ~= self.x or oldY ~= self.y
    if isNewPos then
        self.animationStatus = "moving"
    elseif self.status == "attack" then
        self.animationStatus = "attacking"
    else
        if oldAnimationStatus ~= "attacking" then
            self.animationStatus = "idle"
        end
    end


    self.changed = isNewPos or oldAnimationStatus ~= self.animationStatus
end

function Monster:clientUpdate(dt)
    self.currentAnimation = self.animations[self.animationStatus]

    self.currentAnimation:update(dt)
end

function Monster:applyServerResponse(serializedMonster)
    self.x, self.y = serializedMonster.x, serializedMonster.y
    self.animationStatus = serializedMonster.animationStatus
end

function Monster:draw()
    self.currentAnimation:draw(self.spritesheet, lume.round(self.x), lume.round(self.y), 0, 1, 1, self.offsetX, self.offsetY)
end
