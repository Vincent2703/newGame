Client = class("Client")

function Client:init()
    self.timeAccumulator = 0

    self.latency = 0
    self.clientTimeOffset = 0

    self.inputsNotServProcessed = {}
    self.lastRequestID = 0 --The latest request id sent to the server (to process inputs)
    self.lastRequestProcessedID = nil

    self.players = {}

    self.sock = sock.newClient("localhost", 27039)
    self.sock:enableCompression()

    -- The connection is made to the server
    self.sock:on("connect", function(data)
        print("Client connected to the server.")
        local inGame = GameState:getState("InGame")

        local clientTime = love.timer.getTime() --TODO: Keep in client
        self.sock:send("timeSyncRequest", clientTime)
    end)

    -- Synchronize the time between the client and the server
    self.sock:on("timeSyncResponse", function(times)
        local clientReceiveTime = love.timer.getTime()
        local RTT = clientReceiveTime - times.client
        self.latency = RTT/2

        local clientTimeAtServerResponse = times.client + self.latency
        self.clientTimeOffset = times.server - clientTimeAtServerResponse
    end)
    
    -- The client disconnects from the server
    self.sock:on("disconnect", function(data)
        print("Client disconnected from the server.")
    end)

    -- Receive the map and create it
    self.sock:on("newMap", function(map)
        local inGame = GameState:getState("InGame")
        inGame.map = Map:loadSTIMap(map)
        inGame:createCanvas(map.width*TILESIZE, map.height*TILESIZE)
    end)


    -- Update the players
    self.sock:on("playersUpdate", function(serializedPlayers)
        for _, serializedPlayer in ipairs(serializedPlayers) do
            local isCurrentPlayer = serializedPlayer.connectId == self.sock:getConnectId()

            if self.players[serializedPlayer.connectId] == nil then --If new player
                local inGameState = GameState:getState("InGame")

                local deserializedNewPlayer = Player(serializedPlayer.x, serializedPlayer.y, serializedPlayer.connectId, false, isCurrentPlayer)
                deserializedNewPlayer.angle, deserializedNewPlayer.direction, deserializedNewPlayer.animationStatus = serializedPlayer.angle, serializedPlayer.direction, serializedPlayer.animationStatus
                if serializedPlayer.inventory then
                    for _, item in ipairs(serializedPlayer.inventory) do
                        deserializedNewPlayer.inventory:add(Item:getItemInTableByName(inGameState.items, item.itemName), item.slotID)
                    end
                end
                self.players[serializedPlayer.connectId] = deserializedNewPlayer
                if isCurrentPlayer then
                    inGameState.currentPlayer = deserializedNewPlayer
                end
            else --Update the existing player
                local player = self.players[serializedPlayer.connectId]
                if isCurrentPlayer then
                    self.lastRequestProcessedID = serializedPlayer.lastRequestProcessedID
                    serializedPlayer.isCurrentPlayer = true
                end
                player:applyServerResponse(serializedPlayer)
            end
        end
    end)

    self.sock:on("itemsMapUpdate", function(items)
        local inGameState = GameState:getState("InGame")
        local allItems = inGameState.items --Table with all items
        local itemsMap = inGameState.map.itemsMap --Table with items on the map
        
        inGameState.map.itemsMap = {}
        for _, serializedItem in ipairs(items) do
            local item = Item:getItemInTableByName(allItems, serializedItem.name)
            table.insert(itemsMap, {instance=item, x=serializedItem.x, y=serializedItem.y})
        end
    end)

    self.sock:connect()

    self.timeLastUpdate = 0
end

function Client:update(dt)
    local currentPlayer = GameState:getState("InGame").currentPlayer --attr ?
    if currentPlayer then --TODO : create & use gameStarted
        local oldSelectedSlotID = currentPlayer.inventory.selectedSlot.id
        currentPlayer.inventory:update()
        
        self.timeAccumulator = self.timeAccumulator + dt

        while self.timeAccumulator >= FIXED_DT do
            currentPlayer:clientUpdate()
            if input.state.updated then
 
                self.lastRequestID = self.lastRequestID +1
                self.inputsNotServProcessed[self.lastRequestID] = {input = input.state, pos = {x=currentPlayer.x, y=currentPlayer.y}} --rename to buffer smth

                if Utils:countAssoTableItems(self.inputsNotServProcessed) > 25 then
                    self.inputsNotServProcessed[self.lastRequestID-25] = nil
                end

                local dataToSend = {
                    id = self.lastRequestID, 
                    inputs = input.state
                }
                local newSelectedSlotID = currentPlayer.inventory.selectedSlot.id
                if oldSelectedSlotID ~= newSelectedSlotID then
                    dataToSend.selectedSlotID = newSelectedSlotID
                end
                self.sock:send("playerInputs", dataToSend)
            end

            self.timeAccumulator = self.timeAccumulator - FIXED_DT
        end
    end
    self.sock:update()
end


function Client:sendPing()
    local startTime = love.timer.getTime()
    self.sock:send("ping", startTime)
end

function Client:receivePong(serverTime)
    self.lastServerTimestamp = serverTime
    local endTime = self.clientTimeOffset + love.timer.getTime()
    self.latency = (endTime - serverTime) / 2
end