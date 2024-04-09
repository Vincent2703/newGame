Level = class("Level")

function Level:init(width, height)
    self.bumpWorld = bump.newWorld(TILESIZE)

    self.tilesetPath = "../assets/tiles/tileset"
    self.tileset = require(self.tilesetPath)

    self.width, self.height = width, height

    self.rooms = {
       {
            x=22,
            y=4,
            w=3,
            h=3,
            doors={},
        },
        {
            x=8,
            y=4,
            w=5,
            h=4
        },
        {
            x=14,
            y=4,
            w=3,
            h=5
        },
        {
            x=13,
            y=10,
            w=3,
            h=5
        }
    }
    local nbRooms = 0

    for i=1, nbRooms do --Add random rooms
        if self:addRoom(self.rooms) == false then
            break
        end 
    end

    local stiMap = { --STI map configuration
        orientation = "orthogonal",
        width = self.width,
        height = self.height,
        tilewidth = TILESIZE,
        tileheight = TILESIZE,
        tilesets = {self.tileset},
        layers = {}
    }

    self.layers = { --Layers USEFUL TO HAVE SELF.LAYERS ? Can't do self.sti.layers if needed ?
        ground = self:addLayer(stiMap, "ground"),
        wallsTop = self:addLayer(stiMap, "wallsTop"),
        wallsBottom = self:addLayer(stiMap, "wallsBottom"),
        wallsRight = self:addLayer(stiMap, "wallsRight"),
        wallsLeft = self:addLayer(stiMap, "wallsLeft"),
        wallsLevel = self:addLayer(stiMap, "wallsLevel"),
    }

    --Tiles
    self.whiteGroundTileId = self:getTiles{type="ground", variation="white"}[1].id+1
    --self.greenGroundTileId = self:getTiles{type="ground", variation="green"}[1].id+1
    self.groundWoodTiles = self:getTiles({type="ground", variation="wood"})

    local allWallTiles = self:getTiles({type="wall", variation="brick"})
    self.wallTiles = {}
    for _, pos in ipairs({"front", "right", "left"}) do
        local tile = self:getTiles({position=pos}, allWallTiles)[1]
        self.wallTiles[pos] = {id=tile.id+1, collider=tile.objectGroup.objects[1]} --keep collider ?
    end

    self:fillSTIMap() --Rename to something else (createArchitecture() ?)

    self.sti = sti(stiMap)

    self:initLightWorld()
end

function Level:load(data)
    local map = self:create()
    map.width, map.height = data.width, data.height --remove ?
    map.tileset = require(data.tilesetPath)
    map.rooms = data.rooms

    map.bumpWorld = bump.newWorld(TILESIZE)
    for _, item in pairs(data.bumpItems) do
        if item.obstacle then
            map:addToBump({x=item.x, y=item.y, width=item.width, height=item.height, obstacle=true}, item.x, item.y, item.width, item.height)
        end
    end

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
        self:addLayer(stiMap, layer.name, layer.data)
    end

    map.sti = sti(stiMap)

    map:initLightWorld()

    return map
end


function Level:addRoom(rooms)
    local nbMaxTries = 50
    local currentTry = 0

    local minRoomSize = 3
    local maxRoomSize = 8

    while currentTry < nbMaxTries do
        local x, y, w, h = math.random(2, self.width), math.random(2, self.height), math.random(minRoomSize, maxRoomSize), math.random(minRoomSize, maxRoomSize) --should exclude x, y tried

        if x + w <= self.width and y + h <= self.height then
            local intersect = false
            for _, room in ipairs(rooms) do
                if Utils:rectsIntersect(x, x+w+1, y-1, y+h+1, room.x, room.x+room.w+1, room.y, room.y+room.h+1) then
                    intersect = true
                    break
                end
            end

            if not intersect then
                table.insert(rooms, {x = x, y = y, w = w, h = h, doors = {}})
                return true
            end
        end

        currentTry = currentTry+1
        if maxRoomSize >= minRoomSize and currentTry%3 == 0 then
            maxRoomSize = maxRoomSize-1
        end
    end

    return false
end

