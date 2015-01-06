local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local names = require "/Lib/namegen"
local eqCl = require "/Classes/equipment"

local ai = eqCl:newEquipment(ai)

ai.name = "Basic Combat AI"
ai.slot = "AI"
ai.type = "ship"

function ai:equipItem()
	local newAi = {}
	setmetatable(newAi, self)
	self.__index = self
	return newAi
end

function ai:checkWeapons()
  local wCount = 1
  self.weapons = {}
  for i = 1, #uni.ent[self.id].eqTab do
    if uni.ent[self.id].eqTab[i].equipped ~= nil then
      if uni.ent[self.id].eqTab[i].equipped.slot == "Weapon" then
        self.weapons[wCount] = i
        wCount = wCount + 1
      end
    end
  end
end

function ai:onEquip()
    self.timer = 0
    self.tick = 30
    self:checkWeapons()
    self:gatherTargets()
    self.target = 0
end

function ai:logEntry(msg, clear)
    uni.ent[self.id]:logEntry(msg, clear)
end

function ai:gatherTargets()
  self.ships = {}
  self.stations = {}
  local shipCount = 1
  local statCount = 1
  for i = 1, #uni.ent do
    if uni.ent[i].faction ~= uni.ent[self.id].faction then
      if uni.ent[i].type == "ship" then
        self.ships[shipCount] = i
        shipCount = shipCount + 1
        self:logEntry("Ship Added, Id: "..i)
      elseif uni.ent[i].type == "station" then
        self.stations[statCount] = i
        statCount = statCount + 1
        self:logEntry("Station Added, Id: "..i)
      end
    end
  end
end

function ai:findTarget()
  for i = 1, #self.ships do
    local x, y = uni.ent[self.id].x, uni.ent[self.id].y
    local tx, ty = uni.ent[self.ships[i]].x, uni.ent[self.ships[i]].y
    local dist = uni.getDistance(x, y, tx, ty)
    for j = 1, #self.weapons do
      local range = uni.ent[self.id].eqTab[self.weapons[j]].equipped.range
      if dist >= x - range and dist <= x + range then
        if dist >= y - range and dist <= y + range then
          self.target = self.ships[i]
          return true
        end
      end
    end
  end
end

function ai:lockWeapons()
  for i = 1, #self.weapons do
    local name = uni.ent[self.id].eqTab[self.weapons[i]].equipped.name
    uni.ent[self.id].eqTab[self.weapons[i]].equipped:setTarget(self.target)
    self:logEntry(name.." locked.")
  end
end

function ai:findClosestEnemy()
  local tDist = 0
  local closest = 0
  for i = 1, #self.ships do
    local x, y = uni.ent[self.id].x, uni.ent[self.id].y
    local tx, ty = uni.ent[self.ships[i]].x, uni.ent[self.ships[i]].y
    local dist = uni.getDistance(x, y, tx, ty)
    if i == 1 then
      tDist = dist
      closest = self.ships[i]
    else
      if dist < tDist then
        tDist = dist
        closest = self.ships[i]
      end
    end
  end
  return closest
end

function ai:combatTurn()
  if uni.ent[self.id].aggressive then
    if self.target == 0 then
      self:logEntry("No target, searching...")
      self.target = self:findClosestEnemy()
      self:lockWeapons(self.target)
    else
      uni.ent[self.id]:handleTargeting(uni.ent[self.target].x - 100, uni.ent[self.target].y - 100)
    end
  elseif uni.ent[self.id].defensive then
    
  end
end

function ai:onUpdate(dt)
  dt = dt * uni.gameSpeed
  self.timer = self.timer + dt
  if self.timer > self.tick then
    self.timer = 0
    self:combatTurn()
  end
end

return ai