Interface = class("Interface")

function Interface:init(player)
    self.canvas = love.graphics.newCanvas()

    self.GUIItems = {
        inventory = InventoryGUI(player.inventory),
        bodyStatus = BodyStatusGUI(player.bodyStatus)
    }

    self.opacity = 0

    self.times = {
        delay = 1.2,
        duration = 0.5
    }

    self.delay = self.times.delay
    self.duration = self.times.duration
end

function Interface:show()
    self.opacity = 1

    self.delay = self.times.delay
    self.duration = self.times.duration
end


function Interface:update(dt)
    if self.opacity > 0 then
        if self.delay > 0 then
            self.delay = self.delay-dt
        else
            self.duration = self.duration-dt
            self.opacity = math.max(0, self.duration/0.5)
        end
    end

    if input.state.mouse.wheelmovedUp or input.state.mouse.wheelmovedDown then
        self:show()
    end

    --[[for _, gui in pairs(self.GUIItems) do
        gui:update(dt)
    end--]]
end

function Interface:draw()
    if self.opacity > 0 then
        love.graphics.setCanvas(self.canvas)
        love.graphics.clear()

        for _, gui in pairs(self.GUIItems) do
            gui:draw()
        end
        love.graphics.setCanvas()

        love.graphics.setColor(1, 1, 1, self.opacity)
        love.graphics.draw(self.canvas)
        love.graphics.setColor(1, 1, 1, 1)
    end
end