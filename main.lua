function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)

    cellSize = 12

    gridXCount = 67
    gridYCount = 50
    timer = 0

    grid = {}
    for y = 1, gridYCount do
        grid[y] = {}
        for x = 1, gridXCount do
            grid[y][x] = false
        end
    end

    function moveFood()
      local possibleFoodPositions = {}

      for foodX = 1, gridXCount do
          for foodY = 1, gridYCount do
              local possible = true

              for segmentIndex, segment in ipairs(snakeSegments) do
                  if foodX == segment.x and foodY == segment.y then
                      possible = false
                  end
              end

              if possible then
                  table.insert(possibleFoodPositions, {x = foodX, y = foodY})
              end
          end
      end

      foodPosition = possibleFoodPositions[love.math.random(1, #possibleFoodPositions)]
  end

    function reset()
        snakeSegments = {
            {x = 3, y = 1},
            {x = 2, y = 1},
            {x = 1, y = 1},
        }
        directionQueue = {'right'}
        snakeAlive = true
        timer = 0
        moveFood()
    end

    reset()

end

function love.update(dt)
    timer = timer + dt

    if snakeAlive then
        local timerLimit = 0.15
        if timer >= timerLimit then
            timer = timer - timerLimit

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

            local canMove = true

            for segmentIndex, segment in ipairs(snakeSegments) do
                if segmentIndex ~= #snakeSegments
                and nextXPosition == segment.x
                and nextYPosition == segment.y then
                    canMove = false
                end
            end

            if canMove then
                table.insert(snakeSegments, 1, {x = nextXPosition, y = nextYPosition})

                if snakeSegments[1].x == foodPosition.x
                and snakeSegments[1].y == foodPosition.y then
                    for segmentIndex, segment in ipairs(snakeSegments) do
                        grid[segment.y][segment.x] = true
                    end
                    moveFood()

                else
                    table.remove(snakeSegments)
                end
            else
                snakeAlive = false
            end
        end
    elseif timer >= 2 then
        reset()
    end
end

function love.draw()
    for y = 1, 50 do
        for x = 1, 70 do
            local cellDrawSize = cellSize - 1

            if grid[y][x] then
                love.graphics.setColor(1, 0, 1)
            else
                love.graphics.setColor(.86, .86, .86)
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

    local function drawCell(x, y)
        love.graphics.rectangle(
            'fill',
            (x - 1) * cellSize,
            (y - 1) * cellSize,
            cellSize - 1,
            cellSize - 1
        )
    end

    for segmentIndex, segment in ipairs(snakeSegments) do
        if snakeAlive then
            love.graphics.setColor(.6, 1, .32)
        else
            love.graphics.setColor(.5, .5, .5)
        end
        drawCell(segment.x, segment.y)
    end

    love.graphics.setColor(1, .3, .3)
    drawCell(foodPosition.x, foodPosition.y)
end

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
    end
end