--[[
    Void
    Add the walls of a room in the current bump world.
    Used for collisions and libraries.shadows
]]
function Level:addRoomToBump(room)
    local frontTilesHeight = self.wallTiles.front.collider.height
    local lateralTilesWidth = self.wallTiles.right.collider.width --right/left doesn't matter

    
    -- top 
    local realX, realY = (room.x-1)*TILESIZE, (room.y-1)*TILESIZE
    if not room.doors.top then
        self:addToBump(room, realX, realY, room.w*TILESIZE, frontTilesHeight)
    else
        local width = room.doors.top.x*TILESIZE
        local first = {x=realX, w=width}
        self:addToBump(room, first.x, realY, first.w, frontTilesHeight)

        local width2 = (room.w-1)*TILESIZE-width
        local sec = {x=realX+width+TILESIZE, w=width2}
        self:addToBump(room, sec.x, realY, sec.w, frontTilesHeight)
    end

    -- bottom
    local realX, realY = (room.x-1)*TILESIZE, (room.y+room.h-1)*TILESIZE-1
    if not room.doors.bottom then
        self:addToBump(room, realX, realY, room.w*TILESIZE, frontTilesHeight)
    else
        local width = room.doors.bottom.x*TILESIZE
        local first = {x=realX, w=width}
        self:addToBump(room, first.x, realY, first.w, frontTilesHeight)

        local width2 = (room.w-1)*TILESIZE-width
        local sec = {x=realX+width+TILESIZE, w=width2}
        self:addToBump(room, sec.x, realY, sec.w, frontTilesHeight)
    end
    

    -- left
    local realX, realY = (room.x-1)*TILESIZE, (room.y-1)*TILESIZE 
    if not room.doors.left then
        self:addToBump(room, realX, realY, lateralTilesWidth, room.h*TILESIZE)
    else
        local height = room.doors.left.y*TILESIZE
        local first = {y=realY, h=height}
        self:addToBump(room, realX, first.y, lateralTilesWidth, first.h)

        local height2 = (room.h-1)*TILESIZE-height
        local sec = {y=realY+height+TILESIZE, h=height2}
        self:addToBump(room, realX, sec.y, lateralTilesWidth, sec.h)
    end

    -- right
    local realX, realY = (room.x+room.w-1)*TILESIZE-lateralTilesWidth*2+1, (room.y-1)*TILESIZE
    local xShadow = realX+lateralTilesWidth-1
    if not room.doors.right then
        self:addToBump(room, xShadow, realY, lateralTilesWidth, room.h*TILESIZE)
    else
        local height = room.doors.right.y*TILESIZE
        local first = {y=realY, h=height}
        self:addToBump(room, xShadow, first.y, lateralTilesWidth, first.h)

        local height2 = (room.h-1)*TILESIZE-height
        local sec = {y=realY+height+TILESIZE, h=height2}
        self:addToBump(room, xShadow, sec.y, lateralTilesWidth, sec.h)
    end

end

