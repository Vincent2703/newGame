Map = class("Map")

function Map:init(width, height)
    self.tilesetPath = "../assets/tiles/tileset"
    self.tileset = require(self.tilesetPath)

    self.width, self.height = width, height

    self.spawnPoint = { x = 1, y = math.random(2, self.height - 1) }

    self:createArchitectureMap()
    local minDimMap = math.min(width, height)
    self:generateCorridors(9, math.floor(minDimMap / 2), minDimMap, 2)
    self:generateRooms(12, 4, 6)

    -- Print the architecture map DEBUG
    for y = 1, self.height do
        local col = ''
        for x = 1, self.width do
            col = col .. self.architecture[x][y]
        end
        print(col)
    end

    self.sti = self:generateSTIMap()

    -- BUMP
    self.bumpWorld = self:generateBumpWorld()

    -- Lightworld
    self.lightWorld = self:generateLightWorld()
end

function Map:roomOverlaps(x, y, w, h)
    for _, room in ipairs(self.rooms) do
        -- Check if there's any overlap
        if not (x + w < room.x or x > room.x + room.w - 1 or
                y + h < room.y or y > room.y + room.h - 1) then
            return true -- There is an overlap
        end
    end
    return false -- No overlap found
end


function Map:createArchitectureMap()
    self.architecture = {}
    -- Create and fill the architecture map with nothing
    for x = 1, self.width do
        self.architecture[x] = {}
        for y = 1, self.height do
            self.architecture[x][y] = 0
        end
    end
end

