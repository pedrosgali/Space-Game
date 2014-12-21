local stat = require "/Classes/station"
local item = require "/Classes/item"

local fac = stat:spawnStation(fac)

fac.class = "Factory"
fac.type = "station"
fac.hp = 10000
fac.hpMax = 10000
fac.hpRecharge = 0
fac.ap = 5000
fac.apMax = 5000
fac.apRecharge = 0
fac.sp = 1
fac.spMax = 15000
fac.shRecharge = 100
fac.turn = 0.01
fac.tgtx = "none"
fac.tgty = "none"
fac.scrx = "none"
fac.scry = "none"
fac.state = "Idle"
fac.productType = "Product"
fac.products = 1
fac.tw = 80
fac.th = 80
fac.vizHeading = 0
fac.image = love.graphics.newQuad(162, 1, fac.tw, fac.th, uni.statSet:getDimensions())

function fac:spawnStation()
    local newStat = {}
    setmetatable(newStat, self)
    self.__index = self
    newStat:addEqSlot("AI")
    return newStat
end

return fac