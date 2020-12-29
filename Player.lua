-- The Player Character

Player = Class{}

local RUNNING_SPEED = 140
local JUMP_VELOCITY = 330
local GRAVITY = 18

function Player:init()
    self.x = 600
    self.y = 980
    self.dx = 0
    self.dy = 0
    self.width = 50
    self.height = 37.001

    self.xOffset = 25
    self.yOffset = 18.5

    self.texture = love.graphics.newImage("Assets/main_character.png")

    self.frames = {}
    self.currentFrame = nil

    self.state = 'idle'

    self.direction = 'right'

    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(self.width * 0, self.height * 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 1, self.height * 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 2, self.height * 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 3, self.height * 0, self.width, self.height, self.texture:getDimensions())
            },
            interval = 1/7
        }),

        ['running'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(self.width * 1, self.height * 1, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 2, self.height * 1, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 3, self.height * 1, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 4, self.height * 1, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 5, self.height * 1, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 6, self.height * 1, self.width, self.height, self.texture:getDimensions())
            },
            interval = 1/8
        }),

        ['jump'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(self.width * 0, self.height * 2, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 1, self.height * 2, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 2, self.height * 2, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 3, self.height * 2, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 4, self.height * 2, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 1, self.height * 3, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(self.width * 2, self.height * 3, self.width, self.height, self.texture:getDimensions())
            },
            interval = 1/11
        })
    }


    self.behaviors = {
        ['idle'] = function(dt)
            if love.keyboard.isDown('left') then

                self.sounds['run']:setLooping(true)
                self.sounds['run']:play()
                self.direction = 'left'
                self.dx = -RUNNING_SPEED
                self.state = 'running'
                
                self.animation = self.animations['running']
            
            elseif love.keyboard.isDown('right') then
                self.sounds['run']:setLooping(true)
                self.sounds['run']:play()
                self.direction = 'right'
                self.dx = RUNNING_SPEED
                self.state = 'running'
                
                self.animation = self.animations['running']
            
            elseif love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jump']

            else
                self.dx = 0
            end
            
        end,

        ['running'] = function(dt)
            
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jump']
                self.sounds['run']:stop()
            elseif love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -RUNNING_SPEED
            
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = RUNNING_SPEED
                     
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.sounds['run']:stop()
            end
        end,

        ['jumping'] = function(dt)
            
            self.dy = self.dy + GRAVITY 
            if love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -RUNNING_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = RUNNING_SPEED
            else
                self.dx = 0
            end
        end           
    }
    
    self.sounds = {
        ['BGM'] = love.audio.newSource('Assets/Sounds/BGM.wav', 'static'),
        ['Hit'] = love.audio.newSource('Assets/Sounds/Hit.wav', 'static'),
        ['Victory'] = love.audio.newSource('Assets/Sounds/Victory.wav', 'static'),
        ['run'] = love.audio.newSource('Assets/Sounds/run.wav', 'static'),
        ['death'] = love.audio.newSource('Assets/Sounds/death.wav', 'static')
    }

    self.sounds['BGM']:setLooping(true)
    self.sounds['BGM']:play()

    self.animation = self.animations['idle']
end

function Player:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    
    self.currentFrame = self.animation:getCurrentFrame()

    local goalX, goalY = self.x + self.dx * dt, self.y + self.dy * dt
    local actualX, actualY, cols, len = world:move(self, goalX, goalY)
    self.x, self.y = actualX, actualY

    if self.state == 'jumping' then
        if len > 0 then
            self.sounds['Hit']:play()
            self.state = 'idle'
            self.animation = self.animations['idle']
            love.keyboard.keysPressed['space'] = false
            self.dy = 0 
        end
    elseif self.state ~= 'jumping' then
        if len == 0 then
            self.dy = self.dy + GRAVITY    
        
        else
            self.dy = GRAVITY
        end
    end

    self:death()

    if player.x > 4960 then
       gamestate = 'victory'
       self.sounds['BGM']:stop()
       self.sounds['Victory']:setLooping(true)
       self.sounds['Victory']:play() 
    end
end
function Player:render()
    
    local scaleX
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end
    
    love.graphics.draw(self.texture, self.currentFrame, self.x + 8,
        self.y - 2, 0, scaleX, 1, self.xOffset, self.yOffset)
end

function Player:death()

    if self.y > 1100 then
        gamestate = 'dead'
        self.sounds['BGM']:stop()
        self.sounds['death']:setLooping(true)
        self.sounds['death']:play()
    end
    
    if self.dy > 900 then
        gamestate = 'dead'
        self.sounds['BGM']:stop()
        self.sounds['death']:setLooping(true)
        self.sounds['death']:play()
    end

end