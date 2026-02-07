local utf8 = require("utf8")
local Sounds = require("libraries.sounds")

local Dialogue = {}

-- =================================================
-- ПРИВАТНІ ЗМІННІ
-- =================================================

local dialog_window = {}
local texts = {}
local i = 1
local charsToShow = 0
local totalCharsInSlide = 0 -- Загальна кількість символів у поточному слайді
local timer = 0
local typingSpeed = 0.04
local is_printing = false
local sound, volume, pitch, is_repeatative = nil, nil, nil, true


-- Словник кольорів
local colorPalette = {
    ["0"] = {1, 1, 1},       -- Білий (стандарт)
    ["1"] = {1, 0.2, 0.2},   -- Червоний
    ["2"] = {0.2, 1, 0.2},   -- Зелений
    ["3"] = {0.2, 0.6, 1},   -- Блакитний
    ["4"] = {1, 0.8, 0.2},   -- Жовтий
    ["5"] = {1, 0, 1},       -- Пурпурний
}

-- Таблиця оброблених вузлів для поточного слайду
local current_nodes = {}

-- =================================================
-- ПУБЛІЧНІ ЗМІННІ
-- =================================================

Dialogue.isActive = false 
Dialogue.is_done = false
Dialogue.gameFont = love.graphics.newFont(24)

-- =================================================
-- ЛОКАЛЬНІ ДОПОМІЖНІ ФУНКЦІЇ
-- =================================================

-- Парсер: розбиває рядок на вузли за тегами /цифра
local function parseToNodes(input_text)
    local nodes = {}
    -- Якщо текст не починається з тегу, додаємо стандартний білий
    local formatted = input_text:find("^/") and input_text or ("/0" .. input_text)
    
    for color_idx, txt in formatted:gmatch("/(%d)([^/]+)") do
        table.insert(nodes, {
            text = txt,
            color = colorPalette[color_idx] or colorPalette["0"]
        })
    end
    return nodes
end

-- Wrapper: розраховує координати для кожного слова
local function wrapNodes(nodes, limit)
    local wrapped = {}
    local cursor_x = 0
    local cursor_y = 0
    local line_height = gameFont:getHeight() * 1.2
    local total_len = 0

    for _, node in ipairs(nodes) do
        -- Розбиваємо на слова, зберігаючи пробіли
        for word in node.text:gmatch("%S+%s*") do
            local word_width = gameFont:getWidth(word)
            local word_len = utf8.len(word)

            if cursor_x + word_width > limit then
                cursor_x = 0
                cursor_y = cursor_y + line_height
            end

            table.insert(wrapped, {
                text = word,
                color = node.color,
                x = cursor_x,
                y = cursor_y,
                len = word_len
            })
            
            cursor_x = cursor_x + word_width
            total_len = total_len + word_len
        end
    end
    return wrapped, total_len
end

-- =================================================
-- ОСНОВНІ ФУНКЦІЇ МОДУЛЯ
-- =================================================

function Dialogue.load()
    local fontSize = 24
    gameFont = love.graphics.newFont(fontSize)
    
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local d_width = screen_width - 100
    local d_height = 200
    
    dialog_window = {
        width = d_width,
        height = d_height,
        x = (screen_width - d_width) / 2,
        y = screen_height - d_height - 50,
        bgColor = {0, 0, 0, 0.8},
        borderColor = {1, 1, 1, 0.3}
    }
end

function Dialogue.start(texts_array, soundName, volumeLevel, pitchLevel, repeatative)
    Dialogue.is_done = false
    if type(texts_array) ~= "table" or #texts_array == 0 then return end

    texts = texts_array
    i = 1
    
    local raw_nodes = parseToNodes(texts[i])
    current_nodes, totalCharsInSlide = wrapNodes(raw_nodes, dialog_window.width - 40)
    
    charsToShow = 0
    timer = 0
    is_printing = true
    sound = soundName or nil
    volume = volumeLevel or 1.0
    pitch = pitchLevel or 1.0
    is_repeatative = repeatative or false
    Dialogue.isActive = true
end

function Dialogue.update(dt)
    if not Dialogue.isActive or not is_printing then return end

    timer = timer + dt
    if timer > typingSpeed then
        timer = timer - typingSpeed
        if charsToShow < totalCharsInSlide then
            if sound ~= nil and is_repeatative then Sounds.play(sound, volume, pitch) end
            charsToShow = charsToShow + 1
        else
            is_printing = false
        end
    end
end

function Dialogue.draw()
    if not Dialogue.isActive then return end

    -- Малюємо вікно
    love.graphics.setColor(dialog_window.bgColor)
    love.graphics.rectangle("fill", dialog_window.x, dialog_window.y, dialog_window.width, dialog_window.height, 10)
    love.graphics.setColor(dialog_window.borderColor)
    love.graphics.rectangle("line", dialog_window.x, dialog_window.y, dialog_window.width, dialog_window.height, 10)

    love.graphics.setFont(gameFont)

    -- Малюємо токени по літерах
    local printed_so_far = 0
    for _, node in ipairs(current_nodes) do
        if printed_so_far < charsToShow then
            local remaining = charsToShow - printed_so_far
            local display_count = math.min(node.len, remaining)
            
            -- Отримуємо частину тексту слова
            local byteOffset = utf8.offset(node.text, display_count + 1)
            local part = node.text:sub(1, byteOffset and byteOffset - 1 or #node.text)

            love.graphics.setColor(node.color)
            love.graphics.print(part, dialog_window.x + 20 + node.x, dialog_window.y + 20 + node.y)
            
            printed_so_far = printed_so_far + node.len
        else
            break -- Далі літери ще не "надруковані"
        end
    end
    
    -- Стрілочка готовності
    if not is_printing then
        love.graphics.setColor(1, 1, 1, math.abs(math.sin(love.timer.getTime()*5)))
        love.graphics.print(">", dialog_window.x + dialog_window.width - 30, dialog_window.y + dialog_window.height - 40)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Dialogue.keypressed(key)
    if not Dialogue.isActive then return end


    if key == "z" or key == "space" or key == "return" then
        if is_printing then
            is_printing = false
            charsToShow = totalCharsInSlide
        else
            if texts[i+1] == nil then
                Dialogue.isActive = false
                Dialogue.is_done = true
            else
                i = i + 1
                local raw_nodes = parseToNodes(texts[i])
                current_nodes, totalCharsInSlide = wrapNodes(raw_nodes, dialog_window.width - 40)
                charsToShow = 0
                timer = 0
                is_printing = true
            end
        end
    end
end

return Dialogue