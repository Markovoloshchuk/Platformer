local Movement = {}

function Movement.to_target(game_ref, obj_name, target_x, target_y, speed, dt, lvl)
    local obj = obj_name
    --game_ref.find_object(obj_name)

    local dx = target_x - obj.x
    local dy = target_y - obj.y
    local distance = math.sqrt(dx*dx + dy*dy)

    if distance < 1 then
        obj.x, obj.y = target_x, target_y
        return true
    end

    obj.x = obj.x + (dx / distance) * speed * dt
    obj.y = obj.y + (dy / distance) * speed * dt
    return false
end

return Movement