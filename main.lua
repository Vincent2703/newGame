function love.load()
    OS = love.system.getOS()
    math.randomseed(os.time() .. os.clock()) -- To pick different random values with math.random() at each execution
    TILESIZE = 32

    loadLibraries()
    loadClasses()

    initScreen()

    local font = love.graphics.newFont("assets/fonts/FFFFORWA.ttf", 14)
    love.graphics.setFont(font)

    input = Input()  


    level = Level(25, 19) 
    player = Player(20, 20)

    if DEBUG then
        debug = Debug()
    end
end

function love.update(dt)
    input:update()
    level:update(dt)
    player:update(dt)
    if DEBUG then
        debug:update()
    end
end

function love.draw()
    love.graphics.setCanvas(canvas) --ingame canvas : 
    level:draw()
    love.graphics.setCanvas()
    love.graphics.draw(canvas, -player.x*zoom+halfWidthWindow, -player.y*zoom+halfHeightWindow, 0, zoom)

    if DEBUG then
        debug:draw()
    end
end


function loadLibraries()
    json = require("libraries/json/json")
	anim8 = require("libraries/anim8/anim8")
	class = require("libraries/30log/30log-clean")
	sti = require("libraries/sti")
    bump = require("libraries/bump/bump")
    lume = require("libraries/lume/lume")

    Shadows = require("libraries/shadows")
    LightWorld = require("libraries/shadows/LightWorld")
    Light = require("libraries/shadows/Light")
    Body = require("libraries/shadows/Body")
    PolygonShadow = require("libraries/shadows/ShadowShapes/PolygonShadow")
end

function loadClasses()
    require("classes/Utils")
    require("classes/Input")
    
    require("classes/Player")
    require("classes/Level")

    if DEBUG then
        require("classes/Debug")
    end
end

function initScreen()
    widthWindow, heightWindow = love.graphics.getDimensions()
    halfWidthWindow, halfHeightWindow = widthWindow/2, heightWindow/2
    love.graphics.setDefaultFilter("nearest", "nearest")

    zoom = 5

    canvas = love.graphics.newCanvas()
end