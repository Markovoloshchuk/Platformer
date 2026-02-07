local Event = {}
Event.__index = Event

function Event:new(x, y, w, h)
    local instance = setmetatable({}, Event)
    instance.x = x
    instance.y = y
    instance.width = w
    instance.height = h
    instance.active = true
    return instance
end

function Event:trigger(game_ref)
    print("Base event triggered!")
end

function Event:check_collision(player)
    return player.x < self.x + self.width and
           player.x + player.width > self.x and
           player.y < self.y + self.height and
           player.y + player.height > self.y
end

function Event:update(dt, game_ref, player)
    
end

function Event:draw()
    love.graphics.setColor(1, 0, 0, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Event