local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local pl = require "/Classes/planet"

local planet = pl:spawnPlanet(planet)

--Basic Info...

planet.type = "planet"
planet.class = "Gas Giant"
planet.atmo = "Noxious"
planet.size = 1
planet.cost = 1000000
planet.maxStations = 4 --Not a cap per Planet, a cap on the starting stations on spawn.

--Health and stuff...

planet.hp = 4000
planet.hpMax = 4000
planet.ap = 15
planet.apMax = 15
planet.sp = 0
planet.spMax = 0
planet.shRecharge = 0
planet.spd = 1

--Cargo Stuff...

planet.stored = 0
planet.cargoMax = 1500

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
    newPlanet:randomizeColour()
    newPlanet.landImage = love.graphics.newQuad(611, 1, newPlanet.tw, newPlanet.th, uni.planSet:getDimensions())
    newPlanet.turn = math.random(1, 10) / 10
    newPlanet.scale = 4.5
    newPlanet.tw = newPlanet.tw * newPlanet.scale
    newPlanet.th = newPlanet.th * newPlanet.scale
    newPlanet.x = x - (newPlanet.tw / 2)
    newPlanet.y = y - (newPlanet.th / 2)
	return newPlanet
end

return planet