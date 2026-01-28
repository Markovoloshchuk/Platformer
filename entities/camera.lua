-- entities/camera.lua
local Camera = {
    x = 0,
    y = 0
}

function Camera.update(target, world_boundaries)
    local screen_w = love.graphics.getWidth()
    local screen_h = love.graphics.getHeight()

    -- 1. Слідування за ціллю
    Camera.x = target.x - (screen_w / 2) + (target.width / 2)
    Camera.y = target.y - (screen_h / 2) + (target.height / 2)

    -- 2. Обмеження (Clamping)
    -- X
    if Camera.x < 0 then Camera.x = 0 end
    if Camera.x > world_boundaries.width - screen_w then
        Camera.x = world_boundaries.width - screen_w
    end
    
    -- Y
    if Camera.y > 0 then Camera.y = 0 end
    if Camera.y < world_boundaries.top_limit then
        Camera.y = world_boundaries.top_limit
    end
end

function Camera.set()
    love.graphics.push()
    love.graphics.translate(-Camera.x, -Camera.y)
end

function Camera.unset()
    love.graphics.pop()
end

return Camera