function Level:fillSTIMap()
    local width = self.width
    local height = self.height

    local groundWoodTiles = self.groundWoodTiles
    local wallTiles = self.wallTiles

    local ground = self.layers.ground.data
    local wallsTop = self.layers.wallsTop.data
    local wallsBottom = self.layers.wallsBottom.data
    local wallsRight = self.layers.wallsRight.data
    local wallsLeft = self.layers.wallsLeft.data
    local wallsLevel = self.layers.wallsLevel.data

    -- BUILD LEVEL'S PERIMETER
    for x=1, self.width do
        local idTileTop = Utils:conv2Dto1D(x, 1, self.width)
        local idTileBottom = Utils:conv2Dto1D(x, self.height, self.width)
        wallsLevel[idTileTop] = wallTiles.front.id
        wallsLevel[idTileBottom] = wallTiles.front.id
    end
    for y=1, self.height-1 do
        local idTileLeft = Utils:conv2Dto1D(1, y, self.width)
        local idTileRight = Utils:conv2Dto1D(self.width, y, self.width)
        wallsLevel[idTileLeft] = wallTiles.left.id
        wallsLevel[idTileRight] = wallTiles.right.id
    end

    -- BUILD ROOMS AND ENTRANCES
    local probaDoors = 0.5
    for _, room in ipairs(self.rooms) do 
        -- DOORS
        local doors = {}
        local sides = {}
        if room.y > 2 then table.insert(sides, "top") end
        if room.y+room.h < self.height then table.insert(sides, "bottom") end
        if room.x > 1 then table.insert(sides, "left") end
        if room.x+room.w < self.width then table.insert(sides, "right") end

        for _, room2 in ipairs(self.rooms) do
            if room.x == room2.x+room2.w+1 then
                lume.remove(sides, "left")
            end
            if room.x+room.w+1 == room2.x then
                lume.remove(sides, "right")
            end
            if room.y == room2.y+room2.h and lume.distance(room.x, room.y, room2.x, room2.y+room2.h, true) == 0.1 then
                lume.remove(sides, "top")
            end
            if room.y+room.h == room2.y and lume.distance(room.x, room.y+room.h, room2.x, room2.y, true) == 1 then
                lume.remove(sides, "bottom")
            end
        end

        local mandatorySide = lume.randomchoice(sides)
        doors[mandatorySide] = {}
        if mandatorySide == "left" or mandatorySide == "right" then
            doors[mandatorySide].y = math.random(1, room.h-2)
        else
            doors[mandatorySide].x = math.random(1, room.w-2)
        end
        lume.remove(sides, mandatorySide)
        for _, side in pairs(sides) do
            if math.random() <= probaDoors then
                doors[side] = {}
                if side == "left" or side == "right" then
                    doors[side].y = math.random(1, room.h-2)
                else
                    doors[side].x = math.random(1, room.w-2)
                end
                lume.remove(sides, side)
            end
        end
        room.doors = doors

        -- BORDERS ROOM
        for y=-1, room.h-1 do
            if y < room.h-1 then
                if not doors.left or doors.left.y ~= y then
                    local idTile = Utils:conv2Dto1D(room.x, room.y+y, width)
                    local tile = wallTiles.left -- LEFT
                    wallsLeft[idTile] = tile.id
                end
                if not doors.right or doors.right.y ~= y then
                    local right = Utils:conv2Dto1D(room.x+room.w-1, room.y+y, width)
                    local tile = wallTiles.right -- RIGHT
                    wallsRight[right] = tile.id
                end
            end

            if y>=0 then
                for x=0, room.w-1 do
                    local idTile = Utils:conv2Dto1D(room.x+x, room.y+y, self.width)
                    ground[idTile] = lume.randomchoice(groundWoodTiles).id+1 -- GROUND

                    if y==0 and (not doors.top or doors.top.x ~= x) then
                        local top = Utils:conv2Dto1D(room.x+x, room.y+y-1, self.width)
                        local tile = wallTiles.front
                        wallsTop[top] = tile.id -- TOP
                    elseif y==room.h-1 and (not doors.bottom or doors.bottom.x ~= x) then
                        local tile = wallTiles.front
                        wallsBottom[idTile] = tile.id -- BOTTOM
                    end
                end
            end
        end
        self:addRoomToBump(room)
    end    

    -- BLOCK ACCESS IF ROOM OR LEVEL'S PERIMETER CLOSE
    for _, room in ipairs(self.rooms) do 
        local topLeft = Utils:conv2Dto1D(room.x-1, room.y-1, self.width)
        local bottomLeft = Utils:conv2Dto1D(room.x-1, room.y+room.h-1, self.width)
        local topRight = Utils:conv2Dto1D(room.x+room.w, room.y-1, self.width)
        local bottomRight = Utils:conv2Dto1D(room.x+room.w, room.y+room.h-1, self.width)

        local tileHeight = wallTiles.front.collider.height

        if wallsRight[topLeft] or room.x == 2 then
            wallsTop[topLeft] = wallTiles.front.id
            local x, y = (room.x-2)*TILESIZE, (room.y-1)*TILESIZE-1
            self:addToBump({x=x, y=y, width=TILESIZE, height=tileHeight}, x, y, TILESIZE, tileHeight) --height key missing
        end
        if wallsRight[bottomLeft] or room.x == 2 then
            wallsBottom[bottomLeft] = wallTiles.front.id
            local x, y = (room.x-2)*TILESIZE, (room.y+room.h-1)*TILESIZE-1
            self:addToBump({x=x, y=y, width=TILESIZE, height=tileHeight}, x, y, TILESIZE, tileHeight)
        end
        if wallsLeft[topRight] or room.x+room.w == self.width then
            wallsTop[topRight] = wallTiles.front.id
            local x, y = (room.x+room.w-1)*TILESIZE, (room.y-1)*TILESIZE-1
            self:addToBump({x=x, y=y, width=TILESIZE, height=tileHeight}, x, y, TILESIZE, tileHeight)
        end
        if wallsLeft[bottomRight] or room.x+room.w == self.width then
            wallsBottom[bottomRight] = wallTiles.front.id
            local x, y = (room.x+room.w-1)*TILESIZE, (room.y+room.h-1)*TILESIZE-1
            self:addToBump({x=x, y=y, width=TILESIZE, height=tileHeight}, x, y, TILESIZE, tileHeight)
        end
    end
    

    -- BUILD CORRIDORS
    for idTile=1, self.width*self.height do
        local tile = ground[idTile]
        if not tile then
            ground[idTile] = self.whiteGroundTileId
        end
    end

end

function Level:addToBump(room, x, y, width, height)
    if width > height then
        height = 1
    end
    self.bumpWorld:add({x=x, y=y, width=width, height=height, obstacle=true}, x, y, width, height)
end

function Level:initLightWorld()
    self.lightWorld = LightWorld:new()

    local colliders = self.bumpWorld:getItems()
    for _, collider in pairs(colliders) do
        local newBody = Body:new(self.lightWorld)
        newBody:SetPosition(collider.x, collider.y, 2)

        local width, height = collider.width, collider.height
        if height > width then
            PolygonShadow:new(newBody, 0, 0, width, 0, width, height, 0, height) --left et right ok
        else
            PolygonShadow:new(newBody, 0, height, width, height, width, 0, 0, 0) --TL TR BR BL
        end
        
    end
end

function Level:getTiles(params, tiles)
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


function Level:addLayer(map, name, data)
    local layer = {
        type = "tilelayer",
        name = name,
        x = 0,
        y = 0,
        width = map.width,
        height = map.height,
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        properties = {},
        encoding = "lua",
        data = data or {}
      }

      table.insert(map.layers, layer)
      return layer
end

function Level:getRoomAtPos(x, y)
    for _, room in ipairs(self.rooms) do
        if x >= (room.x-1)*TILESIZE and x <= (room.x+room.w-1)*TILESIZE and
           y >= (room.y-1)*TILESIZE and y <= (room.y+room.h-1)*TILESIZE then
                return room
        end
    end
    return nil
end

function Level:update(dt)
    self.lightWorld:Update(dt)
end

function Level:draw()
    if #client.players > 0 then --temp
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
end