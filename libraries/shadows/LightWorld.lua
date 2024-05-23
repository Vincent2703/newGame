module("libraries.shadows.LightWorld", package.seeall)

Object = require("libraries.shadows.Object")

Shadows				=		require("libraries.shadows")
Body					=		require("libraries.shadows.Body")
BodyTransform		=		require("libraries.shadows.BodyTransform")
PriorityQueue		=		require("libraries.shadows.PriorityQueue")

LightWorld = setmetatable( {}, Object )
LightWorld.__index = LightWorld
LightWorld.__type = "LightWorld"

LightWorld.R, LightWorld.G, LightWorld.B, LightWorld.A = 0, 0, 0, 255
LightWorld.x, LightWorld.y, LightWorld.z = 0, 0, 1

function LightWorld:new()
	
	local self = setmetatable( {}, LightWorld )
	local Width, Height = love.graphics.getDimensions()
	
	self.Canvas = love.graphics.newCanvas(Width, Height)
	self.Width = Width
	self.Height = Height
	self.BorderRadius = math.sqrt( Width * Width + Height * Height ) * 0.5
	
	self.Bodies = PriorityQueue:new()	-- Bodies sorted by height
	
	self.BodyTracks = {}
	self.Rooms = {}
	self.Lights = {}
	self.Stars = {}
	self.Changed = true
	
	return self
	
end

function LightWorld:Resize(Width, Height)
	
	self.Canvas = love.graphics.newCanvas(Width, Height)
	self.Width = Width
	self.Height = Height
	self.BorderRadius = math.sqrt( Width * Width + Height * Height ) * 0.5
	
	self.UpdateCanvas = true
	
	for Index, Light in pairs(self.Stars) do
		
		Light:Resize(Width, Height)
		
	end
	
end

function LightWorld:InitFromPhysics(PhysicsWorld)
	
	for _, BodyObject in pairs( PhysicsWorld:getBodies() ) do
		
		Body:new(self):InitFromPhysics(BodyObject)
		
	end
	
end

function LightWorld:GetBorderRadius()
	
	return self.BorderRadius
	
end

function LightWorld:GetWidth()
	
	return self.Width
	
end

function LightWorld:GetHeight()
	
	return self.Height
	
end

function LightWorld:AddBody(Body)
	
	Body.World = self
	
	self.Changed = true
	self.UpdateCanvas = true
	self.Bodies:Insert(Body)
	
end

function LightWorld:AddLight(Light)
	
	local ID = #self.Lights + 1
	Light:SetWorld(self)
	Light.ID = ID
	
	self.UpdateCanvas = true
	self.Lights[ID] = Light
	
	return Light
	
end

function LightWorld:AddStar(Star)
	
	local ID = #self.Stars + 1
	Star:SetWorld(self)
	Star.ID = ID
	
	self.UpdateCanvas = true
	self.Stars[ID] = Star
	
	return Star
	
end

function LightWorld:AddRoom(Room)
	
	local ID = #self.Rooms + 1
	Room.World = self
	Room.ID = Room
	
	self.UpdateCanvas = true
	self.Rooms[ID] = Room
	
	return Room
	
end

function LightWorld:TrackBody(Body)
	
	local Transform = BodyTransform:new(Body)
	local ID = #self.BodyTracks + 1
	Transform.World = self
	Transform.TransformID = ID
	
	self.BodyTracks[ID] = Transform
	
	return Transform
	
end

function LightWorld:Draw()
	
	love.graphics.origin()
	love.graphics.setBlendMode("multiply", "premultiplied")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.Canvas, 0, 0)
	love.graphics.setBlendMode("alpha", "alphamultiply")
	
end

function LightWorld:SetColor(R, G, B, A)
	
	if R ~= self.R then
		
		self.R = R
		self.UpdateCanvas = true
		
	end
	
	if G ~= self.G then
		
		self.G = G
		self.UpdateCanvas = true
		
	end
	
	if B ~= self.B then
		
		self.B = B
		self.UpdateCanvas = true
		
	end
	
	if A ~= self.A then
		
		self.A = A
		self.UpdateCanvas = true
		
	end
	
end

function LightWorld:GetColor()
	
	return self.R, self.G, self.A, self.B
	
end

function LightWorld:SetPosition(x, y, z)
	
	if x ~= self.x then
		
		self.x = x
		self.UpdateCanvas = true
		self.UpdateStars = true
		
	end
	
	if y ~= self.y then
		
		self.y = y
		self.UpdateCanvas = true
		self.UpdateStars = true
		
	end
	
	if z then
		
		if z ~= self.z then
			
			self.z = z
			self.UpdateCanvas = true
			self.UpdateStars = true
			
		end
		
	end
	
