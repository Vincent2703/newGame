Pathfinding = class("Pathfinding")

function Pathfinding:init(widthMap, heightMap, cellSize, cbIsNodeClear)
    self.cellSize = cellSize
    --Create the nodes table
    self.widthMap, self.heightMap = math.floor(widthMap/cellSize), math.floor(heightMap/cellSize)
    self.nodes = {}

    --Grid of nodes availability
    for y=0, self.heightMap do
        local row = {}
        for x=0, self.widthMap do
            row[x] = cbIsNodeClear(x*cellSize, y*cellSize) --Check that the node is clear
        end
        self.nodes[y] = row
    end
end

function Pathfinding:calcCost(node, goal)
    return lume.distance(node.x, node.y, goal.x, goal.y, true)
end

function Pathfinding:getNeighbors(node)
    local neighbors = {}
    local x, y = node.x, node.y

    if x > 0 and self.nodes[y][x-1] then --left
        table.insert(neighbors, {x=x-1, y=y})
    end
    if x < self.widthMap and self.nodes[y][x+1] then --right
        table.insert(neighbors, {x=x+1, y=y})
    end

    if y > 0 then
        if self.nodes[y-1][x] then --top
            table.insert(neighbors, {x=x, y=y-1})
        end
        if self.nodes[y-1][x-1] then --top left
            table.insert(neighbors, {x=x-1, y=y-1})
        end
        if self.nodes[y-1][x+1] then --top right
            table.insert(neighbors, {x=x+1, y=y-1})
        end
    end
    if y < self.heightMap then --bottom
        if self.nodes[y+1][x] then
            table.insert(neighbors, {x=x, y=y+1})
        end
        if self.nodes[y+1][x-1] then --bottom left
            table.insert(neighbors, {x=x-1, y=y+1})
        end
        if self.nodes[y+1][x+1] then --bottom right
            table.insert(neighbors, {x=x+1, y=y+1}) 
        end
    end

    return neighbors
end

function Pathfinding:reconstructPath(cameFrom, current, goalPX)
    local totalPath = { { x = current.x * self.cellSize, y = current.y * self.cellSize } }
    while cameFrom[current] do
        current = cameFrom[current]
        table.insert(totalPath, 1, { x = current.x * self.cellSize, y = current.y * self.cellSize })
    end
    table.remove(totalPath, 1)
    table.remove(totalPath, #totalPath)
    table.insert(totalPath, goalPX)
    return totalPath
end

function Pathfinding:getPath(startPX, goalPX)
    -- Convert pixel coordinates to node coordinates based on cellSize
    local startNode = {x = lume.round(startPX.x / self.cellSize), y = lume.round(startPX.y / self.cellSize)}
    local goalNode = {x = lume.round(goalPX.x / self.cellSize), y = lume.round(goalPX.y / self.cellSize)}

    -- The set of discovered nodes that may need to be (re-)expanded
    local openSet = {startNode}

    -- For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from the start
    local cameFrom = {}

    -- For node n, GScore[n] is the cost of the cheapest path from start to n currently known
    local GScore = {}
    for y = 0, self.heightMap do
        local row = {}
        for x = 0, self.widthMap do
            row[x] = math.huge -- Initialize all nodes with a high value
        end
        GScore[y] = row
    end
    GScore[startNode.y][startNode.x] = 0 -- The cost of the start node is zero

    -- For node n, fScore[n] := gScore[n] + h(n). fScore[n] represents our current best guess as to
    -- how cheap a path could be from start to finish if it goes through n
    local FScore = {}
    for y = 0, self.heightMap do
        local row = {}
        for x = 0, self.widthMap do
            row[x] = math.huge -- Initialize all nodes with a high value
        end
        FScore[y] = row
    end
    FScore[startNode.y][startNode.x] = self:calcCost(startNode, goalNode) -- Estimate the cost from start to goal

    -- While we still have nodes to explore
    while #openSet > 0 do
        local currentNode
        local lowestF = math.huge
        local nodeLowestFCoords = {x = 0, y = 0}

        -- Find the node with the lowest fScore
        for i, node in ipairs(openSet) do
            if FScore[node.y][node.x] < lowestF then
                lowestF = FScore[node.y][node.x]
                currentNode = node
                nodeLowestFCoords = {x = node.x, y = node.y}
            end
        end

        -- If we have reached the goal, reconstruct and return the path
        if currentNode.x == goalNode.x and currentNode.y == goalNode.y then
            return self:reconstructPath(cameFrom, currentNode, goalPX)
        end

        -- Remove currentNode from openSet
        for i, node in ipairs(openSet) do
            if node.x == currentNode.x and node.y == currentNode.y then
                table.remove(openSet, i)
                break
            end
        end

        -- Get neighbors of the current node
        local neighbors = self:getNeighbors(currentNode)

        for _, neighbor in ipairs(neighbors) do
            -- Calculate the tentative gScore for the neighbor
            local tentativeGScore = GScore[currentNode.y][currentNode.x] + 1 -- The cost between the adjacent nodes is always the same

            -- If this path to the neighbor is better than any previous one, record it
            if tentativeGScore < GScore[neighbor.y][neighbor.x] then
                cameFrom[neighbor] = currentNode 

                GScore[neighbor.y][neighbor.x] = tentativeGScore
                FScore[neighbor.y][neighbor.x] = tentativeGScore + self:calcCost(neighbor, goalNode)

                -- If the neighbor is not in the openSet, add it
                local isInOpenSet = false
                for _, node in ipairs(openSet) do
                    if node.x == neighbor.x and node.y == neighbor.y then
                        isInOpenSet = true
                        break
                    end
                end

                if not isInOpenSet then
                    table.insert(openSet, neighbor)
                end
            end
        end
    end

    return false -- No solution found
end
