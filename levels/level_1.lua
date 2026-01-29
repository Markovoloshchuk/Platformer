local BaseLevel = require("entities.base_level")

local Level1 = {}

function Level1.load()
    -- 1. Створюємо екземпляр на основі Батька
    local level = BaseLevel:new()

    -- 2. Налаштовуємо ТІЛЬКИ унікальні речі
    level.boundaries.width = 2000
    
    -- 3. Розставляємо об'єкти (використовуємо self методи батька)
    level:spawnPlatform(150, 350, 150, 150, "solid")
    level:spawnPlatform(400, 250, 150, 25, "platform")
    
    level:spawnSpike(400, 450)
    
    level:spawnNPC(150, 290, {"Welcome to Level 1", "Don't die!"})

    return level
end

return Level1