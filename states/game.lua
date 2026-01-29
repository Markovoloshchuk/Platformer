-- states/game.lua
local Game = {}

local Player = require("entities.player")
local Camera = require("entities.camera")
local Level1 = require("levels.level_1") 
local Level2 = require("levels.level_2") 
local Dialogue = require("libraries.dialogue")

function Game.load()
    Dialogue.load()
    local gameFont = love.graphics.newFont(24)
    love.graphics.setFont(gameFont)

    Game.transition = {
        active = false,      -- is transition active
        state = "none",      -- 'out' if fade out, 'in' if fade in
        alpha = 0,           -- transparency
        speed = 4,         -- speed of transition
        next_level_num = 1,-- num of level where player will be teleported
        next_x = 0,
        next_y = 0
    }

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
    if Game.transition.active then return end
    
    Game.transition.active = true
    Game.transition.state = "out"
    Game.transition.next_level_num = number
    Game.transition.next_x = x
    Game.transition.next_y = y
end

function Game.changeLevelInstant(number, x, y)
    Game.levelNumber = number

    if number == 1 then
        Game.current_level = Level1.load()
    elseif number == 2 then
        Game.current_level = Level2.load()
    else
        print("Level not found(")
    end
    
    Player.load(x, y)
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

    if not Game.transition.active then
        Player.update(dt, Game.current_level)
    end
    Game.current_level:update(dt, Player, Game)
    Camera.update(Player, Game.current_level.boundaries)
end

function Game.draw()
    love.graphics.setBackgroundColor(0.4, 0.6, 1)

    Camera.set()
        Game.current_level:draw() -- Малює платформи, шипи і NPC
        Player.draw()
    Camera.unset()

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

function Game.keypressed(key)
    if Game.transition.active then return end   
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
    if Game.transition.active then return end
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