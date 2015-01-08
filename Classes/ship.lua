local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local item = require "/Classes/item"

local sh = {}

--SHIP API FUNCTIONS--

function sh:spawnShip(newShip)
	local newShip = newShip or {}
	setmetatable(newShip, self)
	self.__index = self
  newShip.xVel = 0
  newShip.yVel = 0
  newShip.tgtx = "none"
  newShip.tgty = "none"
  newShip.scrx = "none"
  newShip.scry = "none"
  newShip.docked = 0
  newShip.docking = 0
  newShip.orbit = 0
  newShip.state = "Idle"
	return newShip
end

--BASIC SHIP FUNCTIONS--

function sh:setHome(id)
  self.home = id
end

function sh:setLocation(x, y)
  self.x, self.y = x, y
end

function sh:logEntry(msg)
    local count = 1
    if self.log == nil then
        self.log = {}
    elseif #self.log >= uni.maxShipLog then
        local newLog = {}
        for i = 2, #self.log do
            newLog[i - 1] = self.log[i]
        end
        self.log = newLog
        count = #self.log + 1
    else
        count = #self.log + 1
    end
    self.log[count] = msg
    local winId = gameUtils.checkOpen(self.id)
    if gameUtils.checkOpen(self.id) then
        cWin[winId].logPoint = #self.log
        cWin[winId]:render()
    end
end

function sh:findClosestStar()
  local stId = uni.starList[1]
  local dist = uni.getDistance(self.x, self.y, uni.ent[stId].x, uni.ent[stId].y)
  local closest = stId
  for i = 2, #uni.starList do
    stId = uni.starList[i]
    local newDist = uni.getDistance(self.x, self.y, uni.ent[stId].x, uni.ent[stId].y)
    if newDist < dist then
      dist = newDist
      closest = uni.starList[i]
    end
  end
  return closest
end

--BASIC MOVEMENT FUNCTIONS--

function sh:setTarget(x, y)
    self:handleTargeting(x, y)
    self:logEntry("Moving to X: "..x.." Y: "..y)
end

function sh:handleTargeting(x, y)
  self.tgtx = x
  self.tgty = y
  self.docking = 0
  self.docked = 0
  self.orbit = 0
  self.orbitFound = false
end

function sh:getBearing()
	local dx = self.tgtx - self.x
	local dy = self.tgty - self.y
  local bearing = math.atan2(dy,dx)
  return bearing
end

function sh:findBearing(dt)
	if self.heading ~= self.bearing then
		self.heading = self.bearing
	end
	self.vizHeading = maths.rectifyRads(self.heading)
end

function sh:setVelocity(dt)
    local h = math.deg(self.heading)
    local b = math.deg(self.bearing)
    local spd = self.spd
    local dist = uni.getDistance(self.x, self.y, self.tgtx, self.tgty)
    if spd > dist then spd = math.max(dist * 2, 1) end
    if h >= b - 89 and h <= b + 89 then
        self.xVel = (math.cos(self.heading) * spd) * (dt * uni.gameSpeed) 
        self.yVel = (math.sin(self.heading) * spd) * (dt * uni.gameSpeed)
    end
end

function sh:move(dt)
	if self.tgtx ~= "none" then
    if self.docking ~= 0 then
        self:handleDock(self.docking)
    end
    self.docked = 0
		self.bearing = self:getBearing()
		self:findBearing(dt)
		if not uni.isPaused then
			self:setVelocity(dt)
			self:setLocation(self.x + self.xVel, self.y + self.yVel)
      if self.eqTab ~= nil then
        for i = 1, #self.eqTab do
          if self.eqTab[i].equipped ~= nil then
            self.eqTab[i].equipped:onMove(dt)
          end
        end
      end
		end
		if math.floor(self.x) >= self.tgtx - uni.catchArea and math.floor(self.x) <= self.tgtx + uni.catchArea then
			if math.floor(self.y) >= self.tgty - uni.catchArea and math.floor(self.y) <= self.tgty + uni.catchArea then
				self.tgtx = "none"
				self.tgty = "none"
				self.xVel = 0
				self.yVel = 0
				self.x = math.floor(self.x)
				self.y = math.floor(self.y)
        self.star = self:findClosestStar()
        if self.docking ~= 0 then
          self.docked = self.docking
          self.docking = 0
        elseif self.orbit ~= 0 then
          local dx = uni.ent[self.orbit].x - self.x
          local dy = uni.ent[self.orbit].y - self.y
          local bearing = math.deg(math.atan2(dy,dx))
          self.heading = math.rad(bearing + 180)
          self.rad = uni.getDistance(self.x, self.y, uni.ent[self.orbit].x, uni.ent[self.orbit].y)
          self.orbitFound = true
        end
			end
		end
  elseif self.orbitFound then
      self:orbitPlanet(dt)
  elseif self.orbit ~= 0 then
      self:moveToOrbit(self.orbit)
	end
