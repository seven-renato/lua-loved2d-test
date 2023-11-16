function love.load()
    wf = require "libraries/windfield"
    world = wf.newWorld(0, 0)

    camera = require "libraries/camera"
    cam = camera()

    anim8 = require "libraries/anim8"
    love.graphics.setDefaultFilter("nearest", "nearest") -- Ao aumentar o tamanho só aumenta os pixels não da blur

    sti = require "libraries/sti"
    gameMap = sti("maps/testMap.lua")

    player = {} -- Table
    player.collider = world:newBSGRectangleCollider(400, 250, 50, 100, 10)
    player.collider:setFixedRotation(true)

    player.x = 250
    player.y = 500 -- Position values
    player.speed = 300
    player.sprite = love.graphics.newImage("sprites/parrot.png")
    player.spriteSheet = love.graphics.newImage("sprites/player-sheet.png")
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight()) -- Dividir a sprite sheet

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid("1-4", 1), 0.2) -- columns an r, troca de imagem a cada 0.2 sec
    player.animations.left = anim8.newAnimation(player.grid("1-4", 2), 0.2) -- columns an r, troca de imagem a cada 0.2 sec
    player.animations.right = anim8.newAnimation(player.grid("1-4", 3), 0.2) -- columns an r, troca de imagem a cada 0.2 sec
    player.animations.up = anim8.newAnimation(player.grid("1-4", 4), 0.2) -- columns an r, troca de imagem a cada 0.2 sec

    player.anim = player.animations.left

    background = love.graphics.newImage("sprites/background.png")

    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType("static")
        table.insert(walls, wall)
        end
    end

    sounds = {}
    sounds.blip = love.audio.newSource("sounds/blip.wav", "static") -- Todo o arquivo é armazenado na memória
    sounds.music = love.audio.newSource("sounds/music.mp3", "stream") -- O arquivo é carregado em partes, vinda da memória
    sounds.music:setLooping(true)
    sounds.music:play()
end

function love.update(dt) -- Delta time represents the amount of time that has passed since the last frame was drawn. It is often used to make movements and animations in a game smooth and frame rate-independent.
    local isMoving = false

    local vx = 0
    local vy = 0

    if love.keyboard.isDown("right") then
        isMoving = true
        vx = player.speed -- a cada frame o x vai mudar += 1
        player.anim = player.animations.right
    end
    if love.keyboard.isDown("left") then
        isMoving = true
        vx = player.speed * -1 
        player.anim = player.animations.left
    end
    if love.keyboard.isDown("up") then
        isMoving = true
        vy = player.speed * -1 
        player.anim = player.animations.up
    end
    if love.keyboard.isDown("down") then
        isMoving = true
        vy = player.speed 
        player.anim = player.animations.down
    end

    player.collider:setLinearVelocity(vx, vy)

    if not isMoving then
        player.anim:gotoFrame(2)
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    player.anim:update(dt) -- player.anim.update(player.anim, dt)
    cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    if cam.x < w/2 then 
        cam.x = w/2
    end
    if cam.y < h/2 then 
        cam.y = h/2
    end
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tilewidth
    if cam.x > (mapW- w/2) then 
        cam.x = (mapW- w/2)
    end
    if cam.y > (mapH- h/2) then
        cam.y = (mapH- h/2)
    end
end
function love.draw()
    -- love.graphics.draw(background, 0, 0)
    -- love.graphics.draw(player.sprite, player.x, player.y)
    -- obj:cumprimentar()  -- Passa automaticamente 'obj' como o primeiro parâmetro é equivalente a obj.cumprimentar(obj)
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Camada de Blocos 1"])
        gameMap:drawLayer(gameMap.layers["Trees"])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 6, 9)
        --world:draw()
    cam:detach()
end 

function love.keypressed(key)
    if key == "space" then
        sounds.blip:play()
    end
    if key == "z" then
        sounds.music:stop()
    end
end