Level = class("Level")

function Level:init(path, player)
    self.map = sti(path)
    self.tileLayers = lume.filter(self.map.layers, function(layer) return layer.type=="tilelayer" end)

    self.spawnPoints = self:getLayer("spawnPoints").objects
    local randSpawnPoint = lume.randomchoice(self.spawnPoints)
    player.x, player.y = randSpawnPoint.x, randSpawnPoint.y
end

function Level:update(dt)
    self.map:update(dt)
end

function Level:draw()
    for _, layer in ipairs(self.tileLayers) do
        self.map:drawTileLayer(layer)
        if layer.name == "sprites.ground" then
            player:draw()
        end
    end
end


function Level:getLayer(name, group)
    local nameToFind = group and group..'.'..name or name

    for _, layer in pairs(self.map.layers) do
        if layer.name == nameToFind then
            return layer
        end
    end
end