end

--ADVANCED MOVE FUNCTIONS--

function sh:dockAtTarget(id)
    self:logEntry("Docking at: "..uni.ent[id].name)
    self:setTarget(uni.ent[id].x, uni.ent[id].y)
    self.docking = id
end

function sh:handleDock(id)
    self:handleTargeting(uni.ent[id].x, uni.ent[id].y)
    self.docking = id
end

function sh:setOrbit(id)
    self.rad = math.random(uni.statMaxRad, uni.statMaxRad + 200)
    self.orbit = id
    self.orbitFound = false
    self:logEntry("Moving to orbit "..uni.ent[id].name)
end

function sh:orbitPlanet(dt)
  dt = dt * uni.gameSpeed
  self.heading = self.heading + ((self.rad / 500000) * dt)
  self.x = uni.ent[self.orbit].x + (self.rad * math.cos(self.heading))
	self.y = uni.ent[self.orbit].y + (self.rad * math.sin(self.heading))
end

function sh:moveToOrbit(id)
    local dist = uni.getDistance(self.x, self.y, uni.ent[id].x, uni.ent[id].y)
    if dist >= self.rad + 20 and dist <= self.rad - 20 then
        self.rad = dist
        self.orbitFound = true
    else
        self:handleTargeting(uni.ent[id].x + self.rad, uni.ent[id].y + self.rad)
        self.orbit = id
    end
end

--BASIC BUY FUNCTIONS--

function sh:addItem(id, amt, cost)
    local count = 1
    if self.cargo == nil then
        self.cargo = {}
    else
        count = #self.cargo + 1
        for i = 1, #self.cargo do
            if self.cargo[i].id == id then
                local oldTot = self.cargo[i].amt * self.cargo[i].cost
                local newTot = oldTot + cost
                local goodsTot = self.cargo[i].amt + amt
                local avgCost = math.ceil(goodsTot / newTot)
                self.cargo[i].amt = goodsTot
                self.cargo[i].cost = avgCost
                return
            end
        end
    end
    self.cargo[count] = {}
    self.cargo[count].id = id
    self.cargo[count].amt = amt
    self.cargo[count].cost = math.ceil(cost / amt)
end

function sh:checkHold(id, amt)
    local spaceNeeded = uni.items[id].bulk * amt
    local spaceLeft = self.cargoMax - self.stored
    if spaceLeft >= spaceNeeded then
        return amt
    else
        local newAmt = math.floor(spaceLeft / uni.items[id].bulk)
        self:logEntry("Can only hold: "..tostring(newAmt))
        return newAmt
    end
end

function sh:buyAction(stId, pId, amt)
    local itId = uni.ent[stId].productList[pId].item
    local cashPer = uni.ent[stId].productList[pId].cost
    local totCost = amt * cashPer
    --uni.ent[self.home].cash = uni.ent[self.home].cash - totCost
    uni.ent[stId].productList[pId].amt = uni.ent[stId].productList[pId].amt - amt
    self:addItem(itId, amt, totCost)
    self:logEntry("Goods bought for: "..totCost)
    return totCost
end

function sh:buyWares(stId, itId, amt)
    if self.docked == stId then
        self:logEntry("Buying "..amt.." "..uni.items[itId].name..".")
        amt = self:checkHold(itId, amt)
        local bool, pId, amt = uni.ent[stId]:hasItem(itId, amt)
        if pId ~= nil and amt > 0 then
            if bool and amt > 0 then
                local cost = self:buyAction(stId, pId, amt)
                return cost, amt
            end
        end
    end
    return false
end

--BASIC SELL FUNCTIONS--

function sh:removeItem(itId, amt)
    if self.cargo ~= nil then
        for i = 1, #self.cargo do
            if self.cargo[i].id == itId then
                if amt < self.cargo[i].amt then
                    self.cargo[i].amt = self.cargo[i].amt - amt
                    self.stored = self.stored - (self.cargo[i].amt * uni.items[itId].bulk)
                else
                    if #self.cargo == 1 then
                        self.cargo = nil
                        self.stored = 0
                        return
                    end
                    local newTab = {}
                    local count = 1
                    for j = 1, #self.cargo do
                        if j ~= i then
                            newTab[count] = self.cargo[j]
                            count = count + 1
                        else
                            self.stored = self.stored - (self.cargo[i].amt * uni.items[itId].bulk)
                        end
                    end
                    self.cargo = newTab
                end
            end
        end
    end
end

