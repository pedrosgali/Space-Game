local scenario = {}

scenario.name = "Test 2"
scenario.description = "A test Scenario for playtesting."

function scenario:init()
    --name, class, faction, x, y
    uni.ent = nil
    for i = 1, 15 do
        local sx = math.random(-2500, 2500)
        local sy = math.random(-2500, 2500)
        uni.spawnStation("Stat "..i, "Factory", uni.player, sx, sy)
    end
    local sx = math.random(-2500, 2500)
    local sy = math.random(-2500, 2500)
    uni.spawnShip("Ship", "Freighter", uni.player, sx, sy)
end

function scenario:update(dt)

end

return scenario