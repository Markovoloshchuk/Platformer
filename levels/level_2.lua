local BaseLevel = require("entities.base_level")

local Level2 = {}

function Level2.load()
    local level = BaseLevel:new()

    -- Цей рівень довший
    level.boundaries.width = 4000 
    
    -- Тут складніше
    level:spawnPlatform(200, 400, 100, 20, "platform")
    level:spawnSpike(300, 500)
    level:spawnSpike(350, 500)
    level:spawnSpike(400, 500) -- Більше шипів!
    
    level:spawnNPC(500, 440, {"Level 2 is harder", "Good luck"})

    return level
end

return Level2