-- entities/level.lua
local Level = {}

function Level.load()
    Level.boundaries = {
        width = 2000,
        top_limit = -550,
        bottom_limit = 600
    }
    Level.ground_y = 500

    Level.platforms = {}
    Level.spikes = {}

    -- Хелпери
    local function spawnPlatform(x, y, w, h,  type)
        table.insert(Level.platforms, {x = x, y = y, width = w, height = h, type = type})
    end
    local function spawnSpike(x, y)
        table.insert(Level.spikes, {x = x, y = y, width = 50, height = 50})
    end

    -- Будуємо рівень
    spawnSpike(400, 450)
    spawnSpike(600, 450)

    spawnPlatform(150, 350, 150, 150, "solid")
    spawnPlatform(400, 250, 150, 25, "platform")
    spawnPlatform(650, 100, 150, 25, "platform")
    spawnPlatform(400, -50, 150, 25, "platform")
    spawnPlatform(150, -200, 150, 25, "platform")
    spawnPlatform(400, -350, 150, 25, "platform")
end

function Level.draw()
    -- Земля
    love.graphics.setColor(0, 0.8, 0)
    love.graphics.rectangle("fill", 0, Level.ground_y, Level.boundaries.width, 200)

    -- Платформи
    love.graphics.setColor(0, 1, 1)
    for _, p in ipairs(Level.platforms) do
        love.graphics.rectangle("fill", p.x, p.y, p.width, p.height)
    end

    -- Шипи
    love.graphics.setColor(1, 1, 0)
    for _, s in ipairs(Level.spikes) do
        love.graphics.polygon("fill", 
            s.x, s.y + s.height,
            s.x + s.width, s.y + s.height,
            s.x + (s.width / 2), s.y
        )
    end
end

return Level