local eq = require "/Classes/equipment"
local names = require "/Lib/namegen"

local equip = eq:newEquipment(equip)
equip.name = "Small Jumpdrive"
equip.slot = "Engine"
equip.type = "ship"

function equip:equipItem()
    local item = {}
    setmetatable(item, self)
    self.__index = self
    item.canJump = true
    item.jCount = 10
    item.range = 25000
    item.spd = 500000
    return item
end

function equip:onMove(dt)
  if self.tgtx ~= "none" then
    if uni.getDistance(uni.ent[self.id].x, uni.ent[self.id].y, uni.ent[self.id].tgtx, uni.ent[self.id].tgty) > self.range then
      if self.canJump then
        local h = math.deg(uni.ent[self.id].heading)
        local b = math.deg(uni.ent[self.id].bearing)
        local spd = self.spd
        if h >= b - 89 and h <= b + 89 then
          self.xVel = (math.cos(uni.ent[self.id].heading) * spd) * (dt * uni.gameSpeed)
          self.yVel = (math.sin(uni.ent[self.id].heading) * spd) * (dt * uni.gameSpeed)
          uni.ent[self.id].x = uni.ent[self.id].x + self.xVel
          uni.ent[self.id].y = uni.ent[self.id].y + self.yVel
        end
      end
    else
      self.canJump = false
    end
  else
    self.canJump = false
  end
end

function equip:onUpdate(dt)
  if not self.canJump then
    self.jCount = math.max(self.jCount - 1 * (dt * uni.gameSpeed), 0)
  end
  if self.jCount == 0 then
    self.jCount = 10
    self.canJump = true
  end
end

return equip