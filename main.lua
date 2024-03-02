function love.load()
    OS = love.system.getOS()
    math.randomseed(os.time()) -- To pick different random values with math.random() at each execution
    WIDTHRES, HEIGHTRES = 1280, 720

    loadLibraries()
    loadClasses()

    initScreen()

    local font = love.graphics.newFont("assets/fonts/FFFFORWA.ttf", 14)
    love.graphics.setFont(font)

    --input = Input()  

    player = Player()
    lvlTest = Level("assets/maps/test.lua", player)

end

function love.update(dt)
    lvlTest:update(dt)
end

function love.draw()
    lvlTest:draw()
end


function loadLibraries()
    json = require("libraries/json/json")
	anim8 = require("libraries/anim8/anim8")
	class = require("libraries/30log/30log-clean")
	sti = require("libraries/sti")
    bump = require("libraries/bump/bump")
    lightworld = require("libraries/lightworld")
    lume = require("libraries/lume/lume")
end

function loadClasses()
    require("classes/Player")
    require("classes/Level")
end

function initScreen()
    widthWindow, heightWindow = love.graphics.getDimensions()
end