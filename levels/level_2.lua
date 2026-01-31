local BaseLevel = require("entities.base_level")

local Level2 = {}

function Level2.load()
    local level = BaseLevel:new()

    -- Цей рівень довший
    level.boundaries.width = 1000 
    
    -- Platforms
    level:spawnPlatform(200, 400, 100, 20, "platform")
    level:spawnPlatform(0, -200, 600, 25, "platform")
    level:spawnPlatform(600, -300, 200, 125, "solid")
    level:spawnPlatform(300, 300, 200, 25, "moving platform", {300, 800}, {300, -100}, 200)

    -- Spikes
    level:spawnSpike(300, 500)
    level:spawnSpike(350, 500)
    level:spawnSpike(400, 500)
    level:spawnSpike(450, 500)
    level:spawnSpike(500, 500)
    level:spawnSpike(550, 500)
    level:spawnSpike(600, 500)
    level:spawnSpike(650, 500)
    level:spawnSpike(700, 500)
    level:spawnSpike(750, 500)
    level:spawnSpike(800, 500)
    level:spawnSpike(850, 500, 50, 80)
    level:spawnSpike(900, 500, 50, 240)
    level:spawnSpike(950, 500, 50, 700)
    
    -- NPCs
    level:spawnNPC(225, 350, {"What a pricky path. I'm not sure it is possible to go through it."})
    level:spawnNPC(100, 440, {
        "I wonder, where could I go from here...",
        "67"
    })
    level:spawnNPC(675, -350, {
        "Wow, congrats! You really did it, huh?",
        "As a prize, I will sing you a song!",
        "Siiiiiiiix seveeeeeeeeeeeeeeeeeeeeeeeeeeeeeeen",
        "Siiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiix Seveeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeen!",
        "SIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIX SEVEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEN!",
        "Six seven on a Merry X-mas",
        "Now I have a proposal.",
        "Authentic factual responce or mischievous challenge?",
        "...",
        "What's with that unresponsivness?",
        "Well, I will take it as a dare.",
        "Go jump off the edge. To the right, of course.",
        "Muhahahaha~"
    })

    -- Transitions
    level:spawnTransition(0, -100, 10, 700, 1, 900, 450)

    return level
end

return Level2