end

function LightWorld:GetPosition()
	
	return self.x, self.y, self.z
	
end

function LightWorld:Update(dt)
	
	for Index, Body in pairs(self.Bodies:GetArray()) do
		
		Body:Update()
		
	end
	
	for Index, Transform in pairs(self.BodyTracks) do
		
		Transform:Update()
		
	end
	
	for Index, Light in pairs(self.Lights) do
		
		Light:Update()
		
	end; love.graphics.setCanvas()
	
	for Index, Star in pairs(self.Stars) do
		
		Star:Update()
		
	end; love.graphics.setCanvas()
	
	for Index, Room in pairs(self.Rooms) do
		
		Room:Update()
		
	end; love.graphics.setCanvas()
	
	self.Changed = false
	
	if self.UpdateCanvas then
		
		libraries.shadowsinsertionSort(self.Bodies:GetArray())
		
		self.UpdateCanvas = nil
		self.UpdateStars = nil
		
		love.graphics.setCanvas(self.Canvas)
		love.graphics.setShader()
		love.graphics.setBlendMode("alpha", "alphamultiply")
		love.graphics.clear(self.R / 255, self.G / 255, self.B / 255, self.A / 255)
		
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setBlendMode("add", "alphamultiply")
		love.graphics.origin()
		love.graphics.scale(1, 1)
		
		for _, Light in pairs(self.Stars) do
			
			if not Light:GetCanvasDestroyed() then
				love.graphics.draw(Light.Canvas, 0, 0)
			end
			
		end
		
		love.graphics.translate(-self.x * self.z, -self.y * self.z)
		love.graphics.scale(self.z, self.z)
		love.graphics.setShader(libraries.shadowsDarkenShader)
		love.graphics.setBlendMode("alpha", "alphamultiply")
		
		for _, Room in pairs(self.Rooms) do
			
			Room:Draw()
			
		end
		
		love.graphics.setShader()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setBlendMode("add", "alphamultiply")
		
		love.graphics.origin()
		love.graphics.translate(-self.x * self.z, -self.y * self.z)
		love.graphics.scale(self.z, self.z)
		
		for _, Light in pairs(self.Lights) do
			
			if not Light:GetCanvasDestroyed() then
				
				local x, y = Light:GetPosition()
				
				love.graphics.draw(Light.Canvas, x - Light.Radius, y - Light.Radius)
				
			end
			
		end
		
		love.graphics.setBlendMode("alpha", "alphamultiply")
		love.graphics.origin()
		
		for i = 1, self.Bodies:GetLength() do
			
			local Body = self.Bodies:Get(i)
			local Shapes = Body:GetShapes()
			
			Body:SetChanged(false)
			
			for j = 1, Shapes:GetLength() do
				
				Shapes:Get(j):SetChanged(false)
				
			end
			
		end
		
	end
	
	love.graphics.setCanvas()
	love.graphics.setShader()
	
end

function LightWorld:DrawShadows(Light)

end

function LightWorld:DrawSprites(Light)	
	--CUSTOM

	if Light.displayWalls and Light.player then --check if visible
		local memoizedCosSin = lume.memoize(function(angle) -- TODO : Dans utils
			return math.cos(math.rad(angle)), math.sin(math.rad(angle))
		end)

		local player = Light.player
		local x1, y1, _ = Light:GetPosition()
		local angle = Light:GetAngle()
		local minAngle, maxAngle = angle-270, angle-90 --180 angle
		local radius = Light.Radius

		local angleIncrement = 0.5

		local displayedWalls = {}

		for angle=minAngle, maxAngle, angleIncrement do
			local dx, dy = memoizedCosSin(angle)
			local x2, y2 = x1 + dx*radius, y1 + dy*radius
		
			local itemsSegment, len = GameState:getState("InGame").map.bumpWorld:querySegmentWithCoords(x1, y1, x2, y2, function(item) return item.obstacle end)

			if len > 0 and itemsSegment[1].ti1 <= 0.8 then
				table.insert(displayedWalls, itemsSegment[1].item)
			end
		end

		displayedWalls = lume.unique(displayedWalls)

		for _, wall in ipairs(displayedWalls) do
			if wall.w < wall.h then
				love.graphics.rectangle("fill", wall.x+1, wall.y+1, wall.w-1, wall.h-1)
			else
				love.graphics.rectangle("fill", wall.x+1, wall.y-TILESIZE+wall.h+2, wall.w, TILESIZE-2)
			end
		end
	end
end

function LightWorld:ForceUpdate()
	
	self.Changed = true
	
end

return LightWorld