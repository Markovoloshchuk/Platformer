local BaseLevel = require("entities.base_level")
local Sound = require("libraries.sounds")

local Level3 = {}

function Level3.load(game_ref)
    local level = BaseLevel:new()

    level.boundaries.width = 1000 
    
    -- Platforms
    level:spawnPlatform("mp2", 100, 500, 200, 25, "moving platform", {100, 100}, {500, 200}, 400)
    level:spawnPlatform("mp1", 300, 300, 200, 25, "moving platform", {300, 800}, {300, -100}, 200)

    --Transition
    level:spawnTransition(0, -700, 10, 1200, 1, 900)

    --Scenes
    level:spawnScene("toggle information", 200, 200, 300, 300, 3, {
        { action = "toggle", boolean = "draw_statistics" },
        { action = "cooldown", interval = 2.0},
        { action = "sound", sound = {"hurt1", 1.0, 1.0}}
    }, {"on_touch", nil})

    return level
end



return Level3