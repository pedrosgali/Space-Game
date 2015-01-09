local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local names = require "/Lib/namegen"
local aiCl = require "/Classes/equipment"

local ai = aiCl:newEquipment(ai)

ai.name = "Supplier AI"
ai.slot = "AI"
ai.type = "station"
ai.shipBuyPoint = 10000000
ai.maxShips = 2

function ai:equipItem()
	local stAi = {}
	setmetatable(stAi, self)
	self.__index = self
	return stAi
end

function ai:onEquip()
    self.timer = 0
    self.tick = 30
end

function ai:logEntry(msg, clear)
    uni.ent[self.id]:logEntry(msg, clear)
end

function ai:buyShip(class)
	local count = 1
	if self.shipTab == nil then
		self.shipTab = {}
	else
		count = #self.shipTab + 1
	end
	if count > self.maxShips then return end
	local syId = uni.shipClassLookup(class)
	uni.ent[self.id].cash = uni.ent[self.id].cash - uni.shipyard[syId].cost
	local name = uni.ent[self.id].class.." trader "..count
	uni.spawnShip(name, class, "Civilian", self.id)
	uni.ent[uni.eCnt].selected = true --Delete this later..
	self.shipTab[count] = {}
	self.shipTab[count].shipId = uni.eCnt
	self.shipTab[count].state = "Idle"
	self.shipTab[count].target = 0
	self.shipTab[count].product = 0
end

function ai:bestBuyInSector(star, pId)
	local econ = uni.ent[star].econ
	local stList = uni.ent[star].stTab
	local itId = uni.ent[self.id].reagentList[pId].item
	local itemWorth = uni.ent[self.id].reagentList[pId].cost
	local bestTrade = {}
	local count = 1
	for st = 1, #stList do
		local stId = stList[st]
		local item = uni.ent[stId].productList[1].item
		local cost = uni.ent[stId].productList[1].cost
    if item ~= nil and itemWorth ~= nil then
      if item == itId then
        if cost <= itemWorth then
          bestTrade[count] = {}
          bestTrade[count].stId = stId
          bestTrade[count].value = itemWorth - cost
        end
      end
    end
	end
	if bestTrade[1]~= nil then
		local statId = bestTrade[1].stId
		local curVal = bestTrade[1].value
		for i = 1, #bestTrade do
			if curVal < bestTrade[i].value then
				statId = bestTrade[i].stId
				curVal = bestTrade[i].value
			end
		end
		return statId
	end
	return false
end

function ai:assignBuyer(id)
	for i = 1, #uni.ent[self.id].reagentList do
		local shipId = self.shipTab[id].shipId
		local homeStar = uni.ent[self.id].homeStarId
		local amtWeHave = uni.ent[self.id].reagentList[i].amt
		local amtWeCouldHave = uni.ent[self.id].hpMax / 2
		local percFull = maths.percent(amtWeHave, amtWeCouldHave)
		if percFull <= 66 then
			local buyFound = self:bestBuyInSector(homeStar, i)
			for j = 1, #self.shipTab do
				if buyFound == self.shipTab[j].target then
					buyFound = false
				end
			end
			if buyFound ~= false then
				self:logEntry("Trade found...")
				self:logEntry("Ship "..id.." sent to:")
				self:logEntry(uni.ent[buyFound].name)
				uni.ent[shipId]:dockAtTarget(buyFound)
				self.shipTab[id].state = "Outbound"
				self.shipTab[id].product = i
				self.shipTab[id].target = buyFound
			end
		end
	end
end

function ai:buyWares(star, id)
	local shipId = self.shipTab[id].shipId
	local pId = self.shipTab[id].product
	local docked = uni.ent[shipId].docked
	if docked ~= 0 then
		local itId = uni.ent[docked].productList[1].item
		local cost = uni.ent[docked].productList[1].cost
		local value = uni.ent[self.id].reagentList[pId].cost
		local fillUp = uni.ent[shipId].cargoMax
		if cost <= value then
			local totCost, amt = uni.ent[shipId]:buyWares(docked, itId, fillUp)
			if totCost ~= false then
				self:logEntry(amt.." "..uni.items[itId].name.." bought")
				self:logEntry("Total cost: "..totCost)
				self.shipTab[id].state = "Inbound"
				self.shipTab[id].target = self.id
				uni.ent[shipId]:dockAtTarget(self.id)
        uni.ent[docked].cash = uni.ent[docked].cash + totCost
				uni.ent[self.id].cash = uni.ent[self.id].cash - totCost
			else
				self:logEntry("Goods too expensive.")
				self.shipTab[id].state = "Idle"
			end
		end
	end
end

function ai:unloadWares(id)
	local shipId = self.shipTab[id].shipId
	local pId = self.shipTab[id].product
	if uni.ent[shipId].docked == self.id then
		self:logEntry("Ship "..id.." returned...")
		local itId = uni.ent[shipId].cargo[1].id
		local amt = uni.ent[shipId].cargo[1].amt
		local totalLoad = amt
		local spaceLeft = (uni.ent[self.id].hpMax / 2) - uni.ent[self.id].reagentList[pId].amt
        if amt > spaceLeft then
        	amt = spaceLeft
        end
		uni.ent[shipId]:removeItem(itId, amt)
		uni.ent[self.id].reagentList[pId].amt = uni.ent[self.id].reagentList[pId].amt + amt
		if amt < totalLoad then
			self:logEntry("Cannot hold all cargo...")
			self:logEntry("Waiting...")
			self.shipTab[id].state = "Inbound"
		else
			self:logEntry("Goods unloaded.")
			self.shipTab[id].state = "Idle"
		end
	end
end

function ai:onUpdate(dt)
  dt = dt * uni.gameSpeed
  self.timer = self.timer + dt
  if self.timer > self.tick then
    self.timer = 0
    self:logEntry("Taking trade turn...", "c")
    local availCash = uni.ent[self.id].cash
    self:logEntry("Funds: "..availCash.." Um")
    if availCash >= self.shipBuyPoint then
      self:buyShip("Shuttle")
    end
    if self.shipTab ~= nil then
      self:logEntry("Checking owned ships...")
      for j = 1, #self.shipTab do
        local state = self.shipTab[j].state
        if state == "Idle" then
          self:logEntry("Ship "..j.." idle.")
          self:assignBuyer(j)
        elseif state == "Outbound" then
          self:buyWares(uni.ent[self.id].homeStarId, j)
        elseif state == "Inbound" then
          self:unloadWares(j)
        end
      end
    end
  end
end

return ai