local Entity = {}
Entity.__index = Entity

function Entity:new()
    local entity = { components = {} }
    return setmetatable(entity, Entity)
end

function Entity:addComponent(name, component)
    self.components[name] = component
    return self
end

function Entity:getComponent(name)
    return self.components[name]
end

function Entity:hasComponent(name)
    return self.components[name] ~= nil
end

-- Simple components (kept inline to match required structure)
local Components = {}

function Components.Position(x, y)
    return { x = x or 0, y = y or 0 }
end

function Components.Movement(dx, dy)
    return { dx = dx or 0, dy = dy or 0 }
end

function Components.Renderer(color, size)
    return { color = color or {1,1,1}, size = size or 16 }
end

Entity.Components = Components
return Entity
