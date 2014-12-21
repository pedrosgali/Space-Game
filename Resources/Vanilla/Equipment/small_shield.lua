local eq = require "/Classes/equipment"
local names = require "/Lib/namegen"

local equip = eq:newEquipment(equip)
equip.name = "Small shield generator"
equip.slot = "Aux"
equip.type = "ship"

function equip:equipItem()
    local item = {}
    setmetatable(item, self)
    self.__index = self
    item.sp = 0
    item.spMax = 100
    item.shRecharge = .5
    return item
end

function equip:onEquip()
    self.sp = 0
    uni.ent[self.id].spMax = uni.ent[self.id].spMax + self.spMax
    uni.ent[self.id]:logEntry("Shields initiated.")
end

function equip:onRemove()
    uni.ent[self.id].sp = uni.ent[self.id].sp - self.sp
    uni.ent[self.id].spMax = uni.ent[self.id].spMax - self.spMax
    uni.ent[self.id]:logEntry("Shields removed.")
end

function equip:onUpdate(dt)
  dt = dt * uni.gameSpeed
  if uni.ent[self.id].sp < uni.ent[self.id].spMax then
    uni.ent[self.id].sp = math.min(uni.ent[self.id].sp + (self.shRecharge * dt), self.spMax)
    uni.ent[self.id]:logEntry("Shields charging..."..uni.ent[self.id].sp)
  end
end

return equip