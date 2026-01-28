-- states/game.lua
local Game = {}

-- Підключаємо сутності
local Player = require("entities.player")
local Camera = require("entities.camera")
local Level = require("entities.level")
local Dialogue = require("libraries.dialogue")

function Game.load()
    Dialogue.load()
    
    -- Ініціалізуємо рівень (межі, платформи)
    Level.load()
    
    -- Ініціалізуємо гравця (передаємо координати старту)
    Player.load(100, 100)
    
    -- Тексти для діалогу
    Game.dialogueText = {
        "System initiated...",
        "Modular architecture loaded.",
        "Welcome to organized code."
    }
end

function Game.update(dt)
    if Dialogue.isActive then
        Dialogue.update(dt)
        return
    end

    -- 1. Оновлюємо гравця (передаємо йому дані про рівень для колізій!)
    Player.update(dt, Level)

    -- 2. Оновлюємо камеру (щоб вона стежила за гравцем)
    Camera.update(Player, Level.boundaries)
end

function Game.draw()
    love.graphics.setBackgroundColor(0.4, 0.6, 1)

    -- Вмикаємо камеру
    Camera.set()
        Level.draw()  -- Малюємо світ
        Player.draw() -- Малюємо гравця
    Camera.unset()

    -- Інтерфейс (поверх камери)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    
    Dialogue.draw()
end

function Game.keypressed(key)
    if key == "escape" then love.event.quit() end

    if Dialogue.isActive then
        Dialogue.keypressed(key)
        return
    end

    -- Передаємо керування гравцю
    Player.keypressed(key)

    if key == "z" or key == "return" then
        Dialogue.start(Game.dialogueText)
    end
end

function Game.gamepadpressed(joystick, button)
    if Dialogue.isActive then
        if button == "a" then Dialogue.keypressed("space") end
        return
    end

    Player.gamepadpressed(button)

    if button == "start" or button == "y" then
         Dialogue.start(Game.dialogueText)
    end
end

return Game