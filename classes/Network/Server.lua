Server = class("Server")

function Server:init()
    self.sock = sock.newServer("*", 27039)
    self.players = {}
    self:startNewGame()

    -- A connection is made to the server
    self.sock:on("connect", function(data, client)
        print("A new client is connected to the server.")
        self:newClient(client:getConnectId(), tostring(client.connection))
    end)

    -- Input (keyboard/mouse) data received
    self.sock:on("playerInputs", function(data, client)
        if data then --?
            self.players[client:getConnectId()].input = data --set input data
        end
    end)
end

function Server:update(dt)
    self.sock:update()
    if self.gameStarted then
        --map:update(dt)
        local serializedPlayers = {}
        for _, player in pairs(self.players) do --check ipairs ?
            player:updateFromServer(dt)
            if player.changed then
                local serializedPlayer = {
                    x=player.x,
                    y=player.y,
                    angle=player.angle,
                    direction=player.direction,
                    status=player.status,
                    insideRoom=player.insideRoom,
                    connectId=player.connectId 
                }
                table.insert(serializedPlayers, serializedPlayer)
            end
        end
        self.sock:sendToAll("playersUpdate", serializedPlayers)
    end
end


function Server:startNewGame()
    -- Create new map
    local inGame = GameState:getState("InGame")
    local mapWidth, mapHeight = 30, 30
    inGame.map = Map(mapWidth, mapHeight)
    inGame:createCanvas(mapWidth*TILESIZE, mapHeight*TILESIZE)
    local map = inGame.map

    -- Serialize it to send it to other players
    --Bump items
    local serializedBumpItems = {}
    local bumpItems, _ = map.bumpWorld:getItems()
    for _, item in pairs(bumpItems) do
        table.insert(serializedBumpItems,
            {
                x = item.x,
                y = item.y,
                width = item.width,
                height = item.height,
                obstacle = item.obstacle
            }
        )
    end

    --STI layers
    local stiLayers = {}

    for _, layer in ipairs(map.sti.layers) do
        local newLayerData = {} 
        for y=1, layer.height do
            for x=1, layer.width do
                local tile = layer.data[y] and layer.data[y][x]
                table.insert(newLayerData, tile and tile.id + 1 or 0)
            end
        end
        table.insert(stiLayers, {name=layer.name, data=newLayerData})
    end

    self.serializedMap = {
        width = map.width,
        height = map.height,
        tilesetPath = map.tilesetPath,
        bumpItems = serializedBumpItems,
        rooms = map.rooms,
        stiLayers = stiLayers,
    }

    self.gameStarted = true
end



function Server:newClient(connectId, peerId)
    local inGame = GameState:getState("InGame")
    local map = inGame.map

    -- Send the map to the new client if it's not also the server
    if client and client.sock:getConnectId() ~= connectId then
        local clientPeer = self.sock:getClientByConnectId(connectId).connection
        self.sock:sendToPeer(clientPeer, "newMap", self.serializedMap)
    end

    -- Create a new player, update the players table and send it to all
    local playerX, playerY = map.spawnPoint.x*TILESIZE +math.random(-20, 20), map.spawnPoint.y*TILESIZE +math.random(-20, 20)
    local player = Player(playerX, playerY, connectId, peerId, true)

    --self.players, par connectId
    self.players[connectId] = player
    --table.insert(self.players, player)

    local serializedPlayers = {}
    for connectId, player in pairs(self.players) do
        local serializedPlayer = {
            x = player.x,
            y = player.y,
            connectId = player.connectId,
            peerId = player.peerId
        }
        table.insert(serializedPlayers, serializedPlayer)
    end
    self.sock:sendToAll("playersList", serializedPlayers)    
end
