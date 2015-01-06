local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local names = require "/Lib/namegen"

local star = {}

function star:spawnStar(newStar)
    local newStar = newStar or {}
    setmetatable(newStar, self)
    self.__index = self
    return newStar
end

function star:addStation(id)
    local count = 1
    if self.stTab == nil then
        self.stTab = {}
    else
        count = #self.stTab + 1
    end
    self.stTab[count] = id
end

function star:addPlanet(id)
    local count = 1
    if self.plTab == nil then
        self.plTab = {}
    else
        count = #self.plTab + 1
    end
    self.plTab[count] = id
end

function star:findAppropriatePlanet(rad)
    if rad <= 5000 then
        return uni.planetClassLookup("Desert")
    elseif rad > 5000 and rad <= 25000 then
        local rType = math.random(1, 2)
        if rType == 1 then
            return uni.planetClassLookup("Desert")
        else
            return uni.planetClassLookup("Terran")
        end
    elseif rad > 25000 then
        local rType = math.random(1, 2)
        if rType == 1 then
            return uni.planetClassLookup("Ice")
        else
            return uni.planetClassLookup("Gas Giant")
        end
    end
end

function star:generateSystem()
  local rad = math.random(uni.planetMinRad, uni.planetMaxRad)
	for i = 1, self.maxPlanets do
		local angle = math.random(0, 359)
    local x, y = self.x + (rad * math.cos(angle)), (self.y + (rad * math.sin(angle)) / 2)
    local rcl = self:findAppropriatePlanet(rad)
    local class = uni.pTypes[rcl].class
    local rName = names.randomName()
    uni.spawnPlanet(rName, class, rad, self.id, uni.player, x, y)
    rad = rad + math.random(uni.planetMinRad, uni.planetMaxRad)
    self:addPlanet(uni.eCnt)
	end
  local lifeChance = math.random(1, uni.lifeChance)
  if lifeChance == uni.lifeChance then
    local fRace = math.random(1, #uni.factionList)
    local hpBuff = math.random(1, 10)
    local apBuff = math.random(1, 10)
    local spBuff = math.random(1, 10)
    local name = names.randomName()
    uni.spawnFaction(name, fRace, self.plTab[1], hpBuff, apBuff, spBuff)
  end
	for i = 1, self.maxAsteroids do
		
	end
end

function star:update(dt)
	
end

function star:move(dt)
	
end

function star:info(id)
	local info = win:newPane(info, 220, 340)
  info.shipId = self.id
  info.id = id
  info.name = uni.ent[info.shipId].name
  info.scrollPoint = 1
  info.priority = 9
	info.navScreen = true
	info.cargoScreen = false
  info:move(uni.xOff, uni.yOff)

  function info:statBars(x, y)
      self:box(x, y, self.width - (x * 2), 60, 0x00, 0x00, 0x00, uni.opacity)
      self:percentageBar(x + 2, y + 5, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].hp, uni.ent[self.shipId].hpMax)
      self:percentageBar(x + 2, y + 22, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].ap, uni.ent[self.shipId].apMax, 0x99, 0x99, 0x99, uni.opacity, 0x66, 0x66, 0x66, uni.opacity)
      self:percentageBar(x + 2, y + 39, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].sp, uni.ent[self.shipId].spMax, 0xFF, 0xFF, 0x00, uni.opacity, 0xFF, 0x00, 0x00, uni.opacity)
  end

  function info:econView(x, y, w, h)
      local boxRows = #uni.items --math.floor(h / 17)
      if self.scrollPoint > boxRows then
          if self.scrollPoint > #uni.items - boxRows then
              self.scrollPoint = #uni.items - boxRows
          end
      end
      local yOff = 0
      local prTab = uni.gatherStarProduction(self.shipId)
      local reTab = uni.gatherStarReagents(self.shipId)
      for i = self.scrollPoint, self.scrollPoint + boxRows - 1 do
          local amt = math.floor(uni.items[i].cost * uni.ent[self.shipId].econ[i])
          self:button(uni.items[i].name, "none", x, y + yOff, w / 2, 16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x99, 0x00, uni.opacity)
          self:button(amt, "none", x + (w / 2), y + yOff, (w / 2) / 3, 16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x99, 0x00, uni.opacity)
          self:button(prTab[i].amt, "none", x + (w / 2) + ((w / 2) / 3), y + yOff, (w / 2) / 3, 16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x99, 0x00, uni.opacity)
          self:button(reTab[i].amt, "none", x + (w / 2) + 2 * ((w / 2) / 3), y + yOff, (w / 2) / 3, 16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x99, 0x00, uni.opacity)
          yOff = yOff + 17
      end
  end

	function info:renderSetup()
		self:clear()
		self:backdrop()
		self:title(self.name, 0x00, 0x99, 0x99, uni.opacity)
		self:closeButton()
        if self.navScreen then
            self:button("Navigation", "nav_screen", 6, 23, (self.width - 15) / 2, 16, 0x00, 0x66, 0x99, uni.opacity)
            self:button("Trade", "cargo_screen", (self.width / 2) + 5, 23, (self.width - 15) / 2, 16, 0x00, 0x99, 0x99, uni.opacity)
            self:button("Dock", "follow_ship", 6, self.height - 22, self.width - 10, 16)
            self:statBars(6, self.height - 87)
            self:box(6, 44, self.width - 12, self.width - 12, 0x00, 0x00, 0x00, uni.opacity)
            self:setCamera(6, 44, self.width - 12, self.width - 12, uni.ent[self.shipId].x, uni.ent[self.shipId].y)
        elseif self.cargoScreen then
            self:button("Navigation", "nav_screen", 6, 23, (self.width - 15) / 2, 16, 0x00, 0x99, 0x99, uni.opacity)
            self:button("Trade", "cargo_screen", (self.width / 2) + 5, 23, (self.width - 15) / 2, 16, 0x00, 0x66, 0x99, uni.opacity)
            self:box(6, 46, self.width - 10, self.height - 50, 0x00, 0x00, 0x00, 255)
            self:econView(6, 46, self.width - 10, self.height - 50)
        end
	end

	function info:mousePressed(x, y)
		if self:isClicked(x, y) then
			local ret = self:buttonClicked(x, y)
			if ret ~= false then
				if ret == "close" then
					gameUtils.closeWindow(self.id)
				elseif ret == "nav_screen" then
					self.navScreen = true
                    self.cargoScreen = false
                elseif ret == "cargo_screen" then
					self.navScreen = false
                    self.cargoScreen = true
                elseif ret == "follow_ship" then
                    local list = uni.gatherSelectedTable()
                    for i = 1, #list do
                    	if uni.ent[list[i]].type == "ship" then
                            uni.ent[list[i]]:dockAtTarget(self.shipId)
                        end
                    end
				end
                self:render()
				return true
			end
			self.grabbed = true
			self.grabPointX = x - self.x
			self.grabPointY = y - self.y
			return true
		end
	end
    
    function info:updateCall()
        if self.navScreen then self:render() end
    end
    
	info:render()
	return info
end

return star