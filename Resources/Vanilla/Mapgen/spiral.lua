local names = require "/Lib/namegen"

local sp = {}

sp.spirals = 8
sp.spStars = 350
sp.spSpacing = 400
sp.uniSpin = 3.6

function sp:generate()
  uni.ent = nil
  local angle = 0
  for sp = 1, self.spirals do
    local rad = 10
    angle = angle + self.uniSpin
    for i = 1, self.spStars do
      local name = names.randomName()
      local rSt = math.random(1, #uni.starTypes)
      local stClass = uni.starTypes[rSt].class
      local x = rad * math.cos(angle)
      local y = rad * math.sin(angle)
      local stCh = math.random(1, 5)
      if stCh == 1 then
        uni.spawnStar(name, stClass, uni.player, x * self.spSpacing, y * self.spSpacing, angle)
      end
      rad = rad + self.spSpacing --math.random((self.spSpacing / 4) * 3, self.spSpacing)
      angle = angle + self.uniSpin --math.random(self.uniSpin / 1.2, self.uniSpin)
    end
  end
end

return sp