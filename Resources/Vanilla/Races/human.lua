local fact = require "/Classes/faction"

local fac = fact:newFaction(fac)

fac.race = "Human"
fac.atmo = "Oxygen"

function fac:newFaction(newFac, id, name, homePlanetId, hp, ap, sp)
	local newFac = newFac or {}
	setmetatable(newFac, self)
	self.__index = self
	newFac.name = name
	newFac.facId = id
	newFac.homePlanetId = homePlanetId
	newFac.homeStarId = uni.ent[newFac.homePlanetId].homeStarId
	newFac.cash = uni.factionCash
	newFac.hpBuff = hp
	newFac.apBuff = ap
	newFac.shBuff = sp
	local ranAI = math.random(1, #uni.aiList)
	newFac.ai = uni.aiList[ranAI]:newAi(id, newFac.name)
  newFac.ai:init()
	return newFac
end

return fac