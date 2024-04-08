Server = class("Server")

function Server:init()
    self.server = sock.newServer("*", 270398)  --rename to sock
    self.players = {}
    self:startNewGame()

    self.server:on("connect", function(data, client)
        print("Server : new client connected")

        -- Send a message back to the connected client
        local msg = "Hello from the server !"
        client:send("hello", msg)

        self:newClient(client:getConnectId())
    end)

    print("Server : "..self.server:getAddress())

    self.server:on("playerInputs", function(data, client)
        if data then
            print(data.mouse.x)
        end
    end)
end

function Server:update(dt)
    self.server:update()
    if #self.players > 0 and level then
        level:update(dt)
        for _, player in pairs(self.players) do
            player:update(dt)
        end
    end
end


function Server:startNewGame()
    level = Level(25, 19)
    print("Server : New level")
end

function Server:newClient(connectId)
    local playerX, playerY = math.random(0, 40), math.random(0, 40)
    local player = Player(playerX, playerY)
    self.players[connectId] = player 
    local playerSerialized = {x = player.x, y = player.y, id = connectId}
    self.server:sendToAll("newPlayerConnected", playerSerialized)
end
