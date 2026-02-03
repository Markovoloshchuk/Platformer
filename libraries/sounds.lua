local Sounds = {}

-- Таблиця для зберігання самих аудіо-об'єктів
Sounds.library = {}

function Sounds.load()
    -- Ефекти (static)
    Sounds.library.damage = love.audio.newSource("assets/sfx/damage.wav", "static")
    Sounds.library.jump = love.audio.newSource("assets/sfx/jump.wav", "static")
    Sounds.library.speakDinner = love.audio.newSource("assets/sfx/speakDinner.wav", "static")
    Sounds.library.collect = love.audio.newSource("assets/sfx/collect.wav", "static")
    Sounds.library.hurt1 = love.audio.newSource("assets/sfx/hurt1.wav", "static")
    Sounds.library.no = love.audio.newSource("assets/sfx/no.mp3", "static")
    
    -- Музика (stream)
    Sounds.library.chillMusic = love.audio.newSource("assets/bgm/chillMusic.wav", "stream")
end

-- Зручна функція для програвання
function Sounds.play(name, volume, pitch)
    local s = Sounds.library[name]
    if s then
        -- Якщо хочемо, щоб звуки накладалися, краще використовувати :clone()
        local instance = s:clone()
        instance:setVolume(volume or 1.0)
        instance:setPitch(pitch or 1.0)
        instance:play()
    end
end

-- Функція для фонової музики (без клонування)
function Sounds.playMusic(name)
    if Sounds.library[name] then
        Sounds.library[name]:play()
    end
end

return Sounds