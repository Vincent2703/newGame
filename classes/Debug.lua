Debug = class("Debug")

function Debug:init()
    self.cycles = 0

    self.memory = {
        max = 0,
        current = 0,
        total = 0,
        avg = 0
    }

    self.fps = {
        min = 999,
        max = 0,
        current = 0,
        total = 0,
        avg = 0
    }

    self.visible = true
end

function Debug:update()
    if input.state.actions.newPress.debug then
        self.visible = not self.visible
    end

    self.memory.current = math.floor(collectgarbage("count")/100)
    if self.memory.current > self.memory.max then
        self.memory.max = self.memory.current
    end
    self.cycles = self.cycles+1
    self.memory.total = self.memory.total + self.memory.current
    self.memory.avg = math.floor(self.memory.total / self.cycles)

    self.fps.current = math.floor(1.0/love.timer.getDelta())
    if self.fps.current > self.fps.max and self.fps.current < 100 then
        self.fps.max = self.fps.current
    elseif self.fps.current < self.fps.min then
        self.fps.min = self.fps.current
    end
    if self.fps.current < 100 then
        self.fps.total = self.fps.total + self.fps.current
    end
    self.fps.avg = math.floor(self.fps.total / self.cycles)
end

function Debug:draw()
    if self.visible then
        love.graphics.print(("FPS: %d  min: %d avg: %d"):format(self.fps.current, self.fps.min, self.fps.avg), 10, 10)
        love.graphics.print(("Mem (Mo): %d  max: %d  avg: %d"):format(self.memory.current, self.memory.max, self.memory.avg), 10, 45)
        local currentPlayer = GameState:getState("InGame").currentPlayer
        if currentPlayer then
            love.graphics.print(("x: %d  y: %d"):format(currentPlayer.x, currentPlayer.y), 10, 80)
        end
    end
end