------------------------------------
-- File Name  : triral.lua
-- Description: Galaxy creation code
-- Edited By  : Simon Wright
-- Date       : 19 Dec 2014
------------------------------------

local names = require "/Lib/namegen"

local sp = {}

-- Variables
sp.armWidth = 3    -- Number of iterations over each arm
sp.stars = 300      -- Number of stars per arm
sp.spacing = 400    -- Space between stars
sp.density = 3      -- Density of stars, higher number is less dense
sp.uniSpin = 0.02   -- Angle of each arm's curve, really sensitive, default is 0.02

--Generation Code
function sp:generate()
  uni.ent = nil
  local angle = 0
  for sp = 1, (self.armWidth * 3) do
    local radius = 3000
    angle = 90 * sp
    for i = 1, math.floor(self.stars / math.ceil(sp / 3)) do
      local name = names.randomName()
      local rSt = math.random(1, #uni.starTypes)
      local stClass = uni.starTypes[rSt].class
      local x = (radius * math.cos(angle)) + math.random(-5000, 5000)
      local y = (radius * math.sin(angle)) + math.random(-5000, 5000)
      local stCh = math.random(1, self.density)
      if stCh == 1 then
        uni.spawnStar(name, stClass, uni.player, x * self.spacing, y * self.spacing, angle)
      end
      radius = radius + self.spacing
      angle = angle + self.uniSpin
    end
  end
end

return sp