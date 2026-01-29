local NPC = require("entities.npc")
local Transition = require("entities.events.transition")

local BaseLevel = {}
BaseLevel.__index = BaseLevel

function BaseLevel:new()
    local instance = setmetatable({}, BaseLevel)
    
    -- Спільні налаштування
    instance.platforms = {}
    instance.spikes = {}
    instance.npcs = {}
    instance.events = {}

    instance.boundaries = { width = 2000, top_limit = -1000, bottom_limit = 1000 }
    instance.ground_y = 500
    
    return instance
end

-- === ХЕЛПЕРИ (Щоб не писати table.insert вручну) ===
function BaseLevel:spawnPlatform(x, y, w, h, type)
    table.insert(self.platforms, {x = x, y = y, width = w, height = h, type = type})
end

function BaseLevel:spawnSpike(x, y)
    table.insert(self.spikes, {x = x, y = y, width = 50, height = 50})
end

function BaseLevel:spawnNPC(x, y, dialogue)
    local npc = NPC.new(x, y, dialogue)
    table.insert(self.npcs, npc)
end

function BaseLevel:spawnTransition(x, y, w, h, target_level, to_x, to_y)
    local trans = Transition:new(x, y, w, h, target_level, to_x, to_y)
    table.insert(self.events, trans)
    
end

-- === СПІЛЬНА ЛОГІКА ===
function BaseLevel:update(dt, player, game_ref)
    -- Оновлюємо всіх NPC рівня
    for _, npc in ipairs(self.npcs) do
        npc:update(dt, player)
    end

    for _, event in ipairs(self.events) do
        if event:check_collision(player) then
            event:trigger(game_ref, player)
        end
    end
end

function BaseLevel:draw()
    -- Малюємо землю
    love.graphics.setColor(0, 0.8, 0)
    love.graphics.rectangle("fill", 0, self.ground_y, self.boundaries.width, 200)

    -- Малюємо платформи
    love.graphics.setColor(0, 1, 1)
    for _, p in ipairs(self.platforms) do
        love.graphics.rectangle("fill", p.x, p.y, p.width, p.height)
    end

    -- Малюємо шипи
    love.graphics.setColor(1, 1, 0)
    for _, s in ipairs(self.spikes) do
        -- Твій код малювання шипів з margin
        love.graphics.polygon("fill", 
            s.x, s.y,
            s.x + s.width, s.y,
            s.x + (s.width / 2), s.y - s.height
        )
    end

    -- Малюємо NPC
    for _, npc in ipairs(self.npcs) do
        npc:draw()
    end

    for _, event in ipairs(self.events) do
        event:draw()
    end
end

return BaseLevel