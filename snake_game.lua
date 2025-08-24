local Entity = require("entity")
local Events = require("events")
local HighScore = require("highscore")

local SnakeGame = {}
SnakeGame.__index = SnakeGame

local CELL = 20        -- pixels per grid cell
local GRID_W = 24      -- grid width  (adjust as you like)
local GRID_H = 18      -- grid height
local MOVE_INTERVAL = 0.12 -- seconds per snake step

local function rect(x, y, size)
    love.graphics.rectangle("fill", x, y, size, size)
end

function SnakeGame:new()
    local game = {
        snake = {},                   -- array of Entity segments (head at index 1)
        direction = {x = 1, y = 0},   -- unit grid direction
        nextDir   = {x = 1, y = 0},   -- buffered direction (prevents double turn in same tick)
        food = {x = 15, y = 10},
        score = 0,
        highScore = HighScore:load(),
        gameOver = false,
        timer = 0
    }

    -- create initial snake: length 3, head at (10,10)
    local startX, startY = 10, 10
    for i = 0, 2 do
        local seg = Entity:new()
            :addComponent("position", Entity.Components.Position(startX - i, startY))
            :addComponent("renderer", Entity.Components.Renderer({0.2, 0.9, 0.2}, CELL))
        table.insert(game.snake, seg)
    end

    return setmetatable(game, SnakeGame)
end

local function positionsSet(snake)
    local s = {}
    for _, seg in ipairs(snake) do
        local p = seg:getComponent("position")
        s[p.x .. ":" .. p.y] = true
    end
    return s
end

function SnakeGame:spawnFood()
    local occupied = positionsSet(self.snake)
    local x, y
    repeat
        x = math.random(0, GRID_W - 1)
        y = math.random(0, GRID_H - 1)
    until not occupied[x .. ":" .. y]
    self.food.x, self.food.y = x, y
end

function SnakeGame:update(dt)
    if self.gameOver then return end
    self.timer = self.timer + dt
    if self.timer < MOVE_INTERVAL then return end
    self.timer = self.timer - MOVE_INTERVAL

    -- finalize buffered direction once per tick
    self.direction.x = self.nextDir.x
    self.direction.y = self.nextDir.y

    -- compute next head cell
    local headPos = self.snake[1]:getComponent("position")
    local newX = headPos.x + self.direction.x
    local newY = headPos.y + self.direction.y

    -- wall collision
    if newX < 0 or newX >= GRID_W or newY < 0 or newY >= GRID_H then
        self:doGameOver()
        return
    end

    -- self collision
    for i = 1, #self.snake do
        local p = self.snake[i]:getComponent("position")
        if p.x == newX and p.y == newY then
            self:doGameOver()
            return
        end
    end

    -- move: add new head
    local newHead = Entity:new()
        :addComponent("position", Entity.Components.Position(newX, newY))
        :addComponent("renderer", Entity.Components.Renderer({0.2, 0.9, 0.2}, CELL))
    table.insert(self.snake, 1, newHead)

    -- food?
    if newX == self.food.x and newY == self.food.y then
        self.score = self.score + 1
        Events:emit("food_eaten", { score = self.score })
        self:spawnFood()  -- keep tail (growth)
    else
        -- remove tail
        table.remove(self.snake, #self.snake)
    end
end

function SnakeGame:doGameOver()
    self.gameOver = true
    if self.score > self.highScore then
        self.highScore = self.score
        HighScore:save(self.highScore)
    end
end

function SnakeGame:draw()
    -- background grid (subtle)
    love.graphics.setColor(0.12, 0.12, 0.12)
    love.graphics.rectangle("fill", 0, 0, GRID_W * CELL, GRID_H * CELL)

    -- draw food
    love.graphics.setColor(0.9, 0.25, 0.25)
    rect(self.food.x * CELL, self.food.y * CELL, CELL)

    -- draw snake
    for i, seg in ipairs(self.snake) do
        local p = seg:getComponent("position")
        if i == 1 then
            love.graphics.setColor(0.1, 0.8, 0.1) -- head a bit darker
        else
            love.graphics.setColor(0.2, 0.9, 0.2)
        end
        rect(p.x * CELL, p.y * CELL, CELL)
    end

    -- HUD
    love.graphics.setColor(1,1,1)
    love.graphics.print(("Score: %d    High: %d"):format(self.score, self.highScore), 8, GRID_H * CELL + 8)

    if self.gameOver then
        local msg = "Game Over! Press Enter to return to Menu"
        love.graphics.printf(msg, 0, (GRID_H * CELL)/2 - 10, GRID_W * CELL, "center")
    end
end

function SnakeGame:changeDirection(dx, dy)
    if self.gameOver then return end
    -- avoid reversing directly into self
    -- disallow exact opposite of current direction
    if (dx == -self.direction.x and dy == -self.direction.y) then
        return
    end
    self.nextDir.x, self.nextDir.y = dx, dy
end

-- Expose grid size for states to size the window nicely
function SnakeGame.getPixelSize()
    return GRID_W * CELL, GRID_H * CELL + 32
end

return SnakeGame
