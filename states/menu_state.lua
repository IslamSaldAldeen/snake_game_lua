local Menu = {}
Menu.__index = Menu

function Menu:enter()
    -- Size window to match game board exactly
    local SnakeGame = require("snake_game")
    local w, h = SnakeGame.getPixelSize()
    love.window.setMode(w, h, {resizable=false})
end

function Menu:update(_) end

function Menu:draw()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0.1,0.1,0.12)
    love.graphics.rectangle("fill", 0, 0, w, h)

    love.graphics.setColor(1,1,1)
    love.graphics.printf("SNAKE", 0, h*0.35, w, "center")
    love.graphics.printf("Press Enter to Play", 0, h*0.45, w, "center")
end

function Menu:keypressed(key, switch)
    if key == "return" or key == "kpenter" then
        switch("playing")
    end
end

return setmetatable({}, Menu)
