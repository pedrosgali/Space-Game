local bt = require "/Lib/behaviour"

local ai = {}

--Pass Leaf:
--Good for testing, always returns "passed".
ai.passLeaf = bt.inheritsFrom(bt.node, "Test Leaf")
function ai.passLeaf:run()
  self.state = "passed"
end


--Check Systems:
--Gathers lists of nearby stars and planets
ai.checkSystems = bt.inheritsFrom(bt.node, "Check Systems")
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
ai.getShipLists = bt.inheritsFrom(bt.node, "Gather Ship Lists")
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
  local count = 0
  uni.factions[self.id].idleTab = nil
  uni.factions[self.id].idleTab = {}
  for i = 1, #uni.factions[self.id].shipTab do
    if uni.factions[self.id].shipTab[i].state == "idle" then
      count = count + 1
      uni.factions[self.id].idleTab[count] = uni.factions[self.id].shipTab[i].id
    end
  end
end

function ai.getShipLists:run()
  if uni.factions[self.id].shipTab == nil then
    self:gatherFactionShips()
    self:gatherIdleShips()
    self.state = "passed"
  else
    self:gatherIdleShips()
    self.state = "passed"
  end
end


--Build Ship:
--Builds another ship that the AI can use
--Call as:
--ai.ch[etc]:add(ai.buildShip, nodeName, facId, class, type)
ai.buildShip = bt.inheritsFrom(bt.node, "Build Ship")
function ai.buildShip:run()
  local name = uni.factions[self.id].name.." "..self.name
  uni.spawnShip(name, self.name, self.id, uni.factions[self.id].homePlanetId)
  local id = #uni.factions[self.id].shipTab + 1
  uni.factions[self.id].shipTab[id] = {}
  uni.factions[self.id].shipTab[id].id = uni.eCnt
  uni.factions[self.id].shipTab[id].state = "idle"
  self.state = "passed"
end


--Check Cash:
--Checks Faction cash against the name you give it (put the number as a string when you add the node eg: "50000")
ai.checkCash = bt.inheritsFrom(bt.node, "Check Cash")
function ai.checkCash:run()
  local amt = tonumber(self.name)
  if uni.factions[self.id].cash > amt then
    self.state = "passed"
  else
    self.state = "failed"
  end
end


--Set Ship Type:
--Sets an AI ship to the specified type
return ai