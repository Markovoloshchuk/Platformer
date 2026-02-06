local BaseLevel = require("entities.base_level")

local Level2 = {}

function Level2.load(game_ref)
    local level = BaseLevel:new()

    -- Цей рівень довший
    level.boundaries.width = 1000 
    
    -- Platforms
    level:spawnPlatform("p1", 200, 400, 100, 20, "platform")
    level:spawnPlatform("p2", 0, -200, 600, 25, "platform")
    level:spawnPlatform("sp1", 600, -300, 200, 125, "solid")
    level:spawnPlatform("mp1", 300, 300, 300, 25, "moving platform", {300, 600}, {300, -100}, 200)

    -- Spikes
    level:spawnSpike("s1", 350, 300)
    level:spawnSpike("s2", 300, 500)
    level:spawnSpike("s3", 350, 500)
    level:spawnSpike("s4", 400, 500)
    level:spawnSpike("s5", 450, 500)
    level:spawnSpike("s6", 500, 500)
    level:spawnSpike("s7", 550, 500)
    level:spawnSpike("s8", 600, 500)
    level:spawnSpike("s9", 650, 500)
    level:spawnSpike("s10", 700, 500)
    level:spawnSpike("s11", 750, 500)
    level:spawnSpike("s12", 800, 500)
    level:spawnSpike("s13", 850, 500, 50, 80)
    level:spawnSpike("s14", 900, 500, 50, 240)
    level:spawnSpike("s15", 950, 500, 50, 700)
    
    -- NPCs
    level:spawnNPC("npc1", 225, 350, {"What a /4pricky path. /0I'm not sure it is possible to go through it."})
    level:spawnNPC("npc2", 100, 440, {
        "I wonder, where could I go /4from here /0...",
        "67"
    })
    level:spawnNPC("npc3", 675, -350, {
        "Wow, congrats! You really did it, huh?",
        "As a prize, I will sing you a song!",
        "Siiiiiiiix seveeeeeeeeeeeeeeeeeeeeeeeeeeeeeeen",
        "Siiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiix Seveeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeen!",
        "SIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIX SEVEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEN!",
        "Six seven on a Merry X-mas",
        "Now I have a /1proposal.",
        "/2Authentic factual responce /0or /1mischievous challenge?",
        "...",
        "What's with that unresponsivness?",
        "Well, I will take it as a dare.",
        "Go jump off the edge. To the right, of course.",
        "/4Muhahahaha~"
    }, {"speakDinner", 0.1, 1.3, true})
    level:spawnNPC("npc4", 400, -250, {
        "/1no"
    }, {"no", 3.0, 1, false})

    -- Transitions
    level:spawnTransition(0, -700, 10, 1200, 1, 900)

    -- Collectables
    level:spawnCollectable(275, -300, 100, 100, "shelly_icon", game_ref.l1_mp1_active, "l1_mp1_active")

---@diagnostic disable-next-line: duplicate-set-field
    level.update = function(self, dt, player, game_ref)
        BaseLevel.update(self, dt, player, game_ref)

        self:move_along_moving_platform("mp1", {{name = "s1", rx = 100, ry = 0}, {name = "npc2", rx = 200, ry = -50}})
    end

    return level
end



return Level2