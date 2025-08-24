local Events = {}
local listeners = {}

function Events:subscribe(event, callback)
    if not listeners[event] then listeners[event] = {} end
    table.insert(listeners[event], callback)
end

function Events:emit(event, data)
    local ls = listeners[event]
    if not ls then return end
    for _, cb in ipairs(ls) do
        cb(data)
    end
end

return Events
