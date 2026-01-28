local utf8 = require("utf8")

local Dialogue = {}

-- =================================================
-- ПРИВАТНІ ЗМІННІ
-- =================================================

local gameFont = nil
local dialog_window = {}
local texts = {}
local target_text = ""
local i = 1
local charsToShow = 0
local timer = 0
local typingSpeed = 0.04
local is_printing = false
local is_upper = false

-- =================================================
-- ПУБЛІЧНІ ЗМІННІ
-- =================================================

Dialogue.isActive = false 

-- =================================================
-- ЛОКАЛЬНІ ДОПОМІЖНІ ФУНКЦІЇ
-- =================================================

local function wrapText(text, limit, font)
    limit = limit or 600
    font = font or gameFont

    local words = {}
    for word in text:gmatch("[^ ]+") do
        table.insert(words, word)
    end

    local current_line_width = 0
    local final_text = ""
    
    -- is_upper = false -- Можна розкоментувати, якщо треба скидати капс на кожному слайді

    for _, word in ipairs(words) do
        -- Обробка тегів /u (UPPERCASE)
        if word:find("/u") then
            if not is_upper then
                word = word:gsub("/u", "")
                is_upper = true
            else
                word = word:gsub("/u", "")
                is_upper = false
            end
        end
        
        -- Обробка тегів /+ (сміття)
        if word:find("%/%+") then
            word = word:gsub("%/%+", "")
        end

        if is_upper then
            word = string.upper(word)
        end

        local word_width = font:getWidth(word)
        local space_width = font:getWidth(" ")

        if current_line_width + word_width > limit then
            if final_text == "" then
                final_text = word
            else 
                final_text = final_text .. "\n" .. word
            end
            current_line_width = word_width
        else
            if final_text ~= "" then
                final_text = final_text .. " " .. word
                current_line_width = current_line_width + space_width + word_width
            else
                final_text = word
                current_line_width = word_width
            end
        end
    end

    return final_text
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
        color = {0, 0, 0, 0.8},
        textColor = {1, 1, 1, 1}
    }
end

function Dialogue.start(texts_array)
    if type(texts_array) ~= "table" then 
        print("Error: Dialogue.start очікує таблицю!") 
        return 
    end

    texts = texts_array
    i = 1
    is_upper = false
    
    target_text = wrapText(texts[i], dialog_window.width - 40, gameFont)
    
    charsToShow = 0
    timer = 0
    is_printing = true
    Dialogue.isActive = true
end

function Dialogue.update(dt)
    if not Dialogue.isActive then return end

    timer = timer + dt
    
    if is_printing then
        if timer > typingSpeed then
            timer = timer - typingSpeed
            if charsToShow < utf8.len(target_text) then
                charsToShow = charsToShow + 1
            else
                is_printing = false
            end
        end
    end
end

function Dialogue.draw()
    if not Dialogue.isActive then return end

    -- Фон
    love.graphics.setColor(dialog_window.color)
    love.graphics.rectangle("fill", dialog_window.x, dialog_window.y, dialog_window.width, dialog_window.height, 10, 10)

    -- Текст
    love.graphics.setColor(dialog_window.textColor)
    love.graphics.setFont(gameFont)

    local currentText = ""
    if is_printing then
        local byteOffset = utf8.offset(target_text, charsToShow + 1)
        if byteOffset then
            currentText = string.sub(target_text, 1, byteOffset - 1)
        else
            currentText = target_text
        end
    else
        currentText = target_text
    end

    love.graphics.print(currentText, dialog_window.x + 20, dialog_window.y + 20)
    
    -- Індикатор продовження (блимаюча стрілочка, якщо текст дописався)
    if not is_printing then
        love.graphics.print(">", dialog_window.x + dialog_window.width - 30, dialog_window.y + dialog_window.height - 40)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Dialogue.keypressed(key)
    if not Dialogue.isActive then return end

    -- ОНОВЛЕНО: Тепер реагує на Z, Space (Геймпад A) та Enter (Return)
    if key == "z" or key == "space" or key == "return" then
        if is_printing then
            -- Пропустити друк
            is_printing = false
            charsToShow = utf8.len(target_text)
        else
            -- Наступний слайд
            if texts[i+1] == nil then
                Dialogue.isActive = false
                target_text = ""
            else
                i = i + 1
                target_text = wrapText(texts[i], dialog_window.width - 40, gameFont)
                charsToShow = 0
                timer = 0
                is_printing = true
            end
        end
    end
end

return Dialogue