local win = require "/Lib/screen"
local ai = require "/Classes/ai"

local econAi = ai:newAi(econAi)
econAi.name = "Economist"

function econAi:newAi(newAiPlayer, facId)
	local newAiPlayer = newAiPlayer or {}
	setmetatable(newAiPlayer, self)
	self.__index = self
	newAiPlayer.facId = facId
	newAiPlayer.skimPerc = 1.1
	return newAiPlayer
end

function econAi:findGoodBuy(star, shipId)
	local econ = uni.ent[star].econ
	local stList = uni.factions[self.facId].stationList
	for i = 1, #econ do
		local cost = math.floor(uni.items[i].cost * econ[i])
		for st = 1, #stList do
			local stId = stList[st]
			gameUtils.debug(uni.items[uni.ent[stId].productList[1].item].name.." prices: "..uni.ent[stId].productList[1].cost)
			if uni.ent[stId].productList[1].item == i then
				if cost <= cost * self.skimPerc then
					uni.ent[shipId]:dockAtTarget(stId)
					uni.ent[shipId].state = "Filling"
					gameUtils.debug("Good buy found, docking.")
					gameUtils.debug("Buying "..uni.items[i].name.." for "..cost.." Cr.")
					return true
				end
			end
		end
	end
	gameUtils.debug("No trades here.")
end

function econAi:bestPriceInSector(star, itId)
	local econ = uni.ent[star].econ
	local stList = self.stationList
	local bestTrade = {}
	local count = 1
	local itemWorth = uni.items[itId].cost * econ[itId]
	for st = 1, #stList do
		local stId = stList[st]
		local item = uni.ent[stId].productList[1].item
		local cost = uni.ent[stId].productList[1].cost
		if item == itId then
			if cost <= itemWorth * self.skimPerc then
				bestTrade[count] = {}
				bestTrade[count].stId = stId
				bestTrade[count].value = math.floor(itemWorth * self.skimPerc) - cost
			end
		end
	end
	if bestTrade[1]~= nil then
		local stId = bestTrade[1].stId
		local curVal = bestTrade[1].value
		for i = 1, #bestTrade do
			if curVal < bestTrade[i].value then
				stId = bestTrade[i].stId
				curVal = bestTrade[i].value
			end
		end
		return stId
	end
	return false
end

function econAi:buyWares(star, shipId)
	if uni.ent[shipId].docked ~= 0 then
		local docked = uni.ent[shipId].docked
		local itId = uni.ent[docked].productList[1].item
		local cost = uni.ent[docked].productList[1].cost
		local value = uni.items[itId].cost * uni.ent[star].econ[itId]
		local fillUp = uni.ent[shipId].cargoMax
		if cost <= value * self.skimPerc then
			if uni.ent[shipId]:buyWares(docked, itId, fillUp) then
				uni.ent[shipId].state = "Selling"
			else
				uni.ent[shipId].state = "Idle"
			end
		end
	end
end

function econAi:findGoodSale(star, shipId)
	gameUtils.debug("Trading ship found, finding a good sale.")
	local econ = uni.ent[star].econ
	local stList = uni.factions[self.facId].stationList
	local itId = uni.ent[shipId].cargo[1].id
	for i = 1, #econ do
		gameUtils.debug("Checking "..uni.items[itId].name.." prices...")
		local cost = uni.ent[shipId].cargo[1].cost
		for st = 1, #stList do
			local stId = stList[st]
			for pId = 1, #uni.ent[stId].reagentList do
				if uni.ent[stId].reagentList[pId].item == itId then
					if uni.ent[stId].reagentList[pId].cost > cost then
						uni.ent[shipId]:dockAtTarget(stId)
						uni.ent[shipId].tradeSlot = pId
						uni.ent[shipId].state = "Supplying"
						gameUtils.debug("Good sale found, docking.")
						return true
					end
				end
			end
		end
	end
	gameUtils.debug("No trades here.")
end

function econAi:sellWares(star, shipId)
	if uni.ent[shipId].docked ~= 0 then
		local docked = uni.ent[shipId].docked
		local pId = uni.ent[shipId].tradeSlot
		local itId = uni.ent[shipId].cargo[1].id
		local wePaid = uni.ent[shipId].cargo[1].cost
		local theyPay = uni.ent[docked].reagentList[pId].cost
		local sellAll = uni.ent[shipId].cargo[1].amt
		if wePaid < theyPay then
			uni.ent[shipId]:sellWares(docked, itId, sellAll)
			if uni.ent[shipId].cargo ~= nil then
				uni.ent[shipId].state = "Selling"
			else
				uni.ent[shipId].state = "Idle"
			end
		end
	end
end

function econAi:tradeTurn()
	gameUtils.debug("Taking trade turn.", "c")
	for st = 1, #self.starList do
		local star = self.starList[st]
		local econ = uni.ent[star].econ
		local buyTab = {}
		local count = 1
		for i = 1, #econ do
			local stId = self:bestPriceInSector(star, i)
			if stId ~= false then
				buyTab[count] = stId
				count = count + 1
			end
		end
		if buyTab[1] ~= nil then
			count = 1
		end
		gameUtils.debug("Faction Cash: "..uni.factions[self.facId].cash.." Cr.")
		gameUtils.debug("Checking for trades in "..uni.ent[self.starList[st]].name.." sector...")
		for sh = 1, #self.supplyList do
			local shipId = self.supplyList[sh]
			if uni.ent[shipId].state == "Idle" then
				gameUtils.debug("Idle trader found...")
				if buyTab[count] ~= nil then
					gameUtils.debug("Dispatching trader to "..uni.ent[buyTab[count]].name..".")
					uni.ent[shipId]:dockAtTarget(buyTab[count])
					uni.ent[shipId].state = "Filling"
					count = count + 1
				else
					self:findGoodBuy(star, shipId)
				end
			elseif uni.ent[shipId].state == "Selling" then
				gameUtils.debug("Full trader found...")
				self:findGoodSale(star, shipId)
			elseif uni.ent[shipId].state == "Supplying" then
				self:sellWares(star, shipId)
			elseif uni.ent[shipId].state == "Filling" then
				self:buyWares(star, shipId)
			end
		end
	end
end

function econAi:turn()
	self:gatherLists()
	self:tradeTurn()
end

return econAi