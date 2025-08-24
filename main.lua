local GameState = require("gamestate")
local gameState = GameState:new()

function love.load()
    love.window.setTitle("Snake — Lua 5.4 + Modern Patterns")
    math.randomseed(os.time())
end

function love.update(dt)
    gameState:update(dt)
end

function love.draw()
    gameState:draw()
end

function love.keypressed(key)
    -- Let current state handle any key first (menu/game use this)
    if gameState.keypressed then gameState:keypressed(key) end

    -- Arrow keys also work directly (per starter template)
    if gameState.current == "playing" then
        local game = gameState.states.playing
        if key == "up"    then game:changeDirection(0, -1) end
        if key == "down"  then game:changeDirection(0,  1) end
        if key == "left"  then game:changeDirection(-1, 0) end
        if key == "right" then game:changeDirection( 1,  0) end
    end
end
