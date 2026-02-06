local Event = require("entities.event")
local Movement = require("entities.events.movement")
local Dialogue = require("libraries.dialogue")
local Sound = require("libraries.sounds")

local Scene = {}
Scene.__index = Scene
setmetatable(Scene, {__index = Event}) -- Inherits Event table

function Scene:new(name, x, y, w, h, lvl, queues, triggered)
    local instance = Event:new(x, y, w, h)

    setmetatable(instance, Scene) -- Attaching metods of Scene to this object (?)

    instance.name = name
    instance.lvl = lvl
    instance.queue = queues
    instance.event_triggered = false
    instance.is_available = true
    instance.on_cooldown = false

    instance.triggered = triggered or {"on_touch", nil} -- {"trigger", false} or "on_touch"

    --[[ The structure of queue:
    Dialogue:      { action = "dialogue", target = nil, dialogue = {{"text"}, "sound", volume, pitch, is_repeatative} } 
    Movement:      { action = "move", target = "[obj]", x = x, y = y, speed = speed }
    Sound:         { action = "sound", target = nil, sound = {"sound", volume, pitch}}
    Boolean        { action = "toggle", target = "[boolean]"}
    Cooldown       { action = "cooldown", target = nil, interval = interval }
    ]]

    return instance
end

function Scene:update(dt, game_ref)
    if self.event_triggered and #self.queue > 0 then
            local task = self.queue[1]

            if task.action == "move" then
                local reached = Movement.to_target(task.target, task.x, task.y, task.speed, dt)
                if reached then table.remove(self.queue, 1) end

            elseif task.action == "dialogue" then
                Dialogue.start(self.text, self.sound, self.volume, self.pitch, self.is_repeatative)
                if Dialogue.isActive == false then table.remove(self.queue, 1) end

            elseif task.action == "sound" then
                Sound.play(task.sound[1], task.sound[2], task.sound[3])
                table.remove(self.queue, 1)

            elseif task.action == "toggle" then
                game_ref[task.boolean] = not game_ref[task.boolean]
                self.on_cooldown = true
                table.remove(self.queue, 1)

            elseif task.action == "cooldown" then
                task.interval = task.interval - dt
                if task.interval <= 0 then
                    table.remove(self.queue, 1)
                else
                    return
                end
            end

    end
        

end

function Scene:trigger(game_ref, player)
    if self.is_available then
        if self.triggered[1] == "on_touch" then
            print("On touch is triggered")
            self.event_triggered = true
            self.is_available = false
        elseif self.triggered[1] == "trigger" and self.triggered[2] == true then
            self.event_triggered = true
            self.is_available = false
        end
    end
        
end



return Scene