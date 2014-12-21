local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local st = require "/Classes/star"

local star = st:spawnStar(star)

--Basic Info...

star.type = "star"
star.class = "White Dwarf"
star.size = 100
star.cost = 10000000000
star.maxPlanets = 7 --Not a cap per Planet, a cap on the starting stations on spawn.
star.maxAsteroids = 1

--Health and stuff...

star.hp = 200000
star.hpMax = 200000
star.ap = 15000
star.apMax = 15000
star.sp = 0
star.spMax = 0
star.shRecharge = 0
star.spd = 0
star.turn = 0

function star:spawnStar(newStar, name, faction, x, y)
	local newStar = newStar or {}
	setmetatable(newStar, self)
	self.__index = self
	newStar.name = string.sub(self.type, 1, 2).."_"..string.sub(self.class, 1, 1)..tostring(#uni.ent + 1)..string.sub(self.class, 2, 2)
    newStar.faction = faction
    newStar.heading = 0
    newStar.vizHeading = 0
    newStar.bearing = 0
    newStar.tw = math.random(600, 1200)
	newStar.th = newStar.tw
    newStar.x = x + (newStar.tw / 2)
    newStar.y = y + (newStar.th / 2)
	newStar.isVisible = true
	newStar.xVel = 0
	newStar.yVel = 0
	newStar.tgtx = "none"
	newStar.tgty = "none"
	newStar.scrx = "none"
	newStar.scry = "none"
	newStar.docked = 0
	newStar.docking = 0
	newStar.state = "Idle"
	return newStar
end

return star