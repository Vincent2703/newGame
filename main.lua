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

    GameState = GameState()
    GameState:setState("Home")

    if DEBUG then
        debug = Debug()
    end
    
end

function love.update(dt)
    input:update() --move to keypressed/mousemoved ?
    GameState:update(dt)
    if server then
        server:update(dt)
    end
    if client then
        client:update(dt)
    end
    if DEBUG then
        debug:update()
    end
end

function love.draw()
    GameState:draw()

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
    bitser = require("libraries/bitser/bitser")
    sock = require("libraries/sock/sock")

    Shadows = require("libraries/shadows")
    LightWorld = require("libraries/shadows/LightWorld")
    Light = require("libraries/shadows/Light")
    Body = require("libraries/shadows/Body")
    PolygonShadow = require("libraries/shadows/ShadowShapes/PolygonShadow")
end

function loadClasses()
    require("classes/Utils")
    require("classes/Input")

    require("classes/GUI/Button")
    require("classes/GUI/ButtonSubclasses/RectangleButton")
    require("classes/GUI/InventoryGUI")
    require("classes/GUI/BodyStatusGUI")
    require("classes/GUI/Interface")

    require("classes/Network/Client")
    require("classes/Network/Server")
    
    require("classes/Inventory")

    require("classes/Item")
    require("classes/Items/Consumable")

    require("classes/Player")
    require("classes/Map")

    require("classes/GameState")
    require("classes/States/Home")
    require("classes/States/InGame")

    if DEBUG then
        require("classes/Debug")
    end
end

function initScreen()
    widthWindow, heightWindow = love.graphics.getDimensions()
    halfWidthWindow, halfHeightWindow = widthWindow/2, heightWindow/2
    love.graphics.setDefaultFilter("nearest", "nearest")

    zoom = 5

end