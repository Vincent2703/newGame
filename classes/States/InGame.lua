InGame = class("InGame")

function InGame:init()
end

function InGame:update(dt)
    if self.map then --Map exists
        self.map:update(dt)

        if input.state.changed then
            client.sock:send("playerInputs", input.state)
        end

        for _, player in pairs(client.players) do
            player:manageAnimations(dt)
        end

        if self.currentPlayer then
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