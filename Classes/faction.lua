local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local item = require "/Classes/item"

local fact = {}

function fact:newFaction(newFac)
	local newFac = newFac or {}
	setmetatable(newFac, self)
	self.__index = self
	return newFac
end

--FACTION TRADE FUNCTIONS--

function fact:hasCash(amt)
	if self.cash >= amt then return true end
	return false
end

function fact:canAffordX(stId, pId, amt)
	local cashPer = uni.ent[stId].productList[pId].cost
	local newAmt = amt * cashPer
	if self:hasCash(newAmt) then
		return amt
	else
		return math.floor(self.cash / cashPer)
	end
end

function fact:canBuyX(stId, pId, amt)
	local cashPer = uni.ent[stId].reagentList[pId].cost
	local newAmt = amt * cashPer
	if self:hasCash(newAmt) then
		return amt
	else
		return math.floor(self.cash / cashPer)
	end
end

function fact:buyWares(stId, pId, amt)
	local cashPer = uni.ent[stId].productList[pId].cost
	local totCost = amt * cashPer
	self.cash = self.cash - totCost
end

function fact:sellWares(stId, pId, amt)
	local cashPer = uni.ent[stId].reagentList[pId].cost
	local totCost = amt * cashPer
	self.cash = self.cash + totCost
end

function fact:getStationTax(stId, pId, amt)
	--Apply government tax here based on local planetary stuffs
end

--FACTION AI FUNCTIONS--

function fact:addTradeUnit(id)
	local count = 1
	if self.supplyList == nil then
	    self.supplyList = {}
	else
		count = #self.supplyList + 1
	end
	self.supplyList[count] = id
end

function fact:addStation(id)
	local count = 1
	if self.stationList == nil then
	    self.stationList = {}
	else
		count = #self.stationList + 1
	end
	self.stationList[count] = id
end

function fact:addPlanet(id)
	local count = 1
	if self.planetList == nil then
	    self.planetList = {}
	else
		count = #self.planetList + 1
	end
	self.planetList[count] = id
	if uni.ent[id].stTab ~= nil then
		for j = 1, #uni.ent[id].stTab do
			local stId = uni.ent[id].stTab[j]
			self:addStation(stId)
		end
	end
end

function fact:addStar(id)
	local count = 1
	if self.starList == nil then
	    self.starList = {}
	else
		count = #self.starList + 1
	end
	self.starList[count] = id
	for i = 1, #uni.ent[id].plTab do
		local plId = uni.ent[id].plTab[i]
		self:addPlanet(plId)
	end
end

--FACTION SETUP FUNCTIONS--

function fact:spawnShip(class, group)
	uni.spawnShip(self.name.." "..class, class, self.name, self.homePlanetId)
  uni.equipItem(uni.eCnt, "Small shield generator")
  uni.equipItem(uni.eCnt, "Small Jumpdrive")
	if group == "trade" then
		self:addTradeUnit(uni.eCnt)
	else

	end
end

function fact:spawnGroup(class, group)
	for i = 1, math.random(uni.maxStartShips / 2, uni.maxStartShips) do
		self:spawnShip(class, group)
		if group == "trade" then
			self:addTradeUnit(uni.eCnt)
		else

		end
	end
end

function fact:init()
  uni.player = self.name
	local hSys = self.homeStarId
	if uni.ent[hSys].plTab == nil then
		hSys = hSys + 1
	end
  self:addStar(hSys)
	for i = 1, #uni.ent[hSys].plTab do
		local plId = uni.ent[hSys].plTab[i]
		if self.atmo == uni.ent[plId].atmo then
			self.homePlanetId = plId
			self:addPlanet(plId)
			break
		elseif i == #uni.ent[hSys].plTab then
			uni.ent[plId].atmo = self.atmo
			self.homePlanetId = plId
			self.homePlanetType = uni.ent[plId].class
			self:addPlanet(plId)
		end
	end
	for i = 1, #uni.items do
		local amt = math.random(math.floor(uni.items[i].rarity / 2), uni.items[i].rarity)
		local itemType = uni.items[i].type
		local stClass = "none"
		for k = 1, #uni.sTypes do
			if uni.sTypes[k]:canMake(itemType) then
				stClass = uni.sTypes[k].class
			end
		end
		for j = 1, amt do
			local rPl = math.random(1, #uni.ent[hSys].plTab)
			local plId = uni.ent[hSys].plTab[rPl]
			local stName = uni.items[i].name.." "..stClass
			local rad = math.random(uni.statMinRad, uni.statMaxRad) * (1 / uni.ent[plId].scale)
			local angle = math.random(0, 359)
			local px = uni.ent[plId].x
			local py = uni.ent[plId].y
			local x, y = px + (rad * math.cos(angle)), (py + (rad * math.sin(angle)) / 2)
			uni.spawnStation(stName, stClass, rad, plId, self.name, x, y)
			uni.ent[uni.eCnt]:inputTradeGood(i)
			uni.ent[uni.eCnt]:addComponentGoods(1)
			self:addStation(uni.eCnt)
		end
	end
	self:spawnGroup("Shuttle", "trade")
	--self:spawnGroup("Freighter", "trade")
end

return fact