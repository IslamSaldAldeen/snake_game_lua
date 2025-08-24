local Input = {}
Input.__index = Input

function Input:new()
    local input = { commands = {} }
    return setmetatable(input, Input)
end

function Input:bind(key, command)
    self.commands[key] = command
end

function Input:handleKey(key)
    local command = self.commands[key]
    if command then command() end
end

return Input
