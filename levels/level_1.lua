local BaseLevel = require("entities.base_level")

local Level1 = {}

function Level1.load(game_ref)
    -- 1. Створюємо екземпляр на основі Батька
    local level = BaseLevel:new()

    -- 2. Налаштовуємо ТІЛЬКИ унікальні речі
    level.boundaries.width = 1000
    
    -- Platforms
    level:spawnPlatform("sp1", 150, 350, 150, 150, "solid")
    level:spawnPlatform("p1", 350, 250, 100, 25, "platform")
    level:spawnPlatform("p2", 800, 250, 200, 25, "platform")
    level:spawnPlatform("p2", 800, 150, 100, 25, "platform")
    level:spawnPlatform("sp2", 700, 50, 100, 225, "solid")
    level:spawnPlatform("sp3", 150, 50, 550, 50, "solid")
    level:spawnPlatform("p3", 150, -50, 100, 25, "platform")
    level:spawnPlatform("sp4", 0, -200, 150, 400, "solid")
    level:spawnPlatform("sp5", 0, -400, 30, 200, "solid")
    level:spawnPlatform("sp6", 0, -800, 600, 400, "solid")
    level:spawnPlatform("sp7", 800, -800, 200, 400, "solid")
    level:spawnPlatform("p4", 250, -200, 600, 25, "platform")
    level:spawnPlatform("mp1", 600, -425, 200, 25, "moving platform", {600, 600}, {-195, -800}, 0)
    
    -- Spikes
    level:spawnSpike("s1", 300, 500)
    level:spawnSpike("s2", 350, 500)
    level:spawnSpike("s3", 400, 500)
    level:spawnSpike("s4", 450, 500)
    level:spawnSpike("s5", 500, 500)
    level:spawnSpike("s6", 550, 500)
    level:spawnSpike("s7", 600, 500)

    level:spawnSpike("s8", 800, 250)
    level:spawnSpike("s9", 350, 50, 200)

    level:spawnSpike("s10", 250, -200)
    level:spawnSpike("s11", 400, -200)
    level:spawnSpike("s12", 450, -200)
    level:spawnSpike("s13", 600, -200, 100, 10)
    
    -- NPCs
    level:spawnNPC("npc1", 200, 290, {"Welcome to /4Level 1 /0", "Don't die!"}, {"speakDinner", 0.8, 1.0, false})
    level:spawnNPC("npc2", 700, 440, {
        "In some areas, you can traverse trough locations.",
        "Remember, that /4your height transfers to another location! /0That might help you get to some seemingly impossible places."
    })

    -- Transitions
    level:spawnTransition(990, -700, 10, 1200, 2, 50)

    -- Collectables
    level:spawnCollectable(850, 120, nil, nil, "empty", 5)
    level:spawnCollectable(730, 0, nil, nil, "empty", 5)
    level:spawnCollectable(150, 300, nil, nil, "empty", 5)
    level:spawnCollectable(250, 300, nil, nil, "empty", 5)
    level:spawnCollectable(375, 200, nil, nil, "empty", 5)
    level:spawnCollectable(175, -100, nil, nil, "empty", 5)


---@diagnostic disable-next-line: duplicate-set-field
    level.update = function(self, dt, player, game_ref)
        BaseLevel.update(self, dt, player, game_ref)

        if game_ref.l1_mp1_active == true then
            
            for i = 1, #self.platforms do
                if self.platforms[i].name == "mp1" then
                    self.platforms[i].moving_speed = {200, 200}
                end
            end
        end
    end

    return level
end


return Level1