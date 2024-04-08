RectangleButton = Button:extend("RectangleButton")

function RectangleButton:init(x, y, content, callback)
    RectangleButton.super.init(self, x, y, content, callback)
    if self.typeContent == "string" then
        self.textX, self.textY = lume.round(self.x+(self.width-self.widthContent)/2), lume.round(self.y+(self.height-self.heightContent)/2)
    elseif self.typeContent == "Image" then
        --scale img selon width/height
    end

    self.borders = true
    self.rectMode = "line"
end

function RectangleButton:draw()
    if self.background or self.borders then
        if not self.pressed and not self.borders then
            love.graphics.setColor(self.colorA)
        else
            love.graphics.setColor(self.colorB)
        end

        love.graphics.setLineWidth(2)
        love.graphics.rectangle(self.rectMode, self.x, self.y, self.width, self.height)
        love.graphics.setLineWidth(1)
    end
    if self.pressed then
        love.graphics.setColor(self.colorA)
    else
        love.graphics.setColor(self.colorB)
    end
    if self.typeContent == "string" then
        love.graphics.print(self.content, self.textX, self.textY, 0, self.scale)
    elseif self.typeContent == "image" then
        love.graphics.draw(self.content, self.x, self.y)
    end
    love.graphics.setColor(255, 255, 255)
end

function RectangleButton:setBordersStyle(visible, mode)
    self.borders = visible
    self.rectMode = mode
end