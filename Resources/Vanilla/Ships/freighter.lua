local ship = require "/Classes/ship"

local Freighter = ship:spawnShip(Freighter)

Freighter.type = "ship"
Freighter.class = "Freighter"
Freighter.size = 1
Freighter.cost = 1000000
Freighter.hp = 2000
Freighter.hpMax = 2000
Freighter.ap = 15
Freighter.apMax = 15
Freighter.sp = 0
Freighter.spMax = 0
Freighter.shRecharge = 0
Freighter.spd = 100
Freighter.turn = 1
Freighter.stored = 0
Freighter.cargoMax = 1500
Freighter.tw = 14
Freighter.th = 19
Freighter.image = love.graphics.newQuad(62, 48, Freighter.tw, Freighter.th, uni.shipSet:getDimensions())

function Freighter:spawnShip(newShip, name, faction, planet)
	local newShip = newShip or {}
    setmetatable(newShip, self)
    self.__index = self
    newShip.name = name
    newShip.faction = faction
    newShip.rad = 0
    newShip.heading = 0
    newShip.vizHeading = 0
    newShip.bearing = 0
    local x, y = uni.ent[home].x, uni.ent[home].y
    newShip.x = x + (self.tw / 2)
    newShip.y = y + (self.th / 2)
    newShip.isVisible = true
    newShip:addEqSlot("Weapon")
    newShip:addEqSlot("Armour")
    newShip:addEqSlot("Engine")
    newShip:addEqSlot("Aux")
    newShip:addEqSlot("Aux")
    return newShip
end

return Freighter