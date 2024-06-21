InGame = class("InGame")

function InGame:init()
    -- Items creation
    self.items = {
        Consumable("Health potion",
            {filePath="assets/textures/items/potion.png", 
                sprites={ 
                    { x=1, y=1, w=16, h=16, color={1, 1, 1} }, 
                    { x=20, y=1, w=16, h=16, color={1, 0, 0.25} } 
                } 
            },
            function(player) player:heal(1) end
        )
    }
end

function InGame:update(dt) --Client side
    if self.map and self.map.lightWorld then --Map exists
        self.map.lightWorld:Update(dt)

        --TODO : move to function in Player
        for _, player in pairs(client.players) do
            player:manageAnimations(dt)
        end

        if self.currentPlayer then
            self.currentPlayer:smoothMove() --Interpolate at each frame
            self.currentPlayer.interface:update(dt)
        end
    end
end

function InGame:draw()
    if self.canvas and self.currentPlayer then
        love.graphics.setCanvas(self.canvas)
        self.map:draw()
        --[[if self.map.bumpWorld then
            local colliders = self.map.bumpWorld:getItems()
            for _, collider in pairs(colliders) do
                love.graphics.rectangle("line", collider.x, collider.y, collider.w, collider.h)    
            end
        end--]]
        love.graphics.setCanvas()
        love.graphics.draw(self.canvas, -self.currentPlayer.x*zoom+halfWidthWindow, -self.currentPlayer.y*zoom+halfHeightWindow, 0, zoom)
        
        self.currentPlayer.interface:draw()
    end
end


function InGame:createCanvas(width, height) --useful ?
    self.canvas = love.graphics.newCanvas(width, height)
end