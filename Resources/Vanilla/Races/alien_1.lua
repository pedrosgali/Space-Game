local names = require "/Lib/namegen"
local fact = require "/Classes/faction"

local fac = fact:newFaction(fac)

fac.race = names.randomName()
fac.atmo = uni.randomAtmo()

function fac:newFaction(newFac, id, name, homePlanetId, hp, ap, sp)
	local newFac = newFac or {}
	setmetatable(newFac, self)
	self.__index = self
	newFac.name = name
	newFac.facId = id
  newFac.homePlanetId = homePlanetId
	newFac.homeStarId = uni.ent[homePlanetId].homeStarId
	newFac.cash = uni.factionCash
	newFac.hpBuff = hp
	newFac.apBuff = ap
	newFac.shBuff = sp
	local ranAI = math.random(1, #uni.aiList)
	newFac.ai = uni.aiList[ranAI]:newAi(newFac.ai, id)
	return newFac
end

function fac:turn()

end

return fac