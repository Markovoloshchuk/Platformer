-- states/game.lua
local Game = {}

local Player = require("entities.player")
local Camera = require("entities.camera")
-- Переконайся, що в цих файлах є 'return Level1' і 'return Level2' в кінці!
local Level1 = require("levels.level_1") 
local Level2 = require("levels.level_2") 
local Dialogue = require("libraries.dialogue")

function Game.load()
    Dialogue.load()
    local gameFont = love.graphics.newFont(24)
    love.graphics.setFont(gameFont)
    
    -- Запускаємо гру з 1-го рівня
    Game.switchLevel(1)
end

function Game.switchLevel(number)
    Game.levelNumber = number
    
    if number == 1 then
        Game.current_level = Level1.load()
        Player.load(100, 300) -- Старт для Рівня 1
    elseif number == 2 then
        Game.current_level = Level2.load()
        Player.load(100, 300) -- Старт для Рівня 2
    else
        print("Level " .. number .. " does not exist!")
    end
end

function Game.update(dt)
    if Dialogue.isActive then
        Dialogue.update(dt)
        return
    end

    Player.update(dt, Game.current_level)
    Game.current_level:update(dt, Player)

    Camera.update(Player, Game.current_level.boundaries)
    
    -- Перехід на наступний рівень
    if Player.x > Game.current_level.boundaries.width - 50 then
        Game.switchLevel(Game.levelNumber + 1)
    end
end

function Game.draw()
    love.graphics.setBackgroundColor(0.4, 0.6, 1)

    Camera.set()
        Game.current_level:draw() -- Малює платформи, шипи і NPC
        Player.draw()
    Camera.unset()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Level: " .. (Game.levelNumber or 1), 10, 10)
    
    Dialogue.draw()
end

function Game.keypressed(key)
    if key == "escape" then love.event.quit() end

    if Dialogue.isActive then
        Dialogue.keypressed(key)
        return
    end

    Player.keypressed(key)

    if key == "z" or key == "return" then
        -- !!! ВИПРАВЛЕННЯ ДЛЯ NPC !!!
        -- 1. Шукаємо в Game.current_level.npcs (а не Level.npcs)
        -- 2. Використовуємо правильну назву змінної: is_player_near
        
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

-- Те саме виправлення для геймпада
function Game.gamepadpressed(joystick, button)
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