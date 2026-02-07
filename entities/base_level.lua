local NPC = require("entities.npc")
local Transition = require("entities.events.transition")
local Collectable = require("entities.collectables")
local Scene = require("entities.events.scene")

local BaseLevel = {}
BaseLevel.__index = BaseLevel

function BaseLevel:new()
    local instance = setmetatable({}, BaseLevel)
    
    instance.platforms = {}
    instance.spikes = {}
    instance.npcs = {}
    instance.events = {}
    instance.collectables = {}
    instance.scenes = {}

    instance.boundaries = { width = 2000, top_limit = -1000, bottom_limit = 1000 }
    instance.ground_y = 500
    
    return instance
end

-- === ХЕЛПЕРИ ===
function BaseLevel:spawnPlatform(name, x, y, w, h, type, target_x, target_y, total_speed)
    local speed_x, speed_y = 0, 0
    
    -- Розрахунок пропорційних швидкостей для діагонального руху
    if type == "moving platform" and target_x and target_y then
        local dx = math.abs(target_x[2] - target_x[1])
        local dy = math.abs(target_y[2] - target_y[1])
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance > 0 then
            speed_x = total_speed * (dx / distance)
            speed_y = total_speed * (dy / distance)
        end
    end

    table.insert(self.platforms, {
        name = name,
        x = x, 
        y = y, 
        width = w, 
        height = h, 
        type = type,
        target_x = target_x or {x, x}, 
        target_y = target_y or {y, y},
        moving_speed = {speed_x, speed_y},
        direction = {true, true} -- true означає шлях до індексу [2], false - до [1]
    })
end

function BaseLevel:spawnSpike(name, x, y, w, h)
    table.insert(self.spikes, {name = name, x = x, y = y, width = w or 50, height = h or 50})
end

function BaseLevel:spawnNPC(name, x, y, dialogue, conf)
    local npc = NPC.new(name, x, y, dialogue, conf or {})
    table.insert(self.npcs, npc)
end

function BaseLevel:spawnTransition(x, y, w, h, target_level, to_x, to_y)
    local trans = Transition:new(x, y, w, h, target_level, to_x, to_y)
    table.insert(self.events, trans)
end

function BaseLevel:spawnCollectable(x, y, width, height, type, value, key_name)
    local collectable = Collectable:new(x, y, width, height, type, value, key_name)
    table.insert(self.collectables, collectable)
end

function BaseLevel:spawnScene(name, x, y, w, h, lvl, queue, trigger)
    local scene = Scene:new(name, x, y, w, h, lvl, queue, trigger)
    table.insert(self.events, scene)
end

-- === СПІЛЬНА ЛОГІКА ===
function BaseLevel:update(dt, player, game_ref)
    -- Оновлення NPC та подій
    for _, npc in ipairs(self.npcs) do npc:update(dt, player) end
    for _, event in ipairs(self.events) do
        event:update(dt, game_ref, player) if event:check_collision(player) then event:trigger(game_ref, player) end
    end

    for _, col in ipairs(self.collectables) do
        -- Додаємо перевірку col.check_collision на існування
        if not col.is_collected and col.check_collision and col:check_collision(player) then
            local p = col:collect()
            if game_ref then
                if col.key_name then
                    game_ref[col.key_name] = p
                else
                    game_ref.score = game_ref.score + p
                    --print("Score: " .. game_ref.score)
                end
            end
        end
    end

    -- Оновлення платформ
    for _, platform in ipairs(self.platforms) do
        if platform.type == "moving platform" then
            local old_x, old_y = platform.x, platform.y
            
            -- Визначаємо ціль
            local target_idx = platform.direction[1] and 2 or 1
            local tx = platform.target_x[target_idx]
            local ty = platform.target_y[target_idx]

            -- Рух по X
            if math.abs(platform.x - tx) > 2 then
                local step_x = (platform.x < tx) and 1 or -1
                platform.x = platform.x + (platform.moving_speed[1] * step_x * dt)
            end

            -- Рух по Y
            if math.abs(platform.y - ty) > 2 then
                local step_y = (platform.y < ty) and 1 or -1
                platform.y = platform.y + (platform.moving_speed[2] * step_y * dt)
            end

            -- Перевірка прибуття (синхронізована)
            if math.abs(platform.x - tx) <= 3 and math.abs(platform.y - ty) <= 3 then
                platform.x, platform.y = tx, ty
                platform.direction[1] = not platform.direction[1]
                platform.direction[2] = not platform.direction[2]
            end

            -- Переміщення гравця
            local dx = platform.x - old_x
            local dy = platform.y - old_y

            if self:isPlayerOnPlatform(player, platform) then
                player.x = player.x + dx
                player.y = player.y + dy
                
                -- Корекція фізики гравця при контакті з рухомою платформою
                if math.abs(dy) > 0 or dx ~= 0 then
                    player.y_velocity = 0
                    player.is_on_ground = true
                end
            end
        end
    end
