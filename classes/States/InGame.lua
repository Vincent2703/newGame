InGame = class("InGame")

function InGame:init()

end

function InGame:update(dt)
    if self.map then --Map exists
        self.map:update(dt)

        if input.state.changed then
            client.sock:send("playerInputs", input.state)
        end
    end
end

function InGame:draw()
    if self.canvas and self.currentPlayer then
        love.graphics.setCanvas(self.canvas)
        self.map:draw()
        love.graphics.setCanvas()
        love.graphics.draw(self.canvas, -self.currentPlayer.x*zoom+halfWidthWindow, -self.currentPlayer.y*zoom+halfHeightWindow, 0, zoom)
    end
end


function InGame:createCanvas(width, height)
    self.canvas = love.graphics.newCanvas(width, height)
end