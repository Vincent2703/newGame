Client = class("Client")

function Client:init()
    self.players = {}

    self.sock = sock.newClient("localhost", 27039)

    -- The connection is made to the server
    self.sock:on("connect", function(data)
        print("Client connected to the server.")
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

    self.sock:on("playersUpdate", function(players)
        for _, serializedPlayer in pairs(players) do
            local player = self.players[serializedPlayer.connectId]
            player:updateFromClient(serializedPlayer)
        end
    end)

    self.sock:connect()
end

function Client:update(dt)
    self.sock:update()
end