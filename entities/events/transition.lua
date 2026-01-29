local Event = require("entities.event")

local Transition = {}
Transition.__index = Transition
setmetatable(Transition, {__index = Event}) -- Inherits Event table

function Transition:new(x, y, w, h, target_level, target_x, target_y)
    local instance = Event:new(x, y, w, h)

    setmetatable(instance, Transition) -- Attaching metods of Transition to this object (?)

    instance.target_level = target_level
    instance.target_x = target_x
    instance.target_y = target_y

    return instance
end

function Transition:trigger(game_ref, player)
    if self.active then
        print("Transition triggered! Going to level " .. self.target_level)

        game_ref.switchLevel(self.target_level, self.target_x, self.target_y)

        self.active = false
    end
    
end

return Transition