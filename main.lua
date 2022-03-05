distance_between = require("distance_between")
menu = require("menu")

function love.load()
    math.randomseed(os.time())


    sprites = {
        background = love.graphics.newImage("sprites/background.png"),
        bullet = love.graphics.newImage("sprites/bullet.png"),
        player = love.graphics.newImage("sprites/player.png"),
        zombie = love.graphics.newImage("sprites/zombie.png")
    }

    player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        speed = 180,
        isInjured = false,
        injuredSpeed = 180 * 1.5

    }

    sounds = {
        theme = love.audio.newSource("sounds/theme.mp3", "stream"),
        hit = love.audio.newSource("sounds/hit.wav", "static"),
        shot = love.audio.newSource("sounds/shot.wav", "static"),
        dead = love.audio.newSource("sounds/dead.wav", "static"),
    }

    sounds.theme:setLooping(true)
    sounds.theme:play()

    myFont = love.graphics.newFont(30)
    score = 0

    zombies = {}
    bullets = {}
    gameState = 1
    maxTime = 2
    timer = maxTime
end

function love.update(dt)
    local moveSpeed = player.speed
    if player.isInjured == true then
        moveSpeed = player.injuredSpeed
    end
    if gameState == 2 then
        if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
            player.x = player.x + moveSpeed * dt
            
        end
        if love.keyboard.isDown("a") and player.x > 0 then
            player.x = player.x - moveSpeed * dt
        end
        if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
            player.y = player.y + moveSpeed * dt
        end
        if love.keyboard.isDown("w") and player.y > 0 then
            player.y = player.y - moveSpeed * dt
        end
        if love.keyboard.isDown("m") and stopSound == false then
            sounds.theme:pause()
            stopSound = true
        elseif love.keyboard.isDown("p") and stopSound == true then
            sounds.theme:play()
            stopSound = false
        end
    end

    for i, z in ipairs(zombies) do
        z.x = z.x + math.cos(playerToZombie(z)) * z.speed * dt
        z.y = z.y + math.sin(playerToZombie(z)) * z.speed * dt
        if distance_between.distance_between(z.x, z.y, player.x, player.y) < 30 then
            if player.isInjured == false then
                player.isInjured = true
                sounds.hit:play()
                z.isDead = true
            else
                sounds.dead:play()
                for i, z in ipairs(zombies) do
                        zombies[i] = nil
                        gameState = 1
                        player.isInjured = false
                        player.x = love.graphics.getWidth() / 2
                        player.y = love.graphics.getHeight() / 2          
                end
            end
        end
    end


    for i, b in ipairs(bullets) do 
        b.x = b.x + math.cos(b.direction) * b.speed * dt
        b.y = b.y + math.sin(b.direction) * b.speed * dt
    end

    for i=#bullets, 1, -1 do
        local b = bullets[i]

        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() or b.isDestroyed == true then
            table.remove(bullets, i)

        end

    end

    for i,z in ipairs(zombies) do
        for j, b in ipairs(bullets) do
            if distance_between.distance_between(z.x, z.y, b.x, b.y) < 20 then
                z.isDead = true
                b.isDestroyed = true
                score = score + 1
            end
        end

    end

    for i=#zombies, 1, -1 do
        local z = zombies[i]
        if z.isDead == true then
            table.remove(zombies, i)

        end
    end

    if gameState == 2 then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            maxTime = 0.98 * maxTime
            timer = maxTime
        end

    end


end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)
    if player.isInjured then
        love.graphics.setColor(1,0,0)
    end
    love.graphics.draw(sprites.player, player.x, player.y, getMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
    love.graphics.setColor(1,1,1)
    if gameState == 1 then
        love.graphics.setFont(myFont)
        menu.menu(love.graphics.getWidth())

    end
    love.graphics.printf("Score: "..score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")

    for i, z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, playerToZombie(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    for i, b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, nil, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end

end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == 2 then
        spawnBullet()
    elseif button == 1 or button == 2 and gameState == 1 then
        gameState = 2
        maxTime = 2
        timer = maxTime
        score = 0
    end

end

function getMouseAngle() return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi end

function playerToZombie(enemy) return math.atan2(player.y - enemy.y, player.x - enemy.x) end
    
function spawnBullet()
    sounds.shot:play()
    local bullet = {
        x = player.x,
        y = player.y,
        speed = 500,
        direction = getMouseAngle(),
        isDestroyed = false
    }

    table.insert(bullets, bullet)
end


function spawnZombie()
    local zombie = {
        x = 0,
        y = 0,
        speed = 100,
        isDead = false
    }

    local side = math.random(1, 4)
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    else
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)

end





