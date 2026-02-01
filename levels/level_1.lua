local BaseLevel = require("entities.base_level")

local Level1 = {}

function Level1.load()
    -- 1. Створюємо екземпляр на основі Батька
    local level = BaseLevel:new()

    -- 2. Налаштовуємо ТІЛЬКИ унікальні речі
    level.boundaries.width = 1000
    
    -- Platforms
    level:spawnPlatform(150, 350, 150, 150, "solid")
    level:spawnPlatform(350, 250, 100, 25, "platform")
    level:spawnPlatform(800, 250, 200, 25, "platform")
    level:spawnPlatform(800, 150, 100, 25, "platform")
    level:spawnPlatform(700, 50, 100, 225, "solid")
    level:spawnPlatform(150, 50, 550, 50, "platform")
    level:spawnPlatform(150, -50, 100, 25, "platform")
    level:spawnPlatform(0, -200, 150, 400, "solid")
    level:spawnPlatform(0, -400, 30, 200, "solid")
    level:spawnPlatform(0, -800, 1000, 400, "solid")
    level:spawnPlatform(250, -200, 600, 25, "platform")
    
    -- Spikes
    level:spawnSpike(300, 500)
    level:spawnSpike(350, 500)
    level:spawnSpike(400, 500)
    level:spawnSpike(450, 500)
    level:spawnSpike(500, 500)
    level:spawnSpike(550, 500)
    level:spawnSpike(600, 500)

    level:spawnSpike(800, 250)
    level:spawnSpike(350, 50, 200)

    level:spawnSpike(250, -200)
    level:spawnSpike(400, -200)
    level:spawnSpike(450, -200)
    level:spawnSpike(600, -200, 100, 10)
    
    -- NPCs
    level:spawnNPC(200, 290, {"Welcome to /0Level 1 /0", "Don't die!"}, {"speakDinner", 0.8, 1.0, false})
    level:spawnNPC(700, 440, {
        "Go right into the /1red zone!",
        "Worry not, it will...",
        "Oh wait, where is it?",
        "...",
        "Well, nevermind, just go to the right to traverse into the /4new location!"
    })

    -- Transitions
    level:spawnTransition(990, -700, 10, 1200, 2, 50, 450)

    return level
end

return Level1