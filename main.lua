Class = require 'class'
push = require 'push'
bump = require 'bump'
sti = require 'sti'


require 'Animation'
require 'Player'

VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 360

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720



love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })

    deathscreen = love.graphics.newImage('Assets/background.png')
    mainFont = love.graphics.newFont("Assets/rainyhearts.ttf", 64)
    smallFont = love.graphics.newFont("Assets/rainyhearts.ttf", 32)     

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

    
    world = bump.newWorld(16)
    map = sti("Assets/Map.lua", { "bump" })
    map:bump_init(world)

    local camX, camY

    len = 0
    player = Player()
    
    world:add(player, player.x , player.y, player.width - 32, player.height - player.yOffset - 3)

    gamestate = 'play'

end

function love.resize(w, h)
    push:resize(w, h)
end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is pressed
function love.keypressed(key)
    
    if key == "return"  then

        if gamestate == 'dead' or gamestate == 'victory' then
            love.event.quit("restart")
        end
    end
    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

function love.update(dt)
    player:update(dt)
    map:update(dt)

    camX = math.max(-4630, -player.x + VIRTUAL_WIDTH/2 )
    
end

function love.draw()
    push:apply('start')
    
    love.graphics.setFont(smallFont)

        map:draw(camX, -player.y + VIRTUAL_HEIGHT /2 + 50)
        love.graphics.translate(camX, -player.y + VIRTUAL_HEIGHT /2 + 50)
        player:render()
        love.graphics.print("Use the ARROW KEYS to move", 400, 800)
        love.graphics.print("Press SPACE to jump", 750, 900)

    if gamestate == 'victory' then
        love.graphics.setFont(mainFont)
        love.graphics.print("YOU WON !", math.min(4960, player.x - 115), player.y - 200)
        love.graphics.setFont(smallFont)
        love.graphics.print("Press ENTER to RESTART!", 4813, 1000)
    end
    push:apply('end')

    if gamestate == 'dead' then
        love.graphics.draw(deathscreen, 0, 0)
    end
    

end

