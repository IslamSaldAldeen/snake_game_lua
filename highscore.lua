-- High score save/load compatible with LÖVE (LuaJIT / Lua 5.1).
-- Manual close; no Lua 5.4 syntax.

local HighScore = {}

function HighScore:save(score)
    local file = io.open("highscore.txt", "w")
    if not file then return end
    local ok = pcall(function()
        file:write(tostring(score or 0))
    end)
    file:close()
end

function HighScore:load()
    local file = io.open("highscore.txt", "r")
    if not file then return 0 end
    local content = file:read("*a")
    file:close()
    return tonumber(content) or 0
end

return HighScore
