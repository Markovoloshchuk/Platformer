Sounds = require("libraries.sounds")

local Player = {}

function Player.load(x, y)
    Player.x = x
    Player.y = y
    Player.width = 50
    Player.height = 50
    Player.speed = 400

    Player.active_keys = {
        left = love.keyboard.isScancodeDown("a"),
        right = love.keyboard.isScancodeDown("d")
    }


    -- Graphic

    local w = Player.width
    local h = Player.height

    -- Коефіцієнти для ширини "свердл" (щоб зручно міняти)
    local s1_w = w * 0.6  -- Ширина верхньої секції
    local s2_w = w * 0.5  -- Ширина середньої
    local s3_w = w * 0.35 -- Ширина нижньої

    -- Координати Y для стиків (розподіляємо по висоті гравця)
    local y_top = h * 0.1
    local y_s1  = h * 0.4   -- Де закінчується 1-а пружинка
    local y_s2  = h * 0.7   -- Де закінчується 2-а пружинка
    local y_bot = h         -- Де закінчується 3-я (РІВНО НА ЗЕМЛІ)

    local outline = {
        -- === ВЕРХ ГОЛОВИ ===
        0, 0,
        w, 0,
        
        -- === ПРАВЕ СВЕРДЛО (Звужується донизу) ===
        
        -- Секція 1 (Верхня - найширша)
        w,          y_top,
        w + s1_w,   y_top,
        w + s1_w,   y_s1,
        w + s1_w/2, y_s1,   -- "Талія" всередину
        
        -- Секція 2 (Середня - вужча)
        w + s2_w,   y_s1 + 2, -- +2 пікселі для візуального накладання
        w + s2_w,   y_s2,
        w + s2_w/2, y_s2,
        
        -- Секція 3 (Нижня - найвужча, впирається в землю)
        w + s3_w,   y_s2 + 2,
        w + s3_w,   y_bot,    -- <--- Рівно по низу гравця (h)
        w + s3_w/4, y_bot,    -- Гострий кінчик на землі
        
        -- Внутрішня сторона правого свердла (повертаємося до шиї)
        w + s3_w/4, y_s2,     -- Йдемо вгору
        w,          y_s1,     -- З'єднуємо з головою приблизно посередині
        
        -- === НИЗ ОБЛИЧЧЯ ===
        w, h,
        0, h,

        -- === ЛІВЕ СВЕРДЛО (Дзеркально) ===
        
        -- Внутрішня сторона
        0,          y_s1,
        0 - s3_w/4, y_s2,
        
        -- Секція 3 (Нижня)
        0 - s3_w/4, y_bot,
        0 - s3_w,   y_bot,
        0 - s3_w,   y_s2 + 2,
        0 - s2_w/2, y_s2,     -- Талія
        
        -- Секція 2 (Середня)
        0 - s2_w,   y_s2,
        0 - s2_w,   y_s1 + 2,
        0 - s1_w/2, y_s1,     -- Талія
        
        -- Секція 1 (Верхня)
        0 - s1_w,   y_s1,
        0 - s1_w,   y_top,
        0,          y_top
    }

    -- === ТРІАНГУЛЯЦІЯ ===
    local triangles = love.math.triangulate(outline)
    
    local meshVertices = {}
    local r, g, b, a = 1, 0, 0, 1 -- Червоний

    for _, tri in ipairs(triangles) do
        table.insert(meshVertices, {tri[1], tri[2], 0, 0, r, g, b, a})
        table.insert(meshVertices, {tri[3], tri[4], 0, 0, r, g, b, a})
        table.insert(meshVertices, {tri[5], tri[6], 0, 0, r, g, b, a})
    end

    Player.sprite = love.graphics.newMesh(meshVertices, "triangles")

    -- Фізика
    Player.y_velocity = 0
    Player.jump_force = -700
    Player.gravity = 1500
    
    -- Стани
    Player.is_on_ground = false
    
    -- Coyote Time
    Player.coyote_duration = 0.15
    Player.coyote_timer = 0

    Sounds.load()
end

function Player.update(dt, levelData, game_ref)
    -- === 1. INPUT ===
    local input_strength = 0

    if Player.active_keys.right then input_strength = 1 end
    if Player.active_keys.left then input_strength = -1 end

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
        if p.type == "platform" or p.type == "moving platform" then
            local oldY = Player.y - (Player.y_velocity * dt)
            
            -- Ловимо, тільки якщо падаємо і торкаємося верху
            if Player.y_velocity > 0 and (oldY + Player.height) <= p.y + 2 then
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
            local respawn_x = game_ref.respawn_point.x or 50
            local respawn_y = game_ref.respawn_point.y or 450

            print("Player died. Respawn at " .. string.format("%.0f", respawn_x) .. "x, " .. string.format("%.0f", respawn_y) .. "y")

            local random_pitch = love.math.random(0.9, 1.2)
            Sounds.play("damage", 0.8, random_pitch)

            Player.x = respawn_x
            Player.y = respawn_y
            Player.active_keys.left = false
            Player.active_keys.right = false
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
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Player.sprite, Player.x, Player.y)
end

function Player.keypressed(key, scancode)
    -- ДІАГНОСТИКА: покаже, що натиснуто
    -- print("Key: " .. key .. " | Scancode: " .. scancode)

    -- Використовуємо scancode для руху (ігнорує розкладку)
    if scancode == "d" then
        Player.active_keys.right = true
    elseif scancode == "a" then
        Player.active_keys.left = true
    end

    -- Стрибок (можна по key, бо space всюди однаковий)
    if key == "space" and Player.coyote_timer > 0 then
        Player.jump()
        local random_pitch = love.math.random(0.7, 1.0)
        Sounds.play("jump", 0.2, random_pitch)
    end
end

function Player.keyreleased(key, scancode)
    if scancode == "d" then
        Player.active_keys.right = false
    elseif scancode == "a" then
        Player.active_keys.left = false
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