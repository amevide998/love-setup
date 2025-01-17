function love.load()
    math.randomseed(os.time())

    score = 0

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')


    player = {}
    player.x = love.graphics.getWidth() / 2 - 20
    player.y = love.graphics.getHeight() / 2 - 20
    player.speed = 3 * 60
    player.rotation = 0

    myFont = love.graphics.newFont(30)

    zombies = {}
    bullets = {}

    gameState = 1
    maxTime = 2
    timer = maxTime
    levelIncrease = 10

end


function love.update(dt)
    if gameState == 2 then
        if love.keyboard.isDown( "d" ) and player.x < love.graphics.getWidth() - 40 then
            player.x = player.x + player.speed*dt
            --player.rotation = 0
        end
        if love.keyboard.isDown( "a" ) and player.x > 0 + 40 then
            player.x = player.x - player.speed*dt
            --player.rotation = 3.14
        end
        if love.keyboard.isDown( "w" ) and player.y > 0 + 40  then
            player.y = player.y - player.speed*dt
            --player.rotation = 3 * 3.14 / 2
        end
        if love.keyboard.isDown( "s" ) and player.y < love.graphics.getHeight() - 40 then
            player.y = player.y + player.speed*dt
            --player.rotation = 3.14 / 2
        end
    end


    for i,z in ipairs(zombies) do
        z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt
        z.y = z.y + math.sin(zombiePlayerAngle(z)) * z.speed * dt

        if distanceBetween(z.x, z.y , player.x, player.y) < 30 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
                gameState = 1
                player.x = love.graphics.getWidth() / 2 - 20
                player.y = love.graphics.getHeight() / 2 - 20
            end
        end
    end

    for i,b in ipairs(bullets) do
        b.x = b.x + (math.cos (b.direction) * b.speed * dt)
        b.y = b.y + (math.sin (b.direction) * b.speed * dt)
    end

    for i=#bullets, 1, -1 do
        if bullets[i].x <= 0 or bullets[i].x >= love.graphics.getWidth() or bullets[i].y <=0 or bullets[i].y >= love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end

    for i,z in ipairs(zombies) do
        for j,b in ipairs(bullets) do
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                z.dead = true
                b.dead = true
                score =  score + 1
            end
        end
    end

    for i=#zombies,1,-1 do
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies,i)
        end
    end

    for i=#bullets,1,-1 do
        local b = bullets[i]
        if b.dead == true then
            table.remove(bullets, i)
        end
    end

    if gameState == 2 then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            timer = maxTime
        end
    end

end

function love.draw()
    love.graphics.draw(sprites.background, 0,0)

    if gameState == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click Anywhere to begin! ", 0, 50, love.graphics.getWidth(), "center")
    else
        love.graphics.print("SCORE : " .. score, 0,0)
    end

    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(),nil,nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

    for i,z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x , z.y, zombiePlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x , b.y, nil, 0.5, nil, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end
end

function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x,y,button)
    if button == 1 and gameState == 2 then
        spawnBullet()
    elseif button == 1 and gameState == 1 then
        gameState = 2
        maxTime = 2
        timer = maxTime
        score = 0
    end
end

function playerMouseAngle()
    return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function zombiePlayerAngle(enemy)
    return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end


function spawnZombie()
    local zombie = {}
    local side = math.random(1,4)
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif side == 4 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    zombie.speed = 140
    zombie.dead = false
    table.insert(zombies, zombie)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2-y1)^2)
end