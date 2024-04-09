Server = class("Server")

function Server:init()
    self.sock = sock.newServer("*", 27039)
    self.players = {}
    self:startNewGame()

    self.sock:on("connect", function(data, client)
        print("Server : new client connected")

        -- Send a message back to the connected client
        local msg = "Hello from the server !"
        client:send("hello", msg)

        self:newClient(client:getConnectId(), tostring(client.connection))
    end)

    print("Server : "..self.sock:getAddress())

    self.sock:on("playerInputs", function(data, client)
        --[[if data then
            print(data.mouse.x)
        end--]]
    end)
end

function Server:update(dt)
    self.sock:update()
    if #self.players > 0 and level then
        level:update(dt)
        for _, player in pairs(self.players) do --check
            player:update(dt)
        end
    end
end


function Server:startNewGame()
    level = Level(25, 19) --Should not be global
    print("Server : New level")
end

function Server:newClient(connectId, peerId)
    -- Send the map to the new client if its not also the server
    if client and client.sock:getConnectId() ~= connectId then
            --SHOULD DO IT ONCE
        --Bump items
        local serializedBumpItems = {}
        local bumpItems, _ = level.bumpWorld:getItems()
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

        for _, layer in ipairs(level.sti.layers) do
            local newLayerData = {} 
            for y=1, layer.height do --to fix x and y
                for x=1, layer.width do
                    if layer.data[y] and layer.data[y][x] then
                        table.insert(newLayerData, layer.data[y][x].id+1)
                    else
                        table.insert(newLayerData, 0)
                    end
                end
            end
            table.insert(stiLayers, {name=layer.name, data=newLayerData})
        end

        local serializedMap = {
            width = level.width,
            height = level.height,
            tilesetPath = level.tilesetPath,
            bumpItems = serializedBumpItems,
            rooms = level.rooms,
            stiLayers = stiLayers,
        }

        local clientPeer = self.sock:getClientByConnectId(connectId).connection
        self.sock:sendToPeer(clientPeer, "newMap", serializedMap)
    end

        -- Create a new player, update the players table and send it to all
        local playerX, playerY = math.random(0, 40), math.random(0, 40)
        local player = Player(playerX, playerY, connectId, peerId)
        table.insert(self.players, player)
    
        local serializedPlayers = {}
        for _, player in pairs(self.players) do
            local serializedPlayer = {
                x = player.x,
                y = player.y,
                connectId = player.connectId,
                peerId = player.peerId
            }
            table.insert(serializedPlayers, serializedPlayer)
        end
        self.sock:sendToAll("updatePlayers", serializedPlayers)
    
    
end
