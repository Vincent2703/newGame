Input = class("Input")

function Input:init()
	self.config = {
					right = "d",
					down = "s",
					up = "z",
					left = "q",
					action = "e",
					throw = "t",
					pause = "escape",
					debug = "f1"
				   }
				   
	self.state = {}
	self.state.keyReleased = false
	self.state.updated = false
	self.state.mouse = {
						x = nil, 
						y = nil, 
						wheelmovedDy = 0,
						wheelmovedUp = false,
						wheelmovedDown = false,
						angle = 0
						}			

	self.state.actions = {
						right = false,
						down = false,
						up = false,
						left = false,
						click = false,
						action = false,
						throw = false,
						pause = false,
						debug = false,
						newPress = {
							right = false,
							down = false,
                            up = false,
							left = false,
							click = false,
							pause = false,
							debug = false
							}
						}
				
	self.prevState = self.state
end

function Input:update() --replace input. by self. ?
	input.state.updated = false

	input.prevState = lume.deserialize(lume.serialize(self.state)) --Ensure deep copying (clone() doesn't work)

	-- Mouse
	local mouseX, mouseY = love.mouse.getPosition()
	input.state.mouse.x = mouseX
	input.state.mouse.y = mouseY

	local dy = input.state.mouse.wheelmovedDy or 0
	if dy ~= 0 then
		input.state.updated = true
	end

	input.state.mouse.wheelmovedUp, input.state.mouse.wheelmovedDown = false, false
	if dy > 0 then
		input.state.mouse.wheelmovedUp = true
	elseif dy < 0 then
		input.state.mouse.wheelmovedDown = true
	end
	input.state.mouse.wheelmovedDy = 0 --TODO fix : can't get the value elsewhere

	local oldAngle = input.state.mouse.angle
	input.state.mouse.angle = Utils:calcAngleBetw2Pts(halfWidthWindow, halfHeightWindow, mouseX, mouseY) --Lume function
	if oldAngle ~= input.state.mouse.angle then
		input.state.updated = true
	end

	input.state.actions.click = love.mouse.isDown(1, 2)
	input.state.actions.newPress.click = input.state.actions.click and not input.prevState.actions.click

	if input.state.actions.click then
		input.state.updated = true
	end
	
	-- Keyboard
	for name, action in pairs(input.state.actions) do --filter table
		if name ~= "newPress" and input.config[name] then
			input.state.actions[name] = love.keyboard.isDown(input.config[name])
			if input.state.actions[name] then
				input.state.updated = true
			end
			input.state.actions.newPress[name] = input.state.actions[name] and not input.prevState.actions[name]
		end
	end

	if input.state.keyReleased then
		input.state.updated = true
		input.state.keyReleased = false
	end
end

function love.wheelmoved(dx, dy)
	input.state.mouse.wheelmovedDy = dy
end

function love.keyreleased(key)
	input.state.keyReleased = true
end