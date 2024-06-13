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

    -- Update the list of players
    self.sock:on("playersList", function(players)
        for _, player in ipairs(players) do --check ipairs
            if not self.players[player.connectId] then
                local isCurrentPlayer = player.connectId == self.sock:getConnectId()
                local deserializedPlayer = Player(player.x, player.y, player.connectId, player.peerId, false, isCurrentPlayer)
                if isCurrentPlayer --[[and player.peerId == tostring(self.sock.connection)--]] then 
                    GameState:getState("InGame").currentPlayer = deserializedPlayer --To know which player the client is
                end
                self.players[deserializedPlayer.connectId] = deserializedPlayer
            end
        end
    end)

    -- Receive the map and create it
    self.sock:on("newMap", function(map)
        local inGame = GameState:getState("InGame")
        inGame.map = Map:loadSTIMap(map)
        inGame:createCanvas(map.width*TILESIZE, map.height*TILESIZE)
    end)

    self.sock:on("playersUpdate", function(data)
        self:receivePong(data.timestamp)
        for _, serializedPlayer in pairs(data.players) do
            local connectID = serializedPlayer.connectId
            local player = self.players[connectID]
            local isCurrentPlayer = connectID == self.sock:getConnectId()
            if isCurrentPlayer then
                self.lastRequestProcessedID = serializedPlayer.lastRequestProcessedID
                serializedPlayer.isCurrentPlayer = true
            end

            player:applyServerResponse(serializedPlayer)
        end
    end)

    self.sock:connect()

    self.timeLastUpdate = 0
end

function Client:update(dt)
    local currentPlayer = GameState:getState("InGame").currentPlayer
    if currentPlayer then --TODO : create & use gameStarted
        if input.state.updated then
            --self.sock:setSendMode("reliable")
            --self:sendPing() --if debug true
            --self.sock:send("playerInputs", {id=self.lastRequestID, inputs=input.state})
        end
        
        self.timeAccumulator = self.timeAccumulator + dt
        while self.timeAccumulator >= FIXED_DT do
            local oldSelectedSlotID = currentPlayer.inventory.selectedSlot.id
            currentPlayer:clientUpdate(input.state)
            if input.state.updated then
                self.lastRequestID = self.lastRequestID +1
                self.inputsNotServProcessed[self.lastRequestID] = {input = input.state, pos = {x=currentPlayer.x, y=currentPlayer.y}}

                if Utils:countAssoTableItems(self.inputsNotServProcessed) > 25 then
                    self.inputsNotServProcessed[self.lastRequestID-20] = nil
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