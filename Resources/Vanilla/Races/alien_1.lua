local names = require "/Lib/namegen"
local fact = require "/Classes/faction"

local fac = fact:newFaction(fac)

fac.race = names.randomName()
fac.atmo = uni.randomAtmo()

function fac:newFaction(id, name, homeStar, hp, ap, sp)
	local newFac = {}
	setmetatable(newFac, self)
	self.__index = self
	newFac.name = name
	newFac.facId = id
  --newFac.homePlanetId = homePlanetId
	newFac.homeStarId = homeStar
	newFac.cash = uni.factionCash
	newFac.hpBuff = hp
	newFac.apBuff = ap
	newFac.shBuff = sp
  --newFac:init()
	local ranAI = math.random(1, #uni.aiList)
	newFac.ai = uni.aiList[ranAI]:newAi(id, newFac.name)
  newFac.ai:init()
	return newFac
end

function fac:turn()

end

return fac