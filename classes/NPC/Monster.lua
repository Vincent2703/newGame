Monster = class("Monster")

function Monster:init(x, y)
    self.x, self.y = x, y

    self.viewRadius = TILESIZE*5

    self.status = "idle" --Search/IDLE TODO : distinct name with animationStatus

    self.playerTarget = nil --Target to attack
    self.tileGoal = nil
    self.pathPoints = {}


    --Slime todo : subclasses
    self.velocity = 8
    self.spritesheet = love.graphics.newImage("assets/textures/characters/NPC/Slime.png")
    local spritesheetTileDim = 32
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
end

function Monster:serverUpdate(dt)
    --[[
        Poursuite déclenchée quand un joueur dans zone de perception. inCircleRadius + raytracing pour prendre en compte les obstacles
        Une fois la poursuite déclenchée, le monstre poursuit le joueur grâce à un algo de pathfinding.
        Quand le monstre est dans la même tuile que le joueur, n'utilise plus le pathfinding mais compare pos au px près pour se déplacer vers lui.
        La poursuite s'arrête si le joueur disparait de la zone de perception + marge
    ]]
    local players = server.players
    local playersInZone = {}
    
    for _, player in pairs(players) do
        if Utils:inCircleRadius(player.x, player.y, self.x, self.y, self.viewRadius) then
            local distance = lume.distance(player.x, player.y, self.x, self.y, true)
            table.insert(playersInZone, {instance=player, distance=distance})
        end
    end

    if #playersInZone > 0 then
        --print("in pursuit")
        self.status = "pursuit"
        playersInZone = lume.sort(playersInZone, "distance")
        self.playerTarget = playersInZone[1].instance
    else
        --print("idle")
        self.status = "idle"
        self.playerTarget = nil
    end
    
    --so far, it works

    if self.status == "pursuit" then
        local map = GameState:getState("InGame").map

        local startTilePosX, startTilePosY = map:absPosToTilePos(self.x, self.y)
        local start = {x=startTilePosX, y=startTilePosY}

        local oldGoal = self.tileGoal

        local playerTargetTilePosX, playerTargetTilePosY = map:absPosToTilePos(self.playerTarget.x, self.playerTarget.y)
        self.tileGoal = {x=playerTargetTilePosX, y=playerTargetTilePosY}

        local function cbIsPosOpen(x, y)
            return map:isPosOpen(x, y)
        end

        if oldGoal == nil or oldGoal.x ~= self.tileGoal.x or oldGoal.y ~= self.tileGoal.y then
            self.pathPoints = luastar:find(map.width, map.height, start, self.tileGoal, cbIsPosOpen, true) --last arg : cache
            print("find new path")
        else

            --check obstacle
            if self.x ~= self.playerTarget.x or self.y ~= self.playerTarget.y then
                local velRes = {vX=0, vY=0}
                if self.x > self.playerTarget.x then -- left
                    velRes.vX = -self.velocity*dt
                elseif self.x < self.playerTarget.x then -- right
                    velRes.vX = self.velocity*dt
                end
                if self.y > self.playerTarget.y then -- up
                    velRes.vY = -self.velocity*dt
                elseif self.y < self.playerTarget.y then -- down 
                    velRes.vY = self.velocity*dt
                end

                if velRes.vX ~= 0 or velRes.vY ~= 0 then
                    self.x = self.x + velRes.vX
                    self.y = self.y + velRes.vY
                    self.changed = true
                else
                    self.changed = false
                end
            end

        end


        if self.pathPoints then
            if self.pathPoints[1] then
                local monsterTilePosX, monsterTilePosY = map:absPosToTilePos(self.x, self.y)
                local tileTarget = self.pathPoints[1]

                local velRes = {vX=0, vY=0}
                if monsterTilePosX > tileTarget.x then -- left
                    velRes.vX = -self.velocity*dt
                elseif monsterTilePosX < tileTarget.x then -- right
                    velRes.vX = self.velocity*dt
                end
                if monsterTilePosY > tileTarget.y then -- up
                    velRes.vY = -self.velocity*dt
                elseif monsterTilePosY < tileTarget.y then -- down 
                    velRes.vY = self.velocity*dt
                end

                if velRes.vX ~= 0 or velRes.vY ~= 0 then
                    self.x = self.x + velRes.vX
                    self.y = self.y + velRes.vY
                    self.changed = true
                else
                    self.changed = false
                end

                monsterTilePosX, monsterTilePosY = map:absPosToTilePos(self.x, self.y)
                if monsterTilePosX == tileTarget.x and monsterTilePosY == tileTarget.y then
                    table.remove(self.pathPoints, 1)
                end
            end
        end

        if self.changed then
            self.animationStatus = "moving"
        end
    end
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
    self.currentAnimation:draw(self.spritesheet, lume.round(self.x), lume.round(self.y), 0, 1, 1, 8, 8)
end
