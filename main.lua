local Shadows = require("shadows")
local LightWorld = require("shadows.LightWorld")
local Light = require("shadows.Light")
local Body = require("shadows.Body")
local PolygonShadow = require("shadows.ShadowShapes.PolygonShadow")
local CircleShadow = require("shadows.ShadowShapes.CircleShadow")
local ImageShadow = require("shadows.ShadowShapes.ImageShadow")
--local newTexture = love.graphics.newImage("water.jpg")
--local newImageShadow = ImageShadow:new(newBody, newTexture)

-- Create a light world
--newLightWorld = LightWorld:new()

-- Create a light on the light world, with radius 300
--newLight = Light:new(newLightWorld, 900)

-- Set the light's color to white
--newLight:SetColor(255, 255, 255, 100)

-- Set the light's position
--newLight:SetPosition(3, 3)


-- Create a body
--newBody = Body:new(newLightWorld)
--newTexture = love.graphics.newImage("water.jpg")
--newImageShadow = ImageShadow:new(newbody, newTexture)

-- Set the body's position and rotation
--newBody:SetPosition(300, 300)
--newBody:SetAngle(-15)

-- Create a polygon shape on the body with the given points
--PolygonShadow:new(newBody, -12, -12, 12, -12, 12, 12, -12, 12)

-- Create a circle shape on the body at (-30, -30) with radius 16
--CircleShadow:new(newBody, -6, -6, 6)

-- Create a second body
--newBody2 = Body:new(newLightWorld)

-- Set the second body's position
--newBody2:SetPosition(350, 350)

-- Add a polygon shape to the second body
--PolygonShape:new(newBody2, -20, -20, 20, -20, 20, 20, -20, 20)

