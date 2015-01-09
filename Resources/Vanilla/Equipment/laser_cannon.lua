local eq = require "/Classes/equipment"
local maths = require "/Lib/maths"

local wep = eq:newEquipment()
wep.name = "Small Laser Cannon"
wep.slot = "Small Weapon"
wep.type = "ship"

function wep:equipItem()
  local item = {}
  setmetatable(item, self)
  self.__index = self
  item.target = 0
  item.chargeLevel = 100
  item.chargeMax = item.chargeLevel
  item.recharge = 10
  item.range = 10000
  item.damage = 50
  item.crit = "Shields"
  item.ammo = 20
  return item
end

function wep:setTarget(id)
  uni.ent[self.id]:logEntry("Target aquired.")
  self.target = id
end

function wep:onUpdate(dt)
  dt = dt * uni.gameSpeed
  if self.chargeLevel < self.chargeMax then
    self.chargeLevel = self.chargeLevel + (self.recharge * dt)
  end
  if self.target ~= 0 then
    local x, y = uni.ent[self.id].x, uni.ent[self.id].y
    local tx, ty = uni.ent[self.target].x, uni.ent[self.target].y
    if uni.getDistance(x, y, tx, ty) < self.range then
      if self.chargeLevel > self.ammo then
        love.graphics.setColor(0xFF, 0x00, 0x00, 0xFF)
        x, y = uni.getScreenCoordinates(x, y)
        tx, ty = uni.getScreenCoordinates(tx, ty)
        love.graphics.line(x, y, tx, ty)
        love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
        if uni.ent[self.target]:takeDamage(self.damage, self.crit) then
          self.target = 0
        end
      end
    end
  end
end

function wep:onFire()
  
end

return wep