function love.load()
    cellSize = 12
    c1 = math.random()/2
    c2 = math.random()/2
    c3 = math.random()
    timer = 0
    level = 1
    timerLimit = 0.1
    bumpblink = 0
    lives = 3
    calorie = 1000
    max_hp = 10000
    love.graphics.setBackgroundColor(25/255, 30/255, 35/255)
    gridXCount = math.floor(love.graphics.getWidth()/cellSize + 0.5)
    gridYCount = math.floor(love.graphics.getHeight()/cellSize + 0.5)
    --------------------------------------

    -- Grid Class
    Grid = {}
    Grid.__index = Grid
    function Grid:reset()
        grid = {}
        for y = 1, gridYCount do
            grid[y] = {}
            for x = 1, gridXCount do
                grid[y][x] = false
            end
        end
        local this =
        {
            grid = grid
        }
        setmetatable(this, Grid)
        return this
    end

    -- Draw Grid
    function Grid:Animate()

        -- Grid Background
        for y = 1, gridYCount do
            for x = 1, gridXCount do
                local cellDrawSize = cellSize - 1
                if self.grid[y][x] then
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

    end



    -- Maybe need random names in future
    function RandomVariable(length)
    	local res = ""
    	for i = 1, length do
    		res = res .. string.char(math.random(97, 122))
    	end
    	return res
    end

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
            rot_limit = math.floor(100 * math.random() + 100 / level),
            c1 = 1,
            c2 = 0,
            c3 = 0,
            x = nil,
            y = nil,
        }
        setmetatable(this, Apple)
        return this
    end

    -- Apple Spawning
    function Apple:Move()
        local possibleFoodPositions = {}
        for foodX = 1, gridXCount do
            for foodY = 1, gridYCount do
                local possible = true
                --for segmentIndex, segment in ipairs(player1.snakeSegments) do
                --    if foodX == segment.x and foodY == segment.y then
                --        possible = false
                --    end
                --end
                --if grid[foodY][foodX] then
                --    possible = false
                --end
                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end
            end
        end
        pos = possibleFoodPositions[love.math.random(1, #possibleFoodPositions)]
        self.x = pos.x
        self.y = pos.y
    end

    -- Draw Apple
    function Apple:Animate()
        love.graphics.setColor(self.c1, self.c2, self.c3)
        drawCell(self.x,self.y)
    end

    -- Apple Decomposing
    function Apple:Decompose()
        self.rot = self.rot + 1
        self.c1 = 1 - self.rot/self.rot_limit/3
        self.c2 = self.rot/self.rot_limit/2
        self.c3 = self.rot/self.rot_limit/2
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
            stay_count = 0,
            alive = true,
            unstuck = true,
            name = RandomVariable(9),
            c1 = .5 + math.random()/2,
            c2 = .5 + math.random()/2,
            c3 = .5 + math.random()/2,
        }
        setmetatable(this, Derpy)
        return this
    end

    -- Animate Derpy
    function Derpy:Animate()
        for segmentIndex, segment in ipairs(self.snakeSegments) do
            if player1.alive then
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
        if self.unstuck == true then
            if #self.directionQueue > 1 then
                table.remove(self.directionQueue, 1)
            end

            local stay = false
            local nextXPosition = self.snakeSegments[1].x
            local nextYPosition = self.snakeSegments[1].y

            local choices = {1,2,3,4}
            local choice = math.random(1,#choices)
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

            if pcall(function() local a = grid1[nextYPosition][nextXPosition] end) then
             --do this as the table was valid

                if stay == false and nextXPosition ~= nil and nextYPosition ~= nil then
                    table.insert(self.snakeSegments, 1, {x = nextXPosition, y = nextYPosition})

                    if nextXPosition ~= nil and nextYPosition ~= nil then
                        if grid1[nextYPosition][nextXPosition] == true then
                            grid1[nextYPosition][nextXPosition] = false
                        else
                            table.remove(self.snakeSegments)
                        end
                    end
                    self.stay_count = 0
                else
                    self.stay_count = self.stay_count + 1
                end

            else
                love.window.setTitle("Error")
            end
        end

        if self.stay_count > 40 then
            self.unstuck = false
            self.stay_count = self.stay_count + 1
        end

        -- Derpy Explodes, Change Mold Color, +Level, Spawn Babies, Speedup
        if self.stay_count > 80 and self.unstuck == false then
            c1 = math.random()/2
            c2 = math.random()/2
            c3 = math.random()
            level = level + 1
            timerLimit = timerLimit * 0.98

            barrel[#barrel].rot = barrel[#barrel].rot_limit

            love.window.setTitle("Level " .. level)
            for segmentIndex, segment in ipairs(self.snakeSegments) do
                grid1[segment.y][segment.x] = true
            end

            self.snakeSegments = {
                {x = self.snakeSegments[1].x, y = self.snakeSegments[1].y},
                {x = self.snakeSegments[1].x, y = self.snakeSegments[1].y},
                {x = self.snakeSegments[1].x, y = self.snakeSegments[1].y},
            }
            self.directionQueue = {'left'}
            self.stay_count = 0
            self.alive = true
            self.unstuck = true
            self.name = RandomVariable(9)
            self.c1 = (self.snakeSegments[1].x/gridXCount)
            self.c2 = .5 + math.random()/2
            self.c3 = (self.snakeSegments[1].y/gridYCount)

            table.insert(brood, Derpy:Create(self.snakeSegments[1].x,self.snakeSegments[1].y))
        end
    end

    -- Player Class
    Player = {}
    Player.__index = Player
    function Player:reset()
        local this =
        {
            snakeSegments = {
                {x = 3, y = 1},
                {x = 2, y = 1},
                {x = 1, y = 1},
            },
            directionQueue = {'right'},
            alive = true,
            timer = 0,
            timerLimit = timerLimit * 0.98,
            health = max_hp,
            lives = 3,
        }
        setmetatable(this, Player)
        return this
    end

    function killem()
        for k,v in pairs(brood) do
            for segmentIndex, segment in ipairs(v.snakeSegments) do
                grid1[segment.y][segment.x] = true
            end
        end
        brood = {}
        table.insert(brood,Derpy:Create(gridXCount,gridYCount))
    end

    -- First Reset
    player1 = Player:reset()
    grid1 = Grid:reset().grid
    grid2 = Grid:reset().grid

    barrel = {}
    table.insert(barrel, Apple:Create())
    barrel[#barrel]:Move()

    brood = {}
    table.insert(brood,Derpy:Create(gridXCount,gridYCount))
    love.window.setTitle("Level " .. level)

end

function love.update(dt)

    timer = timer + dt
    bumpblink = bumpblink - dt

    if player1.alive then

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
                            and grid1[y + dy]
                            and grid1[y + dy][x + dx] then
                                neighbors = neighbors + 1
                            end
                        end
                    end
                    nextGrid[y][x] = neighbors == 3 or (grid1[y][x] and neighbors == 2)
                    if grid1[y][x] == 1 and grid2[y][x] == 1 then
                        nextGrid[y][x] = 0
                    end
                end
            end
            grid1 = nextGrid

            -- Conway Rules
            local nextGrid2 = {}
            for y = 1, gridYCount do
                nextGrid2[y] = {}
                for x = 1, gridXCount do
                    local neighbors = 0
                    for dy = -1, 1 do
                        for dx = -1, 1 do
                            if not (dy == 0 and dx == 0)
                            and grid2[y + dy]
                            and grid2[y + dy][x + dx] then
                                neighbors = neighbors + 1
                            end
                        end
                    end
                    nextGrid2[y][x] = neighbors == 3 or (grid2[y][x] and neighbors == 2)
                    if grid1[y][x] == 1 and grid2[y][x] == 1 then
                        nextGrid2[y][x] = 0
                    end
                end
            end
            grid2 = nextGrid2

            -- Player Movement
            if #player1.directionQueue > 1 then
                table.remove(player1.directionQueue, 1)
            end

            local nextXPosition = player1.snakeSegments[1].x
            local nextYPosition = player1.snakeSegments[1].y

            if player1.directionQueue[1] == 'right' then
                nextXPosition = nextXPosition + 1
                if nextXPosition > gridXCount then
                    nextXPosition = 1
                end
            elseif player1.directionQueue[1] == 'left' then
                nextXPosition = nextXPosition - 1
                if nextXPosition < 1 then
                    nextXPosition = gridXCount
                end
            elseif player1.directionQueue[1] == 'down' then
                nextYPosition = nextYPosition + 1
                if nextYPosition > gridYCount then
                    nextYPosition = 1
                end
            elseif player1.directionQueue[1] == 'up' then
                nextYPosition = nextYPosition - 1
                if nextYPosition < 1 then
                    nextYPosition = gridYCount
                end
            end

            -- Player
            local canMove = true

            -- Bump Self
            for segmentIndex, segment in ipairs(player1.snakeSegments) do
                if segmentIndex ~= #player1.snakeSegments
                and nextXPosition == segment.x
                and nextYPosition == segment.y then
                    canMove = false
                    bumpblink = 3
                    table.remove(player1.snakeSegments)
                end
            end

            -- Bump Mold
            if grid1[nextYPosition][nextXPosition] == true then
                canMove = false
                bumpblink = .5
                table.remove(player1.snakeSegments)
            end

            -- Safe: Eat or Move
            if canMove then
                local ate = false
                table.insert(player1.snakeSegments, 1, {x = nextXPosition, y = nextYPosition})

                for ind, i in ipairs(barrel) do
                    if player1.snakeSegments[1].x == i.x
                    and player1.snakeSegments[1].y == i.y then
                        for segmentIndex, segment in ipairs(player1.snakeSegments) do
                            grid1[segment.y][segment.x] = true
                        end
                        table.remove(barrel, #barrel)
                        table.insert(barrel, Apple:Create())
                        barrel[#barrel]:Move()
                        ate = true
                        player1.health = player1.health + calorie
                    end
                end
                if ate == false then
                    table.remove(player1.snakeSegments)
                end
            elseif #player1.snakeSegments > 3 then
                grid1[nextYPosition][nextXPosition] = false
            else
                player1.alive = false
                bumpblink = 0
            end

            -- Derpy Brood Move
            for k,i in pairs(brood) do
                i:Move()
            end

            -- Rotting
            if barrel[#barrel].rot < barrel[#barrel].rot_limit then
                barrel[#barrel]:Decompose()
            else
                table.remove(barrel, #barrel)
                table.insert(barrel, Apple:Create())
                barrel[#barrel]:Move()
            end

            -- Hunger
            player1.health = player1.health - 1

        end

    elseif timer >= 2 then
        grid1 = Grid.reset().grid
        grid2 = Grid.reset().grid
        player1.reset()
        if player1.lives < 1 then
            player1.lives = 3
            player1.level = 1
            player1.timerLimit = 0.1
            love.window.setTitle("GAME OVER!...  Level " .. level)
            killem()
        else
            lives = lives - 1
            love.window.setTitle("Lives left: " .. lives)
        end
    end
end



function love.draw()

    -- Animate grid
        --grid1:Animate()
        --grid2:Animate()

    -- Animate Derpy Brood
    for k,v in pairs(brood) do
        v:Animate()
    end

    -- Animate Player
    for segmentIndex, segment in ipairs(player1.snakeSegments) do
        if player1.alive then
            if bumpblink > 0 then
                love.graphics.setColor(math.random(), math.random(), math.random())
            else
                love.graphics.setColor(.6, .9, .3)
            end
        else
            love.graphics.setColor(.5, .5, .5)
        end
        drawCell(segment.x, segment.y)
    end

    -- Animate Apples
    for k,v in pairs(barrel) do
        v:Animate()
    end
end



-- Player Controls
function love.keypressed(key)

    if key == 'right'
    and player1.directionQueue[#player1.directionQueue] ~= 'right'
    and player1.directionQueue[#player1.directionQueue] ~= 'left' then
        table.insert(player1.directionQueue, 'right')
    elseif key == 'left'
    and player1.directionQueue[#player1.directionQueue] ~= 'left'
    and player1.directionQueue[#player1.directionQueue] ~= 'right' then
        table.insert(player1.directionQueue, 'left')
    elseif key == 'up'
    and player1.directionQueue[#player1.directionQueue] ~= 'up'
    and player1.directionQueue[#player1.directionQueue] ~= 'down' then
        table.insert(player1.directionQueue, 'up')
    elseif key == 'down'
    and player1.directionQueue[#player1.directionQueue] ~= 'down'
    and player1.directionQueue[#player1.directionQueue] ~= 'up' then
        table.insert(player1.directionQueue, 'down')
    elseif key == 'q' then
        timerLimit = timerLimit + 0.005
    elseif key == 'w' then
        timerLimit = timerLimit - 0.005
    elseif key == 'e' then
        timerLimit = 0.1
    elseif key == 'z' then
        killem()
    elseif key == 'x' then
        for segmentIndex, segment in ipairs(player1.snakeSegments) do
            grid2[segment.y][segment.x] = true
            bumpblink = .5
        end
    end
end
