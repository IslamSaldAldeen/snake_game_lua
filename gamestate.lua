local GameState = {}
GameState.__index = GameState

function GameState:new()
    local state = {
        current = "menu",
        states = {
            menu    = require("states.menu_state"),
            playing = require("states.game_state"),
        }
    }
    -- init states if they provide :enter()
    if state.states.menu.enter then state.states.menu:enter() end
    return setmetatable(state, GameState)
end

function GameState:switch(newState, ...)
    local old = self.current
    if self.states[newState] then
        if self.states[old] and self.states[old].leave then
            self.states[old]:leave()
        end
        self.current = newState
        if self.states[newState].enter then
            self.states[newState]:enter(...)
        end
    end
end

function GameState:update(dt)
    local s = self.states[self.current]
    if s and s.update then s:update(dt) end
end

function GameState:draw()
    local s = self.states[self.current]
    if s and s.draw then s:draw() end
end

function GameState:keypressed(key)
    local s = self.states[self.current]
    if s and s.keypressed then s:keypressed(key, function(nextState, ...)
        self:switch(nextState, ...)
    end) end
end

return GameState
