function love.conf(t)
    DEBUG = true
    VERSION = 0.1
	t.window.title = "Multi game "..VERSION
    t.window.vsync = 1

	t.accelerometerjoystick = false		-- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
	t.modules.audio = true              -- Enable the audio module (boolean)
    t.modules.data = true               -- Enable the data module (boolean)
    t.modules.event = true             -- Enable the event module (boolean)
    t.modules.font = true               -- Enable the font module (boolean)
    t.modules.graphics = true           -- Enable the graphics module (boolean)
    t.modules.image = true              -- Enable the image module (boolean)
    t.modules.joystick = true           -- Enable the joystick module (boolean)
    t.modules.keyboard = true           -- Enable the keyboard module (boolean)
    t.modules.math = true               -- Enable the math module (boolean)
    t.modules.mouse = true              -- Enable the mouse module (boolean)
    t.modules.physics = false            -- Enable the physics module (boolean)
    t.modules.sound = true              -- Enable the sound module (boolean)
    t.modules.system = true             -- Enable the system module (boolean)
    t.modules.thread = false             -- Enable the thread module (boolean)
    t.modules.timer = true              -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = false              -- Enable the touch module (boolean)
    t.modules.video = false              -- Enable the video module (boolean)
    t.modules.window = true             -- Enable the window module (boolean)

end