function sh:sellAction(stId, pId, amt)
    local itId = uni.ent[stId].reagentList[pId].item
    local cost = uni.ent[stId].reagentList[pId].cost
    uni.ent[stId].reagentList[pId].amt = uni.ent[stId].reagentList[pId].amt + amt
    --uni.ent[self.home].cash = uni.ent[self.home].cash + (cost * amt)
    self:removeItem(itId, amt)
    self:logEntry("Goods sold.")
    return cost * amt
end

function sh:sellWares(stId, itId, amt)
    if self.docked == stId then
        self:logEntry("Selling "..amt.." "..uni.items[itId].name..".")
        local bool, pId, amt = uni.ent[stId]:willBuy(itId, amt)
        amt = uni.factions[self.facId]:canBuyX(stId, pId, amt)
        if bool then
            totSale = self:sellAction(stId, pId, amt)
            return totSale
        end
    end
    return false
end

--EQUIPMENT FUNCTIONS--

function sh:addEqSlot(slot)
    local count = 1
    if self.eqTab == nil then
        self.eqTab = {}
    else
        count = #self.eqTab + 1
    end
    self.eqTab[count] = {}
    self.eqTab[count].slot = slot
end

--COMBAT FUNCTIONS--

function sh:damageShields(amt, crit)
  if crit == "Shields" then amt = amt * 2 end
  for i = 1, #self.eqTab do
    if self.eqTab[i].equipped ~= nil then
      if self.eqTab[i].slot == "Shield" then
        if self.eqTab[i].sp >= amt then
          self.eqTab[i].sp = self.eqTab[i].sp - amt
          return 0
        else
          amt = amt - self.eqTab[i].sp
          self.eqTab[i].sp = 0
        end
      end
    end
  end
  if crit == "Shields" then amt = math.floor(amt / 2) end
  return amt
end

function sh:damageArmour(amt, crit)
  if crit == "Armour" then amt = amt * 2 end
  for i = 1, #self.eqTab do
    if self.eqTab[i].equipped ~= nil then
      if self.eqTab[i].slot == "Armour" then
        if self.eqTab[i].ap >= amt then
          self.eqTab[i].ap = self.eqTab[i].ap - amt
          return 0
        else
          amt = amt - self.eqTab[i].ap
          self.eqTab[i].ap = 0
        end
      end
    end
  end
  if crit == "Armour" then amt = amt / 2 end
  return amt
end

function sh:damageHull(amt, crit)
  if crit == "Hull" then amt = amt * 2 end
  self.hp = self.hp - amt
  return amt
end

function sh:takeDamage(amt, crit)
  amt = self:damageShields(amt, crit)
  amt = self:damageArmour(amt, crit)
  amt = self:damageHull(amt, crit)
  if amt > 0 then
    self.dead = true
    return true
  end
end

function sh:onCombat(dt)
  
end

--UPDATE CALLS--

function sh:update(dt)
  if self.facId == nil then self.facId = uni.factionLookup(self.faction) end
  if self.docked ~= 0 then
    self.x = uni.ent[self.docked].x
    self.y = uni.ent[self.docked].y
  end
  if self.eqTab ~= nil then
    for i = 1, #self.eqTab do
      if self.eqTab[i].equipped ~= nil then
        self.eqTab[i].equipped:onUpdate(dt)
      end
    end
  end
end

--SHIP INFORMATION DISPLAY--