end

function BaseLevel:tableConcat(t1)
    local tables = {self.platforms, self.spikes, self.npcs, self.events, self.collectables}
    for _, table in ipairs(tables) do
        for i = 1, #table do
            t1[#t1+1] = table[i]
        end
    end
    return t1
end

function BaseLevel:move_along_moving_platform(platform, objects)

    local level_objects = {}
    self:tableConcat(level_objects)

    local target_platform = 0
    for i = 1, #self.platforms do
        if self.platforms[i].name == platform then
            target_platform = i
            break
        end
    end


    for _, obj in ipairs(objects) do
        for _, lvl_obj in ipairs(level_objects) do
            if obj.name == lvl_obj.name then 

                lvl_obj.x = self.platforms[target_platform].x + obj.rx
                lvl_obj.y = self.platforms[target_platform].y + obj.ry
            end
        end
    end
end

function BaseLevel:find_object(name)
    local level_objects = {}
    self:tableConcat(level_objects)
    print(#level_objects)

    for i = 1, #level_objects do
        print(level_objects[i].name)
        if level_objects[i].name == name then
            return level_objects[i]
        end
    end
end

function BaseLevel:isPlayerOnPlatform(player, platform)
    local player_bottom = player.y + player.height
    -- "Липка" перевірка: гравець має бути в межах ширини і трохи вище/всередині верхнього краю
    if (platform.direction[1] == true and player.y_velocity >= 0 and player_bottom <= (platform.y + (platform.moving_speed[2] / player.y_velocity)))
    or (platform.direction[1] == false and player.y_velocity >= 0 and player_bottom <= platform.y) then
        return player.x + player.width > platform.x and 
           player.x < platform.x + platform.width and
           (player.y + player.height) >= platform.y - (platform.moving_speed[2] / 100) + (player.y_velocity / 20) - 4 and
           (player.y + player.height) <= platform.y + (platform.moving_speed[2] / 25)
        
    end
   --[[ return player.y_velocity >= 0 and
           player.x + player.width > platform.x and 
           player.x < platform.x + platform.width and
           (player.y + player.height) >= platform.y - (platform.moving_speed[2] / 100) + (player.y_velocity / 20) - 4 and
           (player.y + player.height) <= platform.y + (platform.moving_speed[2] / 20)
           ]]--
end

function BaseLevel:resetEvents()
    for _, event in ipairs(self.events) do
        event.active = true
    end
end

function BaseLevel:draw()
    -- Земля
    love.graphics.setColor(0, 0.5, 0)
    love.graphics.rectangle("fill", 0, self.ground_y, self.boundaries.width, 200)

    --[[
    -- Траєкторії платформ (візуальні "рейки")
    love.graphics.setLineWidth(1)
    for _, p in ipairs(self.platforms) do
        if p.type == "moving platform" then
            love.graphics.setColor(1, 1, 1, 0.2)
            love.graphics.line(p.target_x[1] + p.width/2, p.target_y[1] + p.height/2, 
                               p.target_x[2] + p.width/2, p.target_y[2] + p.height/2)
        end
    end
    ]]--

    -- Платформи
    for _, p in ipairs(self.platforms) do
        if p.type == "solid" then love.graphics.setColor(0, 1, 1)
        elseif p.type == "platform" then love.graphics.setColor(0, 1, 1)
        else love.graphics.setColor(0, 1, 1) end
        
        love.graphics.rectangle("fill", p.x, p.y, p.width, p.height)
    end

    -- Шипи
    love.graphics.setColor(1, 1, 0)
    for _, s in ipairs(self.spikes) do
        love.graphics.polygon("fill", s.x, s.y, s.x + s.width, s.y, s.x + (s.width / 2), s.y - s.height)
    end

    for _, npc in ipairs(self.npcs) do npc:draw() end
    for _, event in ipairs(self.events) do event:draw() end

    -- Collectables
    for _, col in ipairs(self.collectables) do
        col:draw()
    end
end

return BaseLevel