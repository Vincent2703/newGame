Input = class("Input")

function Input:init()
	self.config = {
					right = "right",
					down = "down",
					up = "up",
					left = "left",
					pause = "escape",
				   }
				   
	self.state = {}
	self.state.changed = false
	self.state.mouse = {
						x = nil, 
						y = nil, 
						}			

	self.state.actions = {
						right = false,
						down = false,
						up = false,
						left = false,
						click = false,
						pause = false,
						newPress = {
							right = false,
							down = false,
                            up = false,
							left = false,
							click = false,
							pause = false
							}
						}
				
	self.prevState = self.state
end

function Input:update()
	self.prevState = lume.clone(self.state)

	-- Mouse
	local mouseX, mouseY = love.mouse.getPosition()
	self.state.mouse = {x=mouseX, y=mouseY}
	
	self.state.actions.click = love.mouse.isDown(1, 2)
	self.state.actions.newPress.click = self.state.actions.click and not self.prevState.actions.click
	
	-- Keyboard
	self.state.actions.right = love.keyboard.isDown(self.config.right)
	self.state.actions.newPress.right = self.state.actions.right and not self.prevState.actions.right
	
	self.state.actions.down = love.keyboard.isDown(self.config.down)
	self.state.actions.newPress.down = self.state.actions.down and not self.prevState.actions.down

	self.state.actions.up = love.keyboard.isDown(self.config.up)
	self.state.actions.newPress.up = self.state.actions.up and not self.prevState.actions.up
	
	self.state.actions.left = love.keyboard.isDown(self.config.left)
	self.state.actions.newPress.left = self.state.actions.left and not self.prevState.actions.left
	
	self.state.actions.pause = love.keyboard.isDown(self.config.pause) or self.phoneBackPressed
	if self.phoneBackPressed then
		self.phoneBackPressed = false
	end
	self.state.actions.newPress.pause = self.state.actions.pause and not self.prevState.actions.pause

	self.state.changed = 
		self.state.actions.click or
		self.state.actions.right or
		self.state.actions.down or
		self.state.actions.up or
		self.state.actions.left or
		self.state.actions.pause or
		self.state.mouse.x ~= self.prevState.mouse.x or
		self.state.mouse.y ~= self.prevState.mouse.y
end