function sh:info(id)
	local info = win:newPane(info, 220, 340)
    info.shipId = self.id
    info.id = id
    info.name = uni.ent[info.shipId].name
    info.priority = 9
    info.logPoint = 1
    info.tabCount = 4
    info.navScreen = false
    info.cargoScreen = false
    info.logScreen = true
    info.eqScreen = false
    info:move(uni.xOff, uni.yOff)
    
    function info:tabs()
      local tabSpaces = self.tabCount * 5 + 5
      local btnw = math.floor(self.width - tabSpaces) / self.tabCount
      if self.navScreen then
        self:button("View", "nav_screen", 6, 23, btnw, 16, 0x00, 0x66, 0x99, uni.opacity)
      else
        self:button("View", "nav_screen", 6, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
      end
      if self.cargoScreen then
        self:button("Cargo", "cargo_screen", btnw + 10, 23, btnw, 16, 0x00, 0x66, 0x99, uni.opacity)
      else
        self:button("Cargo", "cargo_screen", btnw + 10, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
      end
      if self.logScreen then
        self:button("Log", "log_screen", (btnw * 2) + 15, 23, btnw, 16, 0x00, 0x66, 0x99, uni.opacity)
      else
        self:button("Log", "log_screen", (btnw * 2) + 15, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
      end
      if self.eqScreen then
        self:button("Equip", "eq_screen", (btnw * 3) + 20, 23, btnw, 16, 0x00, 0x66, 0x99, uni.opacity)
      else
        self:button("Equip", "eq_screen", (btnw * 3) + 20, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
      end
    end
    
    function info:statBars(x, y)
        self:box(x, y, self.width - (x * 2), 60, 0x00, 0x00, 0x00, uni.opacity)
        self:percentageBar(x + 2, y + 5, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].hp, uni.ent[self.shipId].hpMax)
        self:percentageBar(x + 2, y + 22, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].ap, uni.ent[self.shipId].apMax, 0x99, 0x99, 0x99, uni.opacity, 0x66, 0x66, 0x66, uni.opacity)
        self:percentageBar(x + 2, y + 39, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].sp, uni.ent[self.shipId].spMax, 0xFF, 0xFF, 0x00, uni.opacity, 0xFF, 0x00, 0x00, uni.opacity)
    end

    function info:logPrint(x, y, w, h)
        self:box(x, y, w, h, 0x00, 0x00, 0x00, uni.opacity)
        if uni.ent[self.shipId].log ~= nil then
            local yOff = y + 5
            local boxHeight = math.floor((h / 17) - 2)
            local startPoint = 1
            if self.logPoint > boxHeight then
                startPoint = #uni.ent[self.shipId].log - boxHeight
            end
            for i = startPoint, startPoint + boxHeight do
                if uni.ent[self.shipId].log[i] ~= nil then
                    self:text(uni.ent[self.shipId].log[i], 8, yOff, 0x00, 0x99, 0x00, uni.opacity)
                    yOff = yOff + 17
                end
            end
        end
    end
  
  function info:equipmentView()
    local yOff = 46
    self:box(6, yOff, self.width - 12, self.width - 12, 0x00, 0x00, 0x00, uni.opacity)
    if uni.ent[self.shipId].eqTab ~= nil then
      for i = 1, # uni.ent[self.shipId].eqTab do
        self:text(uni.ent[self.shipId].eqTab[i].slot..": ", 6, yOff, 0x00, 0x99, 0x00, uni.opacity)
        if uni.ent[self.shipId].eqTab[i].equipped ~= nil then
          self:button(uni.ent[self.shipId].eqTab[i].equipped.name, "none", self.width / 3 + 2, yOff, ((self.width - 10) / 3) * 2, 16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x99, 0x00, uni.opacity)
        else
          self:button("Empty", "none", self.width / 3 + 2, yOff, ((self.width - 10) / 3) * 2, 16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x99, 0x00, uni.opacity)
        end
        yOff = yOff + 17
      end
    end
  end
  
	function info:renderSetup()
		self:clear()
		self:backdrop()
		self:title(self.name, 0x00, 0x99, 0x99, uni.opacity)
		self:closeButton()
    self:tabs()
    if self.navScreen then
        self:button("Follow", "follow_ship", 6, self.height - 22, self.width - 10, 16)
        self:statBars(6, self.height - 87)
        self:box(6, 44, self.width - 12, self.width - 12, 0x00, 0x00, 0x00, uni.opacity)
        self:setCamera(6, 44, self.width - 12, self.width - 12, uni.ent[self.shipId].x, uni.ent[self.shipId].y)
    elseif self.cargoScreen then
        self:button("Follow", "follow_ship", 6, self.height - 22, self.width - 10, 16)
        self:box(6, 46, self.width - 10, self.height - 50, 0x00, 0x00, 0x00, uni.opacity)
        if uni.ent[self.shipId].cargo ~= nil then
            local yOff = 46
            for i = 1, #uni.ent[self.shipId].cargo do
                local amt = uni.ent[self.shipId].cargo[i].amt
                local name = uni.items[uni.ent[self.shipId].cargo[i].id].name
                local cost = uni.ent[self.shipId].cargo[i].cost
                self:text(amt.." x "..name..". ("..cost.." Um)", 8, yOff, 0x00, 0x99, 0x00, uni.opacity)
                yOff = yOff + 22
            end
        end
    elseif self.logScreen then
        self:button("Follow", "follow_ship", 6, self.height - 22, self.width - 10, 16)
        self:logPrint(6, 46, self.width - 10, self.height - 74)
    elseif self.eqScreen then
        self:equipmentView()
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
            self.logScreen = false
            self.eqScreen = false
        elseif ret == "cargo_screen" then
            self.navScreen = false
            self.cargoScreen = true
            self.logScreen = false
            self.eqScreen = false
        elseif ret == "log_screen" then
            self.navScreen = false
            self.cargoScreen = false
            self.logScreen = true
            self.eqScreen = false
        elseif ret == "eq_screen" then
            self.navScreen = false
            self.cargoScreen = false
            self.logScreen = false
            self.eqScreen = true
        elseif ret == "follow_ship" then
            uni.selected = self.shipId
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

return sh