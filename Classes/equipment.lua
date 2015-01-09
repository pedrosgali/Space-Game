local eq = {}

function eq:newEquipment()
    local newEq = {}
    setmetatable(newEq, self)
    self.__index = self
    return newEq
end

function eq:onEquip()
  
end

function eq:onRemove()
  
end

function eq:onFire()
  
end

function eq:onMove()
  
end

function eq:onUpdate()
  
end

return eq