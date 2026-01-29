-- entities/player.lua
local Player = {}

function Player.load(x, y)
    Player.x = x
    Player.y = y
    Player.width = 50
    Player.height = 50
    Player.speed = 400
    
    -- Фізика
    Player.y_velocity = 0
    Player.jump_force = -700
    Player.gravity = 1500
    
    -- Стани
    Player.is_on_ground = false
    
    -- Coyote Time
    Player.coyote_duration = 0.15
    Player.coyote_timer = 0
end

function Player.update(dt, levelData)
    -- === 1. INPUT ===
    local input_strength = 0
    if love.keyboard.isDown("right") then input_strength = 1 end
    if love.keyboard.isDown("left") then input_strength = -1 end

    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        local axisX = joysticks[1]:getGamepadAxis("leftx")
        if math.abs(axisX) > 0.2 then input_strength = axisX end
        if joysticks[1]:isGamepadDown("dpright") then input_strength = 1 end
        if joysticks[1]:isGamepadDown("dpleft") then input_strength = -1 end
    end

    -- === 2. MOVE X ===
    if input_strength > 0 and (Player.x + Player.width) < levelData.boundaries.width then
        Player.x = Player.x + (Player.speed * input_strength * dt)
    elseif input_strength < 0 and Player.x > 0 then
        Player.x = Player.x + (Player.speed * input_strength * dt)
    end

    -- === 3. PHYSICS Y ===
    Player.y_velocity = Player.y_velocity + (Player.gravity * dt)
    Player.y = Player.y + (Player.y_velocity * dt)
    
    -- === 4. COLLISIONS ===
    Player.is_on_ground = false

    -- Земля
    if Player.y > (levelData.ground_y - Player.height) then
        Player.y = levelData.ground_y - Player.height
        Player.y_velocity = 0
        Player.is_on_ground = true
    end

    -- Платформи
for _, p in ipairs(levelData.platforms) do
    -- 1. Перевірка перетину
    if Player.x < p.x + p.width and Player.x + Player.width > p.x and
       Player.y < p.y + p.height and Player.y + Player.height > p.y then
       
        -- ВАРІАНТ А: Це НАСКРІЗНА платформа (One-Way)
        if p.type == "platform" then
            local threshold = 12 -- Допуск трохи більший за швидкість падіння
            local overlapY = (Player.y + Player.height) - p.y
            
            -- Ловимо, тільки якщо падаємо і торкаємося верху
            if Player.y_velocity > 0 and overlapY > 0 and overlapY < threshold then
                Player.y = p.y - Player.height
                Player.y_velocity = 0
                Player.is_on_ground = true
            end

        -- ВАРІАНТ Б: Це ТВЕРДА стіна/блок (Solid)
        elseif p.type == "solid" then
             -- Тут вставляєте той код з minOverlap, який я давав раніше
             -- Він буде виштовхувати і вбік, і вниз (головою об стелю)
             
             local overlapLeft = (Player.x + Player.width) - p.x
             local overlapRight = (p.x + p.width) - Player.x
             local overlapTop = (Player.y + Player.height) - p.y
             local overlapBottom = (p.y + p.height) - Player.y
             
             local minOverlapX = math.min(overlapLeft, overlapRight)
             local minOverlapY = math.min(overlapTop, overlapBottom)

             if minOverlapX < minOverlapY then
                 if overlapLeft < overlapRight then Player.x = p.x - Player.width 
                 else Player.x = p.x + p.width end
                 input_strength = 0
             else
                 if overlapTop < overlapBottom then
                     if Player.y_velocity > 0 then
                        Player.y = p.y - Player.height
                        Player.y_velocity = 0
                        Player.is_on_ground = true
                     end
                 else
                     -- Вдарився головою об низ блоку
                     Player.y = p.y + p.height
                     Player.y_velocity = 0
                 end
             end
        end
    end
end

    -- Шипи (Проста перевірка AABB)
    for _, s in ipairs(levelData.spikes) do
       local margin_x = 15 -- Звужуємо з боків, щоб не вбивало об самі куточки
        local margin_y = 10 -- Зрізаємо верхівку, щоб не вбивало об гострий піксель

        -- Координати хітбокса шипа
        local spike_left   = s.x + margin_x
        local spike_right  = s.x + s.width - margin_x
        local spike_top    = s.y - s.height + margin_y -- Верх (трохи нижче піка)
        local spike_bottom = s.y                       -- Низ (земля)

        -- Перевірка AABB (Axis-Aligned Bounding Box)
        if Player.x < spike_right and
           Player.x + Player.width > spike_left and
           Player.y < spike_bottom and
           Player.y + Player.height > spike_top then
            
            -- Респаун
            Player.x, Player.y = 50, 400
            Player.y_velocity = 0
            
            -- (Опціонально) Ефект тряски екрану або звук
        end
    end

    -- === 5. COYOTE TIME ===
    if Player.is_on_ground then
        Player.coyote_timer = Player.coyote_duration
    else
        Player.coyote_timer = Player.coyote_timer - dt
    end
end

function Player.draw()
    love.graphics.setColor(1, 0, 0) -- Червоний гравець
    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)
end

function Player.keypressed(key)
    if key == "space" and Player.coyote_timer > 0 then
        Player.jump()
    end
end

function Player.gamepadpressed(button)
    if button == "a" and Player.coyote_timer > 0 then
        Player.jump()
    end
end

function Player.jump()
    Player.y_velocity = Player.jump_force
    Player.coyote_timer = 0
end

return Player