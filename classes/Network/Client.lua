Client = class("Client")

function Client:init()
    self.players = {}

    self.sock = sock.newClient("localhost", 27039)

    -- sock when a connection is made to the server
    self.sock:on("connect", function(data)
        print("Client connected to the server.") --Too soon to have a Player instance
    end)
    
    -- Called when the client disconnects from the server
    self.sock:on("disconnect", function(data)
        print("Client disconnected from the server.")
    end)

    -- Custom callback, called whenever you send the event from the server
    self.sock:on("hello", function(msg)
        print("The server replied : " .. msg)
    end)

    self.sock:on("updatePlayers", function(players)
        for _, player in pairs(players) do
            local deserializedPlayer = Player(player.x, player.y, player.connectId, player.peerId)
            if player.connectId == self.sock:getConnectId() --[[and player.peerId == tostring(self.sock.connection)--]] then
                deserializedPlayer.current = true
            end
            table.insert(self.players, deserializedPlayer)
        end
    end)

    self.sock:on("newMap", function(map)
        level = Level:load(map)
    end)

    self.sock:connect()

    print("Client : "..self.sock:getAddress())
end

function Client:update(dt)
    self.sock:update()
end