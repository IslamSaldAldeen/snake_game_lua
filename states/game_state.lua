local Input = require("input")
local SnakeGame = require("snake_game")
local Events = require("events")

local Game = {}
Game.__index = Game

function Game:enter()
    self.game = SnakeGame:new()

    -- Example subscription to bonus Events system
    Events:subscribe("food_eaten", function(data)
        print("Score increased to:", data.score)
    end)

    -- Command pattern input
    self.input = Input:new()
    self.input:bind("up",    function() self:changeDirection(0, -1) end)
    self.input:bind("down",  function() self:changeDirection(0,  1) end)
    self.input:bind("left",  function() self:changeDirection(-1, 0) end)
    self.input:bind("right", function() self:changeDirection( 1,  0) end)
    self.input:bind("escape", function() love.event.quit() end)
end

function Game:leave()
    -- allow GC
    self.game = nil
    self.input = nil
end

function Game:update(dt)
    self.game:update(dt)
end

function Game:draw()
    self.game:draw()
end

function Game:keypressed(key, switch)
    if key == "return" or key == "kpenter" then
        -- Return to menu after game over
        if self.game.gameOver then
            switch("menu")
            return
        end
    end
    if self.input then self.input:handleKey(key) end
end

function Game:changeDirection(dx, dy)
    self.game:changeDirection(dx, dy)
end

-- expose to main.lua direct arrow handling
setmetatable(Game, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        if self.enter then self:enter(...) end
        return self
    end
})

return setmetatable({}, Game)
