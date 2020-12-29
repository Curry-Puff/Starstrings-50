Enemy = class{}

local MOVE_SPEED = 50

function Player:init(type, x, y)
    self.x = x
    self.y = y
    self.type = type
end

self.types = {
    ['skeleton'] = {
        idle_texture = love.graphics.newImage("Assets/Skeleton/Idle.png")
        attack_texture = love.graphics.newImage("Assets/Skeleton/Attack.png")
        walk_texture = love.graphics.newImage("Assets/Skeleton/Walk.png")
        death_texture = love.graphics.newImage("Assets/Skeleton/Death.png")
    }      
}