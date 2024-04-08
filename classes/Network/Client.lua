Client = class("Client")

function Client:init()
    self.players = {}

    self.client = sock.newClient("localhost", 270398) --rename to sock

    -- Called when a connection is made to the server
    self.client:on("connect", function(data)
        print("Client connected to the server.")
    end)
    
    -- Called when the client disconnects from the server
    self.client:on("disconnect", function(data)
        print("Client disconnected from the server.")
    end)

    -- Custom callback, called whenever you send the event from the server
    self.client:on("hello", function(msg)
        print("The server replied : " .. msg)
    end)

    self.client:on("newPlayerConnected", function(player)
        local deserializedPlayer = Player(player.x, player.y)
        if player.id == self.client:getConnectId() then
            deserializedPlayer.current = true
        end
        table.insert(self.players, deserializedPlayer)
        print("Client : There is now "..#self.players.." connected player(s)" )
    end)

    self.client:connect()

    print("Client : "..self.client:getAddress())
end

function Client:update(dt)
    self.client:update()
end