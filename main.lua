cellSize = 12
c1 = 1
c2 = 1
c3 = 1
timer = 0
grid = {}
level = 1
rot = 0
rot_limit = 5000
timerLimit = 0.1

gridXCount = math.floor(love.graphics.getWidth()/cellSize + 0.5)
gridYCount = math.floor(love.graphics.getHeight()/cellSize + 0.5)
love.graphics.setBackgroundColor(25/255, 30/255, 35/255)

brood = {}
barrel = {}
baby_key = 1
dead_babies = {}
apple_key = 1
eaten_apples = {}

-- Cell Drawing Function
function drawCell(x, y)
    love.graphics.rectangle(
        'fill',
        (x - 1) * cellSize,
        (y - 1) * cellSize,
        cellSize - 1,
        cellSize - 1
    )
end

-- Apple Class
Apple = {}
Apple.__index = Apple
function Apple:Create()
    local this =
    {
        rot = 0,
        rot_limit = math.floor(100*math.random() + 100/level),
        c1 = 1,
        c2 = rot/rot_limit,
        c3 = 0,
        x = nil,
        y =nil,
    }
    apple_key = apple_key + 1
    setmetatable(this, Apple)
    return this
end

-- Apple Spawning
function Apple:Move()
    local possibleFoodPositions = {}
    for foodX = 1, gridXCount do
        for foodY = 1, gridYCount do
            local possible = true
            for segmentIndex, segment in ipairs(snakeSegments) do
                if foodX == segment.x and foodY == segment.y then
                    possible = false
                end
            end
            if grid[foodY][foodX] then
                possible = false
            end
            if possible then
                table.insert(possibleFoodPositions, {x = foodX, y = foodY})
            end
        end
    end
    pos = possibleFoodPositions[love.math.random(1, #possibleFoodPositions)]
    self.x = pos.x
    self.y = pos.y
end

-- Apple Animation
function Apple:Animate()
    -- Draw Apple
    love.graphics.setColor(self.c1, self.c2, self.c3)
    drawCell(self.x,self.y)
end

-- Apple Decomposing
function Apple:Decompose()
    self.rot = self.rot + 1
end

-- Derpy Class
Derpy = {}
Derpy.__index = Derpy
function Derpy:Create(xo,yo)
    local this =
    {
        snakeSegments = {
            {x = xo - 3, y = yo - 1},
            {x = xo - 2, y = yo - 1},
            {x = xo - 1, y = yo - 1},
        },
        directionQueue = {'left'},
        snakeAlive = true,
        stay_count = 1,
        name = baby_key,
        c1 = (snakeSegments[1].x/gridXCount),
        c2 = .5 + math.random()/2,
        c3 = (snakeSegments[1].y/gridYCount),
    }
    baby_key = baby_key + 1
    setmetatable(this, Derpy)
    return this
end

-- Animate Derpy
function Derpy:Animate()
    for segmentIndex, segment in ipairs(self.snakeSegments) do
        if snakeAlive then
            if self.stay_count > 30 then
                love.graphics.setColor(math.random(),math.random(),math.random())
            else
                love.graphics.setColor(self.c1, self.c2, self.c3)
            end
        else
            love.graphics.setColor(.5, .5, .5)
        end
        drawCell(segment.x, segment.y)
    end
end

-- Derpy Movement
function Derpy:Move()
    if #self.directionQueue > 1 then
        table.remove(self.directionQueue, 1)
    end

    local stay = false

    local nextXPosition = self.snakeSegments[1].x
    local nextYPosition = self.snakeSegments[1].y

    choices = {1,2,3,4}
    choice = math.random(1,#choices)
    self.directionQueue[1] = choices[choice]

    if self.directionQueue[1] == 1 then
        nextXPosition = nextXPosition + 1
        if nextXPosition > gridXCount then
            nextXPosition = 1
        end
        for segmentIndex, segment in ipairs(self.snakeSegments) do
            if segmentIndex ~= #self.snakeSegments
            and nextXPosition == segment.x
            and nextYPosition == segment.y then
                stay = true
            end
        end
        if stay == true then
            nextXPosition = self.snakeSegments[1].x
        end
    end

    if self.directionQueue[1] == 2 then
        nextXPosition = nextXPosition - 1
        if nextXPosition < 1 then
            nextXPosition = gridXCount
        end
        for segmentIndex, segment in ipairs(self.snakeSegments) do
            if segmentIndex ~= #self.snakeSegments
            and nextXPosition == segment.x
            and nextYPosition == segment.y then
                stay = true
            end
        end
        if stay == true then
            nextXPosition = self.snakeSegments[1].x
        end
    end

    if self.directionQueue[1] == 3 then
        nextYPosition = nextYPosition + 1
        if nextYPosition > gridYCount then
            nextYPosition = 1
        end
        for segmentIndex, segment in ipairs(self.snakeSegments) do
            if segmentIndex ~= #self.snakeSegments
            and nextXPosition == segment.x
            and nextYPosition == segment.y then
                stay = true
            end
        end
        if stay == true then
            nextYPosition = self.snakeSegments[1].y
        end
    end

    if self.directionQueue[1] == 4 then
        nextYPosition = nextYPosition - 1
        if nextYPosition < 1 then
            nextYPosition = gridYCount
        end
        for segmentIndex, segment in ipairs(self.snakeSegments) do
            if segmentIndex ~= #self.snakeSegments
            and nextXPosition == segment.x
            and nextYPosition == segment.y then
                stay = true
            end
        end
        if stay == true then
            nextYPosition = self.snakeSegments[1].y
        end
    end

    -- Derpy Ratking?
    if self.stay_count < 60 then
        if stay == false then
            table.insert(self.snakeSegments, 1, {x = nextXPosition, y = nextYPosition})
            if grid[nextYPosition][nextXPosition] == true then
                grid[nextYPosition][nextXPosition] = false
            else
                table.remove(self.snakeSegments)
            end
            self.stay_count = 1
        else
            self.stay_count = self.stay_count + 1
        end
    else
        -- Derpy Explodes
        self.snakeAlive = false
        c1 = math.random()
        c2 = math.random()
        c3 = math.random()
        self.stay_count = 0
        level = level + 1
        timerLimit = timerLimit * 0.95
        rot_limit = rot_limit * 0.90
        love.window.setTitle("Level " .. level)
        for segmentIndex, segment in ipairs(self.snakeSegments) do
            grid[segment.y][segment.x] = true
        end
        table.insert(brood, Derpy:Create(self.snakeSegments[1].x,self.snakeSegments[1].y))
        table.insert(brood, Derpy:Create(self.snakeSegments[1].x,self.snakeSegments[1].y))
        table.insert(dead_babies, self.name)
    end
end

function love.load()

    -- Clear Conway Board
    for y = 1, gridYCount do
        grid[y] = {}
        for x = 1, gridXCount do
            grid[y][x] = false
        end
    end

    -- Respawn Player
    function reset()
        snakeSegments = {
            {x = 3, y = 1},
            {x = 2, y = 1},
            {x = 1, y = 1},
        }
        directionQueue = {'right'}
        snakeAlive = true
        timer = 0
    end

    -- First Reset
    reset()
    table.insert(barrel, Apple:Create())
    barrel[1]:Move()
    table.insert(brood, Derpy:Create(gridXCount,gridYCount))
end

function love.update(dt)

    timer = timer + dt

    if snakeAlive then

        -- Handle Frames
        if timer >= timerLimit then

            -- Handle Game Speed
            timer = timer - timerLimit

            -- Conway Rules
            local nextGrid = {}
            for y = 1, gridYCount do
                nextGrid[y] = {}
                for x = 1, gridXCount do
                    local neighbors = 0
                    for dy = -1, 1 do
                        for dx = -1, 1 do
                            if not (dy == 0 and dx == 0)
                            and grid[y + dy]
                            and grid[y + dy][x + dx] then
                                neighbors = neighbors + 1
                            end
                        end
                    end
                    nextGrid[y][x] = neighbors == 3 or (grid[y][x] and neighbors == 2)
                end
            end
            grid = nextGrid

            -- Player Movement
            if #directionQueue > 1 then
                table.remove(directionQueue, 1)
            end

            local nextXPosition = snakeSegments[1].x
            local nextYPosition = snakeSegments[1].y

            if directionQueue[1] == 'right' then
                nextXPosition = nextXPosition + 1
                if nextXPosition > gridXCount then
                    nextXPosition = 1
                end
            elseif directionQueue[1] == 'left' then
                nextXPosition = nextXPosition - 1
                if nextXPosition < 1 then
                    nextXPosition = gridXCount
                end
            elseif directionQueue[1] == 'down' then
                nextYPosition = nextYPosition + 1
                if nextYPosition > gridYCount then
                    nextYPosition = 1
                end
            elseif directionQueue[1] == 'up' then
                nextYPosition = nextYPosition - 1
                if nextYPosition < 1 then
                    nextYPosition = gridYCount
                end
            end

            -- Player
            local canMove = true

            -- Bump Self
            for segmentIndex, segment in ipairs(snakeSegments) do
                if segmentIndex ~= #snakeSegments
                and nextXPosition == segment.x
                and nextYPosition == segment.y then
                    canMove = false
                end
            end

            -- Bump Mold
            if grid[nextYPosition][nextXPosition] == true then
                canMove = false
            end

            -- Safe: Eat or Move
            if canMove then
                local ate = false
                table.insert(snakeSegments, 1, {x = nextXPosition, y = nextYPosition})

                for ind, i in ipairs(barrel) do
                    if snakeSegments[1].x == i.x
                    and snakeSegments[1].y == i.y then
                        for segmentIndex, segment in ipairs(snakeSegments) do
                            grid[segment.y][segment.x] = true
                        end
                        table.remove(barrel, #barrel)
                        table.insert(barrel, Apple:Create())
                        barrel[#barrel]:Move()
                        ate = true
                    end
                end
                if ate == false then
                    table.remove(snakeSegments)
                end
            else
                snakeAlive = false
            end

            -- Derpy Brood Move
            for ind,i in ipairs(brood) do
                dead = false
                for jnd,j in ipairs(dead_babies) do
                    if j == ind then
                        dead = true
                    end
                end
                if dead == false then
                    ------------ 216 386 need to fix when lots on board
                    i:Move()
                end
            end

            -- Rotting
            if barrel[#barrel].rot < barrel[#barrel].rot_limit then
                barrel[#barrel]:Decompose()
            else
                table.remove(barrel, #barrel)
                table.insert(barrel, Apple:Create())
                barrel[#barrel]:Move()
            end

        end

    elseif timer >= 2 then
        reset()
        level = 1
        timerLimit = 0.1
        rot_limit = 5000
        love.window.setTitle("Level " .. level)
    end
end

function love.draw()

    -- Grid Background
    for y = 1, gridYCount do
        for x = 1, gridXCount do
            local cellDrawSize = cellSize - 1
            if grid[y][x] then
                love.graphics.setColor(c1, c2, c3)
            else
                love.graphics.setColor(35/255, 40/255, 45/255)
            end
            love.graphics.rectangle(
                'fill',
                (x - 1) * cellSize,
                (y - 1) * cellSize,
                cellDrawSize,
                cellDrawSize
            )
        end
    end

    -- Animate Derpy Brood
    for ind,i in ipairs(brood) do
        dead = false
        for jnd,j in ipairs(dead_babies) do
            if j == ind then
                dead = true
            end
        end
        if dead == false then
            i:Animate()
        end
    end

    -- Animate Player
    for segmentIndex, segment in ipairs(snakeSegments) do
        if snakeAlive then
            love.graphics.setColor(.6, .9, .3)
        else
            love.graphics.setColor(.5, .5, .5)
        end
        drawCell(segment.x, segment.y)
    end

    -- Animate Apples
    for ind,i in ipairs(barrel) do
        rotten = false
        for jnd,j in ipairs(eaten_apples) do
            if j == ind then
                rotten = true
            end
        end
        if rotten == false then
            i:Animate()
        end
    end
end

-- Player Controls
function love.keypressed(key)
    if key == 'right'
    and directionQueue[#directionQueue] ~= 'right'
    and directionQueue[#directionQueue] ~= 'left' then
        table.insert(directionQueue, 'right')
    elseif key == 'left'
    and directionQueue[#directionQueue] ~= 'left'
    and directionQueue[#directionQueue] ~= 'right' then
        table.insert(directionQueue, 'left')
    elseif key == 'up'
    and directionQueue[#directionQueue] ~= 'up'
    and directionQueue[#directionQueue] ~= 'down' then
        table.insert(directionQueue, 'up')
    elseif key == 'down'
    and directionQueue[#directionQueue] ~= 'down'
    and directionQueue[#directionQueue] ~= 'up' then
        table.insert(directionQueue, 'down')
    --elseif key == 'q' then
    --    timerLimit = timerLimit + 0.005
    --elseif key == 'w' then
    --    timerLimit = timerLimit - 0.005
    --elseif key == 'e' then
    --    timerLimit = 0.15
    end
end
