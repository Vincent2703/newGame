InGame = class("InGame")

function InGame:init()

end

function InGame:update(dt)
    local function getCurrentPlayer()
        for _, player in pairs(client.players) do
            if player.current then
                return player
            end
        end
    end
    self.currentPlayer = getCurrentPlayer() --No need to check every frame...
    
    if input.state.changed then
        client.client:send("playerInputs", input.state)
    end
end

function InGame:draw()
    if self.currentPlayer then
        love.graphics.setCanvas(canvas)
        level:draw()
        love.graphics.setCanvas()
        love.graphics.draw(canvas, -self.currentPlayer.x*zoom+halfWidthWindow, -self.currentPlayer.y*zoom+halfHeightWindow, 0, zoom)
    end
end