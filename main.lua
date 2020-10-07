-- Main
function love.load()
    love.window.setTitle("BOIDS")
    love.graphics.setBackgroundColor(0, 0, 0)
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    agents = {}
    for i = 1, 100 do
        local face = love.math.random(0, 360)
        local x = love.math.random(0, width)
        local y = love.math.random(0, height)
        local obj = {x=x, y=y, f=face}
        table.insert(agents, obj)
    end
end

function love.update(dt)
    local a = agents[1]
    for i = 1, #agents do
        local a1 = agents[i]
        align(a1)
        separate(a1)
        center(a1)
        wall(a1)
        local dx = math.cos(a1.f * 0.0174533)
        local dy = math.sin(a1.f * 0.0174533)
        a1.x = a1.x + dx * 5
        a1.y = a1.y + dy * 5
    end
end

function love.draw()
    -- love.graphics.setColor(0.9, 0.9, 0.9)
    for i = 1, #agents do
        local agent = agents[i]
        local t1x = math.cos(agent.f * 0.0174533) * 2
        local t1y = math.sin(agent.f * 0.0174533) * 2
        local t2x = math.cos((agent.f + 120) * 0.0174533)
        local t2y = math.sin((agent.f + 120) * 0.0174533)
        local t3x = math.cos((agent.f + 240) * 0.0174533)
        local t3y = math.sin((agent.f + 240) * 0.0174533)
        local r = 4
        love.graphics.polygon("fill",
            agent.x + t1x * r, agent.y + t1y * r,
            agent.x + t2x * r, agent.y + t2y * r,
            agent.x + t3x * r, agent.y + t3y * r)
    end
end

function dist(a1, a2)
    return math.sqrt(
        math.pow(a1.x - a2.x, 2) +
        math.pow(a1.y - a2.y, 2))
end

function align(a1)
    local dx = math.cos(a1.f * 0.0174533)
    local dy = math.sin(a1.f * 0.0174533)
    -- Adjust by this % of average velocity
    local matchingFactor = 0.1
    local visualRange = 75
    local avgDX = 0
    local avgDY = 0
    local numNeighbors = 0
    for i = 1, #agents do
        local a2 = agents[i]
        local dx2 = math.cos(a2.f * 0.0174533)
        local dy2 = math.sin(a2.f * 0.0174533)
        if dist(a1, agents[i]) < visualRange then
            avgDX = avgDX + dx2
            avgDY = avgDY + dy2
            numNeighbors = numNeighbors + 1
        end
    end
    if numNeighbors > 0 then
        avgDX = avgDX / numNeighbors
        avgDY = avgDY / numNeighbors
        dx = dx + (avgDX - dx) * matchingFactor
        dy = dy + (avgDY - dy) * matchingFactor
    end
    a1.f = math.atan2(dy, dx) / 0.0174533
end

function separate(a1)
    local dx = math.cos(a1.f * 0.0174533)
    local dy = math.sin(a1.f * 0.0174533)
    -- The distance to stay away from other boids
    local minDistance = 15
    -- Adjust velocity by this %
    local avoidFactor = 0.05
    local moveX = 0
    local moveY = 0
    for i = 1, #agents do
        if dist(a1, agents[i]) < minDistance then
            moveX = moveX + a1.x - agents[i].x
            moveY = moveY + a1.y - agents[i].y
        end
    end
    dx = dx + moveX * avoidFactor
    dy = dy + moveY * avoidFactor
    a1.f = math.atan2(dy, dx) / 0.0174533
end

function center(a1)
    -- adjust velocity by this %
    local dx = math.cos(a1.f * 0.0174533)
    local dy = math.sin(a1.f * 0.0174533)
    local centeringFactor = 0.003
    local visualRange = 75
    local centerX = 0
    local centerY = 0
    local numNeighbors = 0
    for i = 1, #agents do
        if dist(a1, agents[i]) < visualRange then
            centerX = centerX + agents[i].x
            centerY = centerY + agents[i].y
            numNeighbors = numNeighbors + 1
        end
    end
    if numNeighbors > 0 then
        centerX = centerX / numNeighbors
        centerY = centerY / numNeighbors
        dx = dx + (centerX - a1.x) * centeringFactor
        dy = dy + (centerY - a1.y) * centeringFactor
    end
    a1.f = math.atan2(dy, dx) / 0.0174533
end

function wall(a1)
    local dx = math.cos(a1.f * 0.0174533)
    local dy = math.sin(a1.f * 0.0174533)
    local margin = 200
    local turnFactor = 0.001
    if a1.x < margin then
        dx = dx + turnFactor * (margin - a1.x)
    elseif a1.x > width - margin then
        dx = dx - turnFactor * (a1.x + margin - width)
    end
    if a1.y < margin then
        dy = dy + turnFactor * (margin - a1.y)
    elseif a1.y > height - margin then
        dy = dy - turnFactor * (a1.y + margin - height)
    end
    a1.f = math.atan2(dy, dx) / 0.0174533
end
