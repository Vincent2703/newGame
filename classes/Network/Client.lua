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
        for _, player in pairs(players) do
            local deserializedPlayer = Player(player.x, player.y, player.connectId, player.peerId)
            if player.connectId == self.sock:getConnectId() --[[and player.peerId == tostring(self.sock.connection)--]] then 
                GameState:getState("InGame").currentPlayer = deserializedPlayer --To know which player the client is
            end
            table.insert(self.players, deserializedPlayer)
        end
    end)

    self.sock:on("newMap", function(map)
        local inGame = GameState:getState("InGame")
        inGame.map = Map:loadSTIMap(map)
        inGame:createCanvas(map.width*TILESIZE, map.height*TILESIZE)
    end)

    self.sock:connect()
end

function Client:update(dt)
    self.sock:update()
end