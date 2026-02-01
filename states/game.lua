-- states/game.lua
local Game = {}

local Player = require("entities.player")
local Camera = require("entities.camera")
local Level1 = require("levels.level_1") 
local Level2 = require("levels.level_2") 
local Dialogue = require("libraries.dialogue")
local Sounds = require("libraries.sounds")

-- For collectables
Game.loaded_levels = {}
Game.score = 0

function Game.load()
    Dialogue.load()
    local gameFont = love.graphics.newFont(24)
    love.graphics.setFont(gameFont)

    Sounds.load()
    Sounds.library.chillMusic:setVolume(0.1)
    Sounds.library.chillMusic:setLooping(true)
    Sounds.playMusic("chillMusic")

    Game.transition = {
        active = false,      -- is transition active
        state = "none",      -- 'out' if fade out, 'in' if fade in
        alpha = 0,           -- transparency
        speed = 4,         -- speed of transition
        next_level_num = 1,-- num of level where player will be teleported
        next_x = 0,
        next_y = 0
    }

    Game.respawn_point = {x = 0, y = 0}

    local w, h = love.graphics.getDimensions()
    local vertices = {
      -- X, Y,    U, V, R, G, B, A
        {0, 0,    0, 0, 0, 0, 0, 1},
        {w, 0,    1, 0, 0, 0, 0, 1},
        {w, h,    1, 1, 0, 0, 0.2, 1},
        {0, h,    0, 1, 0, 0, 0.2, 1}
    }

    Game.gradientMesh = love.graphics.newMesh(vertices, "fan")

    Game.changeLevelInstant(1, 50, 450)
end

function Game.switchLevel(number, x, y)
    print("Switching to level " .. number)
    print(Game.transition.active)
    if Game.transition.active then return end
    print(Game.transition.active)
    
    Game.transition.active = true
    Game.transition.state = "out"
    Game.transition.next_level_num = number
    Game.transition.next_x = x
    Game.transition.next_y = y
end

function Game.changeLevelInstant(number, x, y)
    Game.levelNumber = number
    print(number)

    if not Game.loaded_levels[number] then
        if number == 1 then
            Game.loaded_levels[number] = Level1.load()
        elseif number == 2 then
            Game.loaded_levels[number] = Level2.load()
        end
        print("First time for level " .. number)
    else
        print("Level " .. number .. " already exists")
    end
    

    Game.current_level = Game.loaded_levels[number]
    Game.current_level:resetEvents()
    
    Player.load(x, Player.y or 450)

    Game.respawn_point = {x = x, y = Player.y}

    print("New respawn point set at " .. string.format("%.0f", x) .. "x, " .. string.format("%.0f", y) .. "y.")
end

function Game.update(dt)    
    -- == TRANSITION LOGIC == --
    if Game.transition.active then

        if Game.transition.state == "out" then
            Game.transition.alpha = Game.transition.alpha + (dt * Game.transition.speed)

            if Game.transition.alpha >= 1 then
                Game.transition.alpha = 1
                Game.changeLevelInstant(
                    Game.transition.next_level_num,
                    Game.transition.next_x,
                    Game.transition.next_y
                )
                Game.transition.state = "in"
            end

        elseif Game.transition.state == "in" then
            Game.transition.alpha = Game.transition.alpha - (dt * Game.transition.speed)

            if Game.transition.alpha <= 0 then
                Game.transition.alpha = 0
                Game.transition.active = false
                Game.transition.state = "none"
            end
        end
            
    end

    if Dialogue.isActive then
        Dialogue.update(dt)
        return
    end

    if not Game.transition.active and Game.transition.alpha < 0.2 then
        Player.update(dt, Game.current_level, Game)
    end
    Game.current_level:update(dt, Player, Game)
    Camera.update(Player, Game.current_level.boundaries)
end

function Game.draw()
    love.graphics.setBackgroundColor(0.2, 0.3, 0.5)

    Camera.set()
    Game.current_level:draw() -- Малює платформи, шипи і NPC
    Player.draw()
    Camera.unset()

    love.graphics.setColor(1, 1, 0)
    love.graphics.print("Score: " .. Game.score, 10, 40)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Coords: " .. string.format("%.0f", Player.x) .. ", " .. string.format("%.0f", Player.y), 10, 0)
    love.graphics.print("Level: " .. (Game.levelNumber or 1), 10, 20)
    
    Dialogue.draw()

    if Game.transition.alpha > 0 then
        love.graphics.setColor(1, 1, 1, Game.transition.alpha)
        love.graphics.draw(Game.gradientMesh, 0, 0)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Game.keypressed(key, scancode)
    -- Перехоплення системних клавіш
    if key == "escape" then love.event.quit() end

    -- Якщо йде завантаження (темний екран), ігноруємо ввід для руху
    if Game.transition.active and Game.transition.alpha > 0.6 then return end   

    if Dialogue.isActive then
        Dialogue.keypressed(key)
        return
    end
    
    -- ПЕРЕДАЄМО ОБИДВА ПАРАМЕТРИ
    Player.keypressed(key, scancode)

    -- Взаємодія через Scancode (працюватиме на будь-якій розкладці)
    if scancode == "z" or key == "return" then
        if Game.current_level and Game.current_level.npcs then
            for _, npc in ipairs(Game.current_level.npcs) do
                if npc.is_player_near then
                    npc:interact()
                    break 
                end
            end
        end
    end
end

function Game.keyreleased(key, scancode)
    -- Обов'язково передаємо в Player, щоб він міг зупинити рух
    Player.keyreleased(key, scancode)
end

-- Те саме виправлення для геймпада
function Game.gamepadpressed(joystick, button)
    if Game.transition.active and Game.transition.alpha > 0.2 then return end
    if Dialogue.isActive then
        if button == "a" then Dialogue.keypressed("space") end
        return
    end

    Player.gamepadpressed(button)

    if button == "start" or button == "y" then
        if Game.current_level and Game.current_level.npcs then
             for _, npc in ipairs(Game.current_level.npcs) do
                if npc.is_player_near then
                    npc:interact()
                    break 
                end
            end
        end
    end
end

return Game