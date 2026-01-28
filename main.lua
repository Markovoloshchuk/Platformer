-- main.lua
-- Завантажуємо стани
local GameState = require("states.game")
local MenuState = require("states.menu") -- Поки пустий, але нехай буде

local currentState = nil

function love.load()
    -- Глобальні налаштування графіки (піксель-арт стиль)
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Запускаємо гру відразу з геймплею (потім зміниш на MenuState)
    SwitchState(GameState)
end

function love.update(dt)
    if currentState and currentState.update then
        currentState.update(dt)
    end
end

function love.draw()
    if currentState and currentState.draw then
        currentState.draw()
    end
end

function love.keypressed(key)
    if currentState and currentState.keypressed then
        currentState.keypressed(key)
    end
end

function love.gamepadpressed(joystick, button)
    if currentState and currentState.gamepadpressed then
        currentState.gamepadpressed(joystick, button)
    end
end

-- Глобальна функція для зміни станів (щоб викликати її з меню, наприклад)
function SwitchState(newState)
    currentState = newState
    if currentState.load then
        currentState.load()
    end
end