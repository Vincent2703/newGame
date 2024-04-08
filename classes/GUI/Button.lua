Button = class("Button")

function Button:init(x, y, content, callback)
    self.x, self.y = x, y
    self.typeContent = nil
    if type(content) == "string" then
        self.typeContent = "string"
    elseif type(content) == "userdata" and content:typeOf("Image") then
        self.typeContent = "image"
    end
    self.content = content

    self.callback = callback or function() end
    self.pressed = false
    self.colorA = {0, 0, 0}
    self.colorB = {10, 10, 10}
    self.background = nil

    self.visible = true

    if self.typeContent == "string" then
        local currentFont = love.graphics.getFont()
        self.widthContent, self.heightContent = currentFont:getWidth(content), currentFont:getHeight()
        self.width, self.height = lume.round(self.widthContent*1.2), lume.round(self.heightContent*2)
    elseif self.typeContent == "image" then
        self.widthContent, self.heightText = content:getDimensions()
        self.width, self.height = lume.round(self.widthContent*1.2), lume.round(self.heightContent*2)
    end

    self.event = "release"
end

function Button:update()
    local mouseX, mouseY = input.state.mouse.x, input.state.mouse.y

    local function checkInBounds()
        if self:instanceOf(RectangleButton) then
            local margin = self.background == nil and 20 or 0
            return mouseX >= self.x-margin and mouseX <= self.x + self.width + margin and mouseY >= self.y - margin and mouseY <= self.y + self.height + margin
        elseif self:instanceOf(CircleButton) then
            return math.sqrt((mouseX-self.centerX)^2 + (mouseY-self.centerY)^2) <= self.radius
        end
    end

    if self.visible then
        if input.state.actions.click and checkInBounds() then
            self.pressed = true
            if self.event == "press" then
                self.callback()
            end
        else
            if self.event == "release" and self.pressed and checkInBounds() then
                self.callback()
            end
            self.pressed = false
        end
    end
end


function Button:setCallback(fn)
    self.callback = fn --()?
end

function Button:setTriggerEvent(event)
    self.event = event
end

function Button:setColors(colorA, colorB)
    self.colorA, self.colorB = colorA, colorB
end

function Button:setBackgroundColor(bgColor)
    self.background = bgColor
end

function Button:toggleVisibility()
    self.visible = not self.visible
end