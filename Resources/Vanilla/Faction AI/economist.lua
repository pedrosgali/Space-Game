local win = require "/Lib/screen"
local bt = require "/Lib/behaviour"

--AI SETUP--
local ai = bt.inheritsFrom(bt.loop, "Main Trunk")

--CUSTOM LEAVES--
ai.testLeaf = bt.inheritsFrom(bt.node, "Test Leaf")
function ai.testLeaf:run()
  gameUtils.debug("Leaf success!")
  self.state = "passed"
end

--Check Systems:
--Gathers lists of nearby stars and finds good
ai.checkSystems = bt.inheritsFrom(bt.node)
function ai.checkSystems:gatherStarList()
  local id = self.id
  local homeStar = uni.factions[id].homeStarId
  local hx, hy = uni.ent[homeStar].x, uni.ent[homeStar].y
  local starTab = {}
  local count = 0
  for i = 1, #uni.starList do
    starTab[i] = uni.starList[i]
  end
  uni.factions[self.id].starList = {}
  uni.factions[self.id].starList[1] = {}
  uni.factions[self.id].starList[1].id = homeStar
  uni.factions[self.id].starList[1].dist = 0
  uni.factions[self.id].starList[1].owned = true
  for i = 1, #starTab do
    if starTab[i] ~= nil and starTab[i] ~= homeStar then
      local star = starTab[i]
      local tx, ty = uni.ent[star].x, uni.ent[star].y
      local id = 1
      local minDist = uni.getDistance(hx, hy, tx, ty)
      for j = 1, #starTab do
        if starTab[j] ~= nil and starTab[j] ~= homeStar then
          local tx, ty = uni.ent[starTab[j]].x, uni.ent[starTab[j]].y
          local dist = uni.getDistance(hx, hy, tx, ty)
          if dist < minDist then
            id = j
            minDist = dist
          end
        end
      end
      count = count + 1
      uni.factions[self.id].starList[count] = {}
      uni.factions[self.id].starList[count].id = id
      uni.factions[self.id].starList[count].dist = minDist
      uni.factions[self.id].starList[count].owned = false
      starTab[id] = nil
    end
  end
end

function ai.checkSystems:gatherPlanetList()
  local id = self.id
  local homePlanet = uni.factions[id].homePlanetId
  local count = 1
  uni.factions[self.id].plTab = {}
  uni.factions[self.id].plTab[count] = {}
  uni.factions[self.id].plTab[count].id = homePlanet
  uni.factions[self.id].plTab[count].atmo = uni.ent[homePlanet].atmo
  uni.factions[self.id].plTab[count].owned = true
  for i = 1, #uni.factions[id].starList do
    local star = uni.factions[id].starList[i].id
    if uni.ent[star].plTab ~= nil then
      for j = 1, #uni.ent[star].plTab do
        local planet = uni.ent[star].plTab[j]
        if planet ~= homePlanet then
          count = count + 1
          uni.factions[self.id].plTab[count] = {}
          uni.factions[self.id].plTab[count].id = homePlanet
          uni.factions[self.id].plTab[count].atmo = uni.ent[homePlanet].atmo
          uni.factions[self.id].plTab[count].owned = false
        end
      end
    end
  end
end

function ai.checkSystems:gatherLists()
  self:gatherStarList()
  self:gatherPlanetList()
end

function ai.checkSystems:run()
  if uni.factions[self.id].starList == nil and uni.starList ~= nil and uni.factions[self.id].homePlanetId ~= nil then
    self:gatherLists()
    self.state = "passed"
  else
    self.state = "passed"
  end
end

--Gather Ships:
--Gathers lists of Idle Ships.
ai.getShipLists = bt.inheritsFrom(bt.node)
function ai.getShipLists:gatherFactionShips()
    local list = uni.searchList("ship", "all", uni.factions[self.id].name)
    uni.factions[self.id].shipTab = {}
    for i = 1, #list do
      uni.factions[self.id].shipTab[i] = {}
      uni.factions[self.id].shipTab[i].id = list[i]
      uni.factions[self.id].shipTab[i].state = "idle"
    end
end

function ai.getShipLists:gatherIdleShips()
  
end

function ai.getShipLists:run()
  if uni.factions[self.id].shipTab == nil then
    self:gatherFactionShips()
    self.state = "passed"
  else
    self:gatherIdleShips()
    self.state = "passed"
  end
end

--AI SPAWNING--

function ai:newAi(id, name)
  local newFac = {}
	setmetatable(newFac, self)
	self.__index = self
	newFac.id = id
  newFac.name = name
  newFac:add(bt.sequence, "Explore", id)
    newFac.ch[1]:add(ai.checkSystems, "Check Systems", id)
    newFac.ch[1]:add(bt.sequence, "Ship Sequence", id)
      newFac.ch[1].ch[2]:add(ai.getShipLists, "Gather Ships", id)
      newFac.ch[1].ch[2]:add(ai.testLeaf, "Assign fleet ships", id)
      newFac.ch[1].ch[2]:add(bt.sequence, "Move Ships Sequence", id)
        newFac.ch[1].ch[2].ch[3]:add(ai.testLeaf, "Explorer Ships", id)
        newFac.ch[1].ch[2].ch[3]:add(ai.testLeaf, "Colony Ships", id)
  newFac:add(bt.sequence, "Exchange", id)
    newFac.ch[2]:add(ai.testLeaf, "Trade Stuff", id)
    newFac.ch[2]:add(ai.testLeaf, "Build Stuff", id)
  newFac:init()
	return newFac
end

return ai