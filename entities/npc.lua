local Dialogue = require("libraries.dialogue")

standart_font = love.graphics.newFont(Dialogue.gameFont)
sign_font = love.graphics.newFont(Dialogue.gameFont + 8)

local NPC = {}
NPC.__index = NPC

function NPC.new(x, y, texts_array)
    
    local instance = setmetatable({}, NPC)

    instance.x = x
    instance.y = y
    instance.width = 50
    instance.height = 50
    instance.text = texts_array

    instance.is_player_near = false
    instance.color = {0.8, 0.4, 0.8}

    return instance
end

function NPC:update(dt, player)
    -- If Player located in possible NPC area then is_player_near is true
    local reach_distance = 30

    if player.x < self.x + self.width + reach_distance and
    player.x + player.width > self.x - reach_distance and
    player.y < self.y + self.height + reach_distance and
    player.y + player.height > self.y - reach_distance then
        
        self.is_player_near = true
    else
        self.is_player_near = false
    end
end

function NPC:draw()
    -- Draw npc itself
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- If player is near, draws '!' to inform that action is possible
    if self.is_player_near and not Dialogue.isActive then
        sign = "!"
        local centered_x = self.x + (self.width / 2) - (sign_font:getWidth(sign) / 2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(sign_font)
        love.graphics.print(sign, centered_x, self.y - 30)
        love.graphics.setFont(standart_font)
    end
end

function NPC:interact()
    if self.is_player_near then
        Dialogue.start(self.text)
    end
end

return NPC