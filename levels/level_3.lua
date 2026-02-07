local BaseLevel = require("entities.base_level")
local Sound = require("libraries.sounds")

local Level3 = {}

function Level3.load(game_ref)
    local level = BaseLevel:new()

    level.boundaries.width = 1000 
    
    -- Platforms
    level:spawnPlatform("mp1", 300, 300, 200, 25, "moving platform", {300, 500}, {500, -100}, 200)
    level:spawnPlatform("mp2", 75, 800, 200, 25, "platform")

    --Transition
    level:spawnTransition(990, -700, 10, 1200, 1, 50, 450)

    --Scenes
    level:spawnScene("toggle information", 200, 200, 300, 300, 3, {
        { action = "toggle", boolean = "draw_statistics" },
        { action = "jump", target = "player"},
        { action = "move", target = "player", x = 500, y = 450, speed = 300 },
        { action = "cooldown", interval = 0.5},
        { action = "sound", sound = {"hurt1", 1.0, 1.0}},
        { action = "dialogue", text = {
            "You are my friend!",
            "Uuuuuhhhh aaah booku no"
        }, start = false},
        { action = "jump", target = "player"},
        { action = "move", target = "player", x = 100, y = 450, speed = 300 },
        { action = "dialogue", text = {
            "I wonder if some random platform could work.",
            "I mean, their movement in cutscene."
        }, start = false},
        { action = "move", target = level:find_object("mp2"), x = 75, y = 300, speed = 100 },
        { action = "dialogue", text = {
            "...",
            "It's working as well, glad to see that.",
            "Okay, now let's get started."
        }, start = false},
        { action = "move", target = "player", x = 950, y = 450, speed = 500 },
        
    }, {"on_touch", nil})

    return level
end



return Level3