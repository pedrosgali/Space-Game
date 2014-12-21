local names = require "/Lib/namegen"
local scenario = {}

scenario.name = "Test"
scenario.description = "Universe Spawning Tests"
scenario.spirals = 3
scenario.spStars = 350
scenario.spSpacing = 400
scenario.uniSpin = 30

function scenario:init()
    --name, class, faction, x, y
    --[[for x = -uni.mapSize, uni.mapSize do
        for y = -uni.mapSize, uni.mapSize do
            local rnd = math.random(1, uni.starChance)
            if rnd == uni.starChance then
                local name = names.randomName()
                local rSt = math.random(1, #uni.starTypes)
                local stClass = uni.starTypes[rSt].class
                uni.spawnStar(name, stClass, uni.player, x * uni.starClumping, y * uni.starClumping)
            end
        end
    end]]
end

function scenario:update(dt)
    
end

return scenario