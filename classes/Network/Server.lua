Server = class("Server")

function Server:init()
    self.sock = sock.newServer("*", 27039)
    self.sock:enableCompression()

    self.players = {}
    self:startNewGame()

    -- A connection is made to the server
    self.sock:on("connect", function(data, client)
        print("A new client is connected to the server.")
        self:newClient(client, client.connection)
    end)

    -- Sync the time between the server and the clients
    self.sock:on("timeSyncRequest", function(clientTime, client)
            local serverTime = love.timer.getTime()
            --Send the server time and the original client send time back to the client
            local clientPeer = self.sock:getClientByConnectId(client:getConnectId()).connection
            self.sock:sendToPeer(clientPeer, "timeSyncResponse", {server=serverTime, client=clientTime})
    end)

    -- Input (keyboard/mouse) data received
    self.sock:on("playerInputs", function(data, client)
        local player = self.players[client:getConnectId()]
        player.input = data.inputs
        player.lastRequestProcessedID = data.id
        if data.selectedSlotID then
            player.inventory:setSelectedSlot(data.selectedSlotID)
        end
        
        player:serverUpdate()
    end)
end

function Server:update(dt)
    if self.gameStarted then
            local serializedPlayers = {}
            for _, player in pairs(self.players) do 
                if player.changed and player.lastRequestProcessedID then
                    player.changed = false
                    local serializedInventory = {} --TODO : serialized function
                    for _, slot in ipairs(player.inventory.slots) do
                        if slot.item ~= nil then
                            table.insert(serializedInventory, {id=slot.id, itemName=slot.item.name})
                        end
                    end  

                    local serializedPlayer = {
                        x = player.x,
                        y = player.y,
                        bodyStatus = player.bodyStatus,
                        angle = player.angle,
                        animationStatus = player.animationStatus,
                        inventory = serializedInventory,
                        connectId = player.connectId,
                        lastRequestProcessedID = player.lastRequestProcessedID
                    }

                    table.insert(serializedPlayers, serializedPlayer)
                end
            end
            if #serializedPlayers > 0 then
                --local dataToSend = {timestamp=love.timer.getTime(), players=serializedPlayers} --Pas besoin de timestamp ? Calculer depuis le client le temps de réponse ?
                self.sock:sendToAll("playersUpdate", serializedPlayers)
            end

            local map = GameState:getState("InGame").map
            if map.itemsMapUpdated then
                local serializedItemsMap = {}
                for _, item in ipairs(map.itemsMap) do
                    table.insert(serializedItemsMap, {name=item.instance.name, x=item.x, y=item.y})
                end
                self.sock:sendToAll("itemsMapUpdate", serializedItemsMap)
            end
        end

    self.sock:update()

end


function Server:startNewGame()
    -- Create new map
    local inGame = GameState:getState("InGame")
    local mapWidth, mapHeight = 30, 30
    inGame.map = Map(mapWidth, mapHeight)
    inGame:createCanvas(mapWidth*TILESIZE, mapHeight*TILESIZE)
    local map = inGame.map

    -- Serialize it to send it to other players
    --Walls (used to generate the LightWorld and the bumpWorld on the client side)
    local walls = {}
    local bumpItems, _ = map.bumpWorld:getItems()
    for _, item in pairs(bumpItems) do
        if item.obstacle then
            table.insert(walls,
                {
                    x = item.x,
                    y = item.y,
                    w = item.w,
                    h = item.h,
                }
            )
        end
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

    --Items
    local items = {}
    for _, item in ipairs(map.itemsMap) do
        local name = item.instance.name
        table.insert(items, {name=name, x=item.x, y=item.y})
    end

    self.serializedMap = {
        width = map.width,
        height = map.height,
        tilesetPath = map.tilesetPath,
        walls = walls,
        rooms = map.rooms,
        stiLayers = stiLayers,
        itemsMap = items
    }

    self.gameStarted = true
end



function Server:newClient(newClient, newClientPeer)
    local inGame = GameState:getState("InGame")
    local map = inGame.map

    local newClientConnectId = newClient:getConnectId()

    -- Send the map to the new client if it's not also the server
    if client and client.sock:getConnectId() ~= newClientConnectId then
        self.sock:sendToPeer(newClientPeer, "newMap", self.serializedMap)
    end

    -- Create a new player
    local playerX, playerY = map.spawnPoint.x*TILESIZE + math.random(-20, 20), map.spawnPoint.y*TILESIZE + math.random(-20, 20)
    local player = Player(playerX, playerY, newClientConnectId, true)

    -- Fill its inventory if necessary
    local serializedInventory = {} --TODO : serialized function
    for _, slot in ipairs(player.inventory.slots) do
        if slot.item ~= nil then
            table.insert(serializedInventory, {slotID=slot.id, itemName=slot.item.name})
        end
    end

    -- Update the players table
    self.players[newClientConnectId] = player

    -- Serialize the players
    local serializedPlayers = {}
    local newClientSerializedPlayer --To easily get the new player
    for connectId, player in pairs(self.players) do
        local serializedPlayer = {
            x = player.x,
            y = player.y,
            angle = player.angle,
            direction = player.direction,
            animationStatus = player.animationStatus,
            connectId = player.connectId,
        }
        if newClientConnectId == player.connectId then
            newClientSerializedPlayer = serializedPlayer
        end

        if #serializedInventory > 0 then
            serializedPlayer.inventory = serializedInventory --Send the inventory only if not empty
        end
        table.insert(serializedPlayers, serializedPlayer)
    end

    self.sock:sendToPeer(newClientPeer, "playersUpdate", serializedPlayers) --Send all players to the new player
    self.sock:sendToAllBut(newClient, "playersUpdate", {newClientSerializedPlayer}) --Send only the new player to all other players
end
