local Collectables = {}
Collectables.__index = Collectables

function Collectables:new(x, y, type, value)
    local instance = setmetatable({}, Collectables)

    -- Записуємо дані безпосередньо в instance
    instance.x = x or 0
    instance.y = y or 0
    instance.width = 32  -- Додаємо розміри для колізій
    instance.height = 32
    instance.type = type or "empty"
    instance.value = value or 0
    instance.is_collected = false

    return instance
end

function Collectables:collect()
    self.is_collected = true
    return self.value
end

function Collectables:check_collision(player)
    -- Якщо вже зібрано, колізію не перевіряємо
    if self.is_collected then return false end

    return player.x < self.x + self.width and
           player.x + player.width > self.x and
           player.y < self.y + self.height and
           player.y + player.height > self.y
end

function Collectables:draw()
    if not self.is_collected then
        if self.type == "empty" then
            love.graphics.setColor(1, 0, 0)
            -- Малюємо квадрат навколо x, y
            love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
            love.graphics.print("Error", self.x, self.y - 15)
        end
    end
end

return Collectables