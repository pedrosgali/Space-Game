local ship = require "/Classes/ship"

local shuttle = ship:spawnShip(shuttle)

shuttle.type = "ship"
shuttle.class = "Shuttle"
shuttle.size = 1
shuttle.cost = 100000
shuttle.hp = 1000
shuttle.hpMax = 1000
shuttle.ap = 5
shuttle.apMax = 5
shuttle.sp = 0
shuttle.spMax = 0
shuttle.shRecharge = 0
shuttle.spd = 600
shuttle.turn = 3
shuttle.stored = 0
shuttle.cargoMax = 500
shuttle.tw = 9
shuttle.th = 17
shuttle.image = love.graphics.newQuad(92, 48, shuttle.tw, shuttle.th, uni.shipSet:getDimensions())

function shuttle:spawnShip(newShip, name, faction, home)
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
  newShip:addEqSlot("Small Weapon")
  newShip:addEqSlot("Armour")
  newShip:addEqSlot("Engine")
  newShip:addEqSlot("Shield")
  newShip:addEqSlot("AI")
	return newShip
end

return shuttle