function love.load()
    love.graphics.setBackgroundColor(25/255, 30/255, 35/255)
    cellSize = 12
    gridXCount = 67
    gridYCount = 50
    timer = 0
    grid = {}
    c1 = 1
    c2 = 0
    c3 = 1
    stay_count = 0
    derp_size = 3
    level = 1
    rot = 0

    -- Clear Conway Board
    for y = 1, gridYCount do
        grid[y] = {}
        for x = 1, gridXCount do
            grid[y][x] = false
        end
    end

    -- Handle Apple Spawning
    function moveFood()
      rot = 0
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
      foodPosition = possibleFoodPositions[love.math.random(1, #possibleFoodPositions)]

      -- Set the body's position and rotation
      --newBody:SetPosition(cellSize * foodPosition.x, cellSize * foodPosition.y)

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
        moveFood()
    end

    -- Respawn Derpy
    function reset2()
        snakeSegments2 = {
            {x = gridXCount - 3, y = gridYCount - 1},
            {x = gridXCount - 2, y = gridYCount - 1},
            {x = gridXCount - 1, y = gridYCount - 1},
        }
        directionQueue2 = {'left'}
        snakeAlive2 = true
        derp_size = 3
    end

    -- First Reset
    reset()
    reset2()
end

function love.update(dt)
    timer = timer + dt
    if snakeAlive then

      rot = rot + 1
      if rot > 5000 then
          moveFood()
      end

        -- Handle Frames
        local timerLimit = 0.15
        if timer >= timerLimit then
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

            -- Derpy Movement
            if #directionQueue2 > 1 then
                table.remove(directionQueue2, 1)
            end

            stay = false

            local nextXPosition2 = snakeSegments2[1].x
            local nextYPosition2 = snakeSegments2[1].y

            choices = {1,2,3,4}
            choice = math.random(1,#choices)
            directionQueue2[1] = choices[choice]

            if directionQueue2[1] == 1 then
                nextXPosition2 = nextXPosition2 + 1
                if nextXPosition2 > gridXCount then
                    nextXPosition2 = 1
                end
                for segmentIndex2, segment in ipairs(snakeSegments2) do
                    if segmentIndex2 ~= #snakeSegments2
                    and nextXPosition2 == segment.x
                    and nextYPosition2 == segment.y then
                        stay = true
                    end
                end
                if stay == true then
                    nextXPosition2 = snakeSegments2[1].x
                end
            end

            if directionQueue2[1] == 2 then
                nextXPosition2 = nextXPosition2 - 1
                if nextXPosition2 < 1 then
                    nextXPosition2 = gridXCount
                end
                for segmentIndex2, segment in ipairs(snakeSegments2) do
                    if segmentIndex2 ~= #snakeSegments2
                    and nextXPosition2 == segment.x
                    and nextYPosition2 == segment.y then
                        stay = true
                    end
                end
                if stay == true then
                    nextXPosition2 = snakeSegments2[1].x
                end
            end

            if directionQueue2[1] == 3 then
                nextYPosition2 = nextYPosition2 + 1
                if nextYPosition2 > gridYCount then
                    nextYPosition2 = 1
                end
                for segmentIndex2, segment in ipairs(snakeSegments2) do
                    if segmentIndex2 ~= #snakeSegments2
                    and nextXPosition2 == segment.x
                    and nextYPosition2 == segment.y then
                        stay = true
                    end
                end
                if stay == true then
                    nextYPosition2 = snakeSegments2[1].y
                end
            end

            if directionQueue2[1] == 4 then
                nextYPosition2 = nextYPosition2 - 1
                if nextYPosition2 < 1 then
                    nextYPosition2 = gridYCount
                end
                for segmentIndex2, segment in ipairs(snakeSegments2) do
                    if segmentIndex2 ~= #snakeSegments2
                    and nextXPosition2 == segment.x
                    and nextYPosition2 == segment.y then
                        stay = true
                    end
                end
                if stay == true then
                    nextYPosition2 = snakeSegments2[1].y
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

            -- Bump Derpy
            for segmentIndex2, segment in ipairs(snakeSegments2) do
                if segmentIndex2 ~= #snakeSegments2
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

            -- Derpy
            if stay_count < 30 then
                if stay == false then
                    table.insert(snakeSegments2, 1, {x = nextXPosition2, y = nextYPosition2})

                    if grid[nextYPosition2][nextXPosition2] == true then
                        grid[nextYPosition2][nextXPosition2] = false
                        derp_size = derp_size + 1
                    else
                        table.remove(snakeSegments2)
                    end
                    stay_count = 0
                else
                    stay_count = stay_count + 1
                end
            else
                -- Derpy Explodes
                snakeAlive2 = false
                c1 = math.random()
                c2 = math.random()
                c3 = math.random()
                for segmentIndex2, segment in ipairs(snakeSegments2) do
                    grid[segment.y][segment.x] = true
                end
                stay_count = 0
                reset2()
                level = level + 1
                love.window.setTitle("Level " .. level)
                --newLight:SetColor(math.random(1,255),
                --math.random(1,255),
                --math.random(1,255),
                --math.random(50,120))
            end

        end
    elseif timer >= 2 then
        reset()
        level = 1
        love.window.setTitle("Level " .. level)
    end

    -- Move the light to the mouse position with altitude 1.1
  	--newLight:SetPosition(snakeSegments[1].x * cellSize, snakeSegments[1].y * cellSize, 1.1)

  	-- Recalculate the light world
  	--newLightWorld:Update()


end

-- Grid Background
function love.draw()
    for y = 1, 50 do
        for x = 1, 70 do
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

    local function drawCell(x, y)
        love.graphics.rectangle(
            'fill',
            (x - 1) * cellSize,
            (y - 1) * cellSize,
            cellSize - 1,
            cellSize - 1
        )
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

    -- Animate Derpy
    for segmentIndex2, segment in ipairs(snakeSegments2) do
        if snakeAlive then
            love.graphics.setColor(.3, .6, .5)
        else
            love.graphics.setColor(.5, .5, .5)
        end
        drawCell(segment.x, segment.y)
    end

    -- Draw Apple
    love.graphics.setColor(1, .3, .3)
    drawCell(foodPosition.x, foodPosition.y)

    -- Draw the light world with white color
  	--newLightWorld:Draw()

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
    end
end
