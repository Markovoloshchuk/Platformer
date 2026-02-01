local Dialogue = require("libraries.dialogue")
local Sounds = require("libraries.sounds")

-- ПРИБРАЛИ створення шрифтів звідси (з верхівки файлу)

local NPC = {}
NPC.__index = NPC

-- Створимо шрифти як локальні змінні, але ініціалізуємо їх пізніше
local standart_font
local sign_font

function NPC.new(x, y, texts_array, conf)
    -- Ініціалізуємо шрифти тільки тоді, коли створюється перший NPC
    -- Це гарантує, що графічна система вже працює
    if not standart_font then
        -- Спробуємо взяти значення з модуля, якщо воно там є
        local sizeFromModule = Dialogue and Dialogue.gameFont
        
        -- Якщо там nil (або не число), використовуємо жорстко прописане 24
        local finalSize = tonumber(sizeFromModule) or 24
        
        -- Створюємо шрифти, використовуючи ЛОКАЛЬНУ змінну finalSize, яка точно є числом
        standart_font = love.graphics.newFont(finalSize)
        sign_font = love.graphics.newFont(finalSize + 8)
    end

    local instance = setmetatable({}, NPC)

    instance.x = x
    instance.y = y
    instance.width = 50
    instance.height = 50
    instance.text = texts_array
    instance.sound = conf[1] or nil
    instance.volume = conf[2] or 1.0
    instance.pitch = conf[3] or 1.0
    instance.is_repeatative = conf[4] 

    instance.is_player_near = false
    instance.color = {0.8, 0.4, 0.8}

    return instance
end

function NPC:update(dt, player)
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
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    if self.is_player_near and not Dialogue.isActive then
        local sign = "!"
        -- Тепер ми впевнені, що шрифти існують
        love.graphics.setFont(sign_font)
        local centered_x = self.x + (self.width / 2) - (sign_font:getWidth(sign) / 2)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(sign, centered_x, self.y - 40)
        
        -- Повертаємо стандартний шрифт для решти графіки
        love.graphics.setFont(standart_font)
    end
end

function NPC:interact()
    if self.is_player_near then
        if not self.is_repeatative then Sounds.play(self.sound, self.volume, self.pitch) end
        print(self.is_repeatative)
        Dialogue.start(self.text, self.sound, self.volume, self.pitch, self.is_repeatative)
    end
end

return NPC