function Map:generateCorridors(nbCorridors, corridorDimMin, corridorDimMax, widthCorridor)
    self.corridors = {}
    -- Create initial corridor
    local initialCorridor = {
        x = self.spawnPoint.x,
        y = self.spawnPoint.y,
        w = math.random(corridorDimMin, corridorDimMax),
        h = widthCorridor,
        dir = 2
    }
    table.insert(self.corridors, initialCorridor)

    -- Create additional corridors
    for i = 2, nbCorridors do
        local existingCorridor = self.corridors[math.random(1, #self.corridors)]
        local corridorDir = existingCorridor.dir % 2 + 1 -- Alternate direction: 1 for vertical, 2 for horizontal

        local corridor = {
            dir = corridorDir,
            w = (corridorDir == 1) and widthCorridor or math.random(corridorDimMin, corridorDimMax),
            h = (corridorDir == 2) and widthCorridor or math.random(corridorDimMin, corridorDimMax)
        }

        -- Determine the start position of the new corridor to ensure it connects with the existing corridor
        if corridorDir == 1 then  -- Vertical corridor
            corridor.x = existingCorridor.x + math.random(-corridor.w + 1, existingCorridor.w - 1)
            corridor.y = (math.random() > 0.5) and (existingCorridor.y + existingCorridor.h) or (existingCorridor.y - corridor.h)
        else  -- Horizontal corridor
            corridor.y = existingCorridor.y + math.random(-corridor.h + 1, existingCorridor.h - 1)
            corridor.x = (math.random() > 0.5) and (existingCorridor.x + existingCorridor.w) or (existingCorridor.x - corridor.w)
        end

        -- Ensure the corridor stays within the map boundaries
        corridor.x = math.max(1, math.min(corridor.x, self.width - corridor.w + 1))
        corridor.y = math.max(1, math.min(corridor.y, self.height - corridor.h + 1))

        table.insert(self.corridors, corridor)
    end

    -- Fill the architecture map with the corridors
    for _, corridor in ipairs(self.corridors) do
        local startX, startY = math.max(corridor.x, 1), math.max(corridor.y, 1)
        local endX, endY = math.min(corridor.x + corridor.w - 1, self.width), math.min(corridor.y + corridor.h - 1, self.height)

        for y = startY, endY do
            for x = startX, endX do
                self.architecture[x][y] = 1
            end
        end
    end
end

function Map:generateRooms(nbRooms, roomDimMin, roomDimMax)
    self.rooms = {}
    -- Create rooms
    for i = 1, nbRooms do
        local attempts = 0
        local roomPlaced = false

        while not roomPlaced and attempts < 50 do
            local room = {
                w = math.random(roomDimMin, roomDimMax),
                h = math.random(roomDimMin, roomDimMax)
            }

            local places = {"corridors"}
            if i > 1 then
                places = {"rooms", "corridors"}
            end
            local place = lume.randomchoice(places)

            local randomPlace = place == "corridors" and self.corridors[math.random(1, #self.corridors)] or self.rooms[math.random(1, #self.rooms)]

            -- Check all possible sides to place the room
            local sides = {}

            if randomPlace.x - room.w > 1 then
                table.insert(sides, "left")
            end
            if randomPlace.x + randomPlace.w + room.w <= self.width then
                table.insert(sides, "right")
            end
            if randomPlace.y - room.h > 1 then
                table.insert(sides, "top")
            end
            if randomPlace.y + randomPlace.h + room.h <= self.height then
                table.insert(sides, "bottom")
            end

            local side = lume.randomchoice(sides)
            if side == "left" then
                room.x = randomPlace.x-room.w
                room.y = math.random(randomPlace.y, randomPlace.y+randomPlace.h-2) --Check if empty at this pos ?
            elseif side == "right" then
                room.x = randomPlace.x+randomPlace.w --+1 ?
                room.y = math.random(randomPlace.y, randomPlace.y+randomPlace.h-2)
            elseif side == "top" then
                room.x = math.random(randomPlace.x, randomPlace.x+randomPlace.w-1)
                room.y = randomPlace.y-room.h
            elseif side == "bottom" then
                room.x = math.random(randomPlace.x, randomPlace.x+randomPlace.w-1)
                room.y = randomPlace.y+randomPlace.h --+1 ?
            end            

            -- Check for room overlaps
            if room.x and room.y and
            room.x > 0 and room.x+room.w <= self.width and room.y > 0 and room.y+room.h <= self.height
            and not self:roomOverlaps(room.x, room.y, room.w, room.h) then
                table.insert(self.rooms, room)
                roomPlaced = true
            else
                attempts = attempts + 1
            end
        end
    end

    -- Fill the architecture map with the rooms
    for _, room in ipairs(self.rooms) do
        local xStart, xEnd = room.x, room.x + room.w - 1
        local yStart, yEnd = room.y, room.y + room.h - 1

        for y = yStart, yEnd do
            for x = xStart, xEnd do
                self.architecture[x][y] = 2
            end
        end
    end

    -- Add doors the architecture map 
    for _, room in ipairs(self.rooms) do
        local possibleDoors = {top={}, bottom={}, left={}, right={}}
        for x=room.x, room.x+room.w-1 do --x=room.x+1, room.x+room.w-2
            if room.y-1 > 0 then
                if self.architecture[x][room.y-1] == 1 then
                    table.insert(possibleDoors.top, {x=x, y=room.y})
                end
            end
            if room.y+room.h+1 <= self.height then
                if self.architecture[x][room.y+room.h] == 1 then
                    table.insert(possibleDoors.bottom, {x=x, y=room.y+room.h-1})
                end
            end
        end
        for y=room.y, room.y+room.h-1 do --y=room.y+1, room.y+room.h-2
            if room.x-1 > 0 then
                if self.architecture[room.x-1][y] == 1 then
                    table.insert(possibleDoors.left, {x=room.x, y=y})
                end
            end
            if room.x+room.w+1 <= self.width then
                if self.architecture[room.x+room.w][y] == 1 then
                    table.insert(possibleDoors.right, {x=room.x+room.w-1, y=y})
                end
            end
        end
        local addedDoors = 0
        for _, posDoors in pairs(possibleDoors) do 
            if #posDoors > 1 and addedDoors < 2 then
                local randPos = lume.randomchoice(posDoors)
                self.architecture[randPos.x][randPos.y] = 3
                addedDoors = addedDoors+1
            end
        end
    end
end

function Map:generateSTIMap()    
    local layers = {
        ground = self:addLayer("ground"),
        wallsTop = self:addLayer("wallsTop"),
        wallsBottom = self:addLayer("wallsBottom"), 
        wallsLeft = self:addLayer("wallsLeft"),
        wallsRight = self:addLayer("wallsRight")
    }

    local stiMap = { --STI map configuration
        orientation = "orthogonal",
        width = self.width,
        height = self.height,
        tilewidth = TILESIZE,
        tileheight = TILESIZE,
        tilesets = {self.tileset},
        layers = {}
    }


    local whiteGroundTileId = self:getTiles{type="ground", variation="white"}[1].id+1
    local greenGroundTileId = self:getTiles{type="ground", variation="green"}[1].id+1
    local groundWoodTiles = self:getTiles({type="ground", variation="wood"})

    local allWallTiles = self:getTiles({type="wall", variation="brick"})
    local wallTiles = {}
    for _, pos in ipairs({"front", "right", "left"}) do
        local tile = self:getTiles({position=pos}, allWallTiles)[1]
        wallTiles[pos] = {id=tile.id+1, collider=tile.objectGroup.objects[1]} --keep collider ?
    end

    for y=1, self.height do
        for x=1, self.width do
            local posTile = Utils:conv2Dto1D(x, y, self.width)
            local tiles = {
                current = self.architecture[x][y],
                top = self.architecture[x][y-1] or nil,
                bottom = self.architecture[x][y+1] or nil,
                left = self.architecture[x-1] and self.architecture[x-1][y] or nil,
                right = self.architecture[x+1] and self.architecture[x+1][y] or nil,

                leftBottom = self.architecture[x-1] and self.architecture[x-1][y+1] or nil,
                rightBottom = self.architecture[x+1] and self.architecture[x+1][y+1] or nil
            }

            -- Ground
            local lGround = layers.ground.data
            if tiles.current == 1 then
                lGround[posTile] = lume.randomchoice(groundWoodTiles).id+1
            elseif tiles.current == 2 then
                lGround[posTile] = whiteGroundTileId
            elseif tiles.current == 3 then
                lGround[posTile] = greenGroundTileId
            end

            -- left walls corridors test
            local lWLeft = layers.wallsLeft.data
            local lWRight = layers.wallsRight.data
            local lWTop = layers.wallsTop.data
            local lWBottom = layers.wallsBottom.data

            if tiles.current == 2 then
                if (tiles.left == 1 or tiles.left == 0) and (tiles.bottom == 2 or tiles.bottom == 3) then
                    lWLeft[posTile] = wallTiles.left.id
                end
                if (tiles.right == 1 or tiles.right == 0) and (tiles.bottom == 2 or tiles.bottom == 3) and (tiles.rightBottom == 0 or tiles.rightBottom == 1) then
                    lWRight[posTile] = wallTiles.right.id
                end
                if tiles.bottom == 1 or tiles.bottom == 0 then
                    lWBottom[posTile] = wallTiles.front.id
                end

                if tiles.left == 2 and tiles.bottom == 2 and (tiles.leftBottom == 0 or tiles.leftBottom == 1) then
                    lWLeft[posTile] = wallTiles.left.id
                end
            elseif tiles.current == 1 then
                if tiles.bottom == 2 then
                    lWTop[posTile] = wallTiles.front.id
                    if tiles.leftBottom == 0 or tiles.leftBottom == 1 and tiles.bottom == 0 then
                        lWLeft[posTile] = wallTiles.left.id
                    end
                    if tiles.rightBottom == 0 or tiles.rightBottom == 1 and tiles.bottom == 0 then
                        lWRight[posTile] = wallTiles.right.id
                    end
                end
            elseif tiles.current == 0 then
                if tiles.bottom ~= 0 then
                    lWTop[posTile] = wallTiles.front.id
                end
                if tiles.top == 1 then
                    lWBottom[posTile] = wallTiles.front.id
                end
                if tiles.right == 1 and tiles.bottom == 0 then
                    lWRight[posTile] = wallTiles.right.id
                end
                if tiles.left == 1 and tiles.bottom == 0 then
                    lWLeft[posTile] = wallTiles.left.id
                end
            end

            --[[if tiles.current and tiles.current > 0 then
                if y < self.height then
                    if x==1 then
                        lWLeft[posTile] = wallTiles.left.id
                    elseif x==self.width then
                        lWRight[posTile] = wallTiles.right.id
                    end
                end
                if y==1 then
                    lWTop[posTile] = wallTiles.front.id
                elseif y==self.height then
                    lWBottom[posTile] = wallTiles.front.id
                end
            end--]]

        end
    end


    for _, layerName in ipairs({"ground", "wallsTop", "wallsBottom", "wallsLeft", "wallsRight"}) do
        table.insert(stiMap.layers, layers[layerName])
    end

    return sti(stiMap)
end

function Map:loadSTIMap(data)
    local map = self:create() --Create instance of class without doing what's inside init()

    map.width, map.height = data.width, data.height
    map.tileset = require(data.tilesetPath)
    map.rooms = data.rooms
    --map.layers = {}

    map.bumpWorld = map:generateBumpWorld()

    local stiMap = { 
        orientation = "orthogonal",
        width = data.width,
        height = data.height,
        tilewidth = TILESIZE,
        tileheight = TILESIZE,
        tilesets = {map.tileset},
        layers = {}
    }

    for _, layer in ipairs(data.stiLayers) do
        local newLayer = map:addLayer(layer.name, layer.data)
        --table.insert(map.layers, newLayer) --useful ?
        table.insert(stiMap.layers, newLayer)
    end

    map.sti = sti(stiMap)

    map.lightWorld = self:generateLightWorld()

    return map
end


function Map:addLayer(name, data)
    local layer = {
        type = "tilelayer",
        name = name,
        x = 0,
        y = 0,
        width = self.width,
        height = self.height,
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        properties = {},
        encoding = "lua",
        data = data or Utils:tableFill(nil, self.width*self.height)
    }

    return layer
end

function Map:getTiles(params, tiles)
    local tiles = tiles or self.tileset.tiles
    return lume.filter(tiles, function(tile) 
        if not tile.properties then
            return false
        end
        local result = true

        for key, value in pairs(params) do
            result = result and tile.properties[key] ~= nil and tostring(tile.properties[key]) == tostring(value)
            if not result then
                return false
            end
        end
        return true
    end)
end

function Map:generateBumpWorld()
    local bumpWorld = bump.newWorld(TILESIZE)

    --Borders map
    local width, height = self.width*TILESIZE, self.height*TILESIZE
    local borders = {
        top = {x=0, y=0, w=width, h=1},
        bottom = {x=0, y=height, w=width, h=1},
        left = {x=0, y=0, w=1, h=height},
        right = {x=width, y=0, w=1, h=height}
    }

    for _, border in pairs(borders) do
        bumpWorld:add(border, border.x, border.y, border.w, border.h)
    end

    return bumpWorld
end

function Map:generateLightWorld()
    local lightWorld = LightWorld:new()

    --[[local colliders = self.bumpWorld:getItems()
    for _, collider in pairs(colliders) do
        local newBody = Body:new(self.lightWorld)
        newBody:SetPosition(collider.x, collider.y, 2)

        local width, height = collider.width, collider.height
        if height > width then
            PolygonShadow:new(newBody, 0, 0, width, 0, width, height, 0, height) --left et right ok
        else
            PolygonShadow:new(newBody, 0, height, width, height, width, 0, 0, 0) --TL TR BR BL
        end
        
    end--]]

    return lightWorld
end


function Map:update(dt)
    self.lightWorld:Update(dt)
end

function Map:draw()
    for _, layer in ipairs(self.sti.layers) do
        --[[if (player.insideRoom and layer.name == "wallsBottom") or not player.insideRoom and layer.name == "wallsTop" then
            layer.opacity = 0.8
        else
            layer.opacity = 1
        end--]]
            self.sti:drawTileLayer(layer)
            if layer.name == "ground" then --check if visible before drawing the players and the rest
                for _, player in pairs(client.players) do
                    player:draw()
                end
            end

    end
    --love.graphics.origin()
    --self.lightWorld:Draw()
end