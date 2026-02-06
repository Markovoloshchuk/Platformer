local Collectables = {}
Collectables.__index = Collectables

function Collectables:new(x, y, width, height, type, value, key_name)
    local instance = setmetatable({}, Collectables)

    -- Записуємо дані безпосередньо в instance
    instance.x = x or 0
    instance.y = y or 0
    instance.width = width or 32  -- Додаємо розміри для колізій
    instance.height = height or 32
    instance.type = type or "empty"
    instance.value = value
    instance.key_name = key_name or nil
    instance.is_collected = false

    return instance
end

function Collectables.load()
    Collectables.shelly_icon = love.graphics.newImage("assets/image/icon/shelly_icon.png")
end

function Collectables:collect()
    if self.type == "empty" then
        Sounds.play("collect", 0.4, 1.1)
        print("Collectable of Empty type was collected!")

    elseif self.type == "shelly_icon" then
        Sounds.play("collect", 1.0, 0.7)
        print("Collectable of Shelly type was collected!")
    end

    if self.key_name then
        if self.value then
            self.value = false
        else
            self.value = true
        end
    end

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
        elseif self.type == "shelly_icon" then
            local img_w = Collectables.shelly_icon:getWidth()
            local img_h = Collectables.shelly_icon:getHeight()

            local sx = self.width / img_w
            local sy = self.height / img_h
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(Collectables.shelly_icon, self.x, self.y, 0, sx, sy)
        end
    end
end

return Collectables