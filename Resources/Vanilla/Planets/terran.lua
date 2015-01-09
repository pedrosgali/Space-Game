local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local pl = require "/Classes/planet"

local planet = pl:spawnPlanet(planet)

--Basic Info...

planet.type = "planet"
planet.class = "Terran"
planet.atmo = "Oxygen"
planet.size = 1
planet.cost = 1000000
planet.maxStations = 3 --Not a cap per Planet, a cap on the starting stations on spawn.

--Health and stuff...

planet.hp = 2000
planet.hpMax = 2000
planet.ap = 15
planet.apMax = 15
planet.sp = 0
planet.spMax = 0
planet.shRecharge = 0
planet.spd = 1

--Cargo Stuff...

planet.stored = 0
planet.cargoMax = 1500

--Colour Stuff

planet.wr = 0
planet.wg = 0
planet.wb = math.random(200, 255)
planet.lr = 0
planet.lg = math.random(200, 255)
planet.lb = 0

function planet:spawnPlanet(newPlanet, name, faction, x, y)
	local newPlanet = newPlanet or {}
	setmetatable(newPlanet, self)
	self.__index = self
	newPlanet.name = name
    newPlanet.faction = faction
    newPlanet.heading = math.random(0, 359)
    newPlanet.vizHeading = math.random(0, 359)
    newPlanet.bearing = 0
	newPlanet.isVisible = true
    newPlanet.turn = math.random(1, 10) / 10
    newPlanet:setAtmoColour(newPlanet.atmo)
    newPlanet.tw = newPlanet.tw * newPlanet.scale
    newPlanet.th = newPlanet.th * newPlanet.scale
    newPlanet.x = x - (newPlanet.tw / 2)
    newPlanet.y = y - (newPlanet.th / 2)
	return newPlanet
end

return planet