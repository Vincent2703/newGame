GameState = class("GameState")

function GameState:init()
    self.states = {
        Home = Home(),
        InGame = InGame(),
    }
    self.prevState = nil
    self.currentState = nil
end

function GameState:setState(stateName, start)
    self.prevState = self:getCurrentStateClassName()
    self.currentState = self.states[stateName]
    if start then
        self.currentState:start()
    end
end

function GameState:getCurrentStateClassName()
    if self.currentState then
        return self.currentState.className
    else
        return nil
    end
end

function GameState:getPreviousStateClassName()
    if self.prevState then
        return self.prevState.className
    else
        return nil
    end
end

function GameState:isCurrentState(stateName)
    return self:getCurrentStateClassName() == stateName
end

function GameState:update(dt)
    if self.currentState then
        self.currentState:update(dt)
    end
end

function GameState:draw()
    if self.currentState then
        self.currentState:draw()
    end
end