local win = require "/Lib/screen"

local ai = {}

function ai:newAi(newAi)
	local newAi = newAi or {}
	setmetatable(newAi, self)
	self.__index = self
	return newAi
end

function ai:logEntry(msg, clear)
	if clear ~= nil then self.log = nil end
	local count = 1
    if self.log == nil then
        self.log = {}
    elseif #self.log >= uni.maxAiLog then
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
        cWin[winId]:render()
    end
end

function ai:gatherLists()
	self.supplyList = uni.factions[self.facId].supplyList
	self.stationList = uni.factions[self.facId].stationList
	self.planetList = uni.factions[self.facId].planetList
	self.starList = uni.factions[self.facId].starList
end

function ai:tradeTurn()
	gameUtils.debug("Taking trade turn.", "c")
	for st = 1, #self.starList do
		local star = self.starList[st]
		gameUtils.debug("Checking for trades in "..uni.ent[self.starList[st]].name.." sector...")
		for sh = 1, #self.supplyList do
			gameUtils.debug("Checking trading ship "..sh)
			local shipId = self.supplyList[sh]
			if uni.ent[shipId].state == "Idle" then
				self:findGoodBuy(star, shipId)
			elseif uni.ent[shipId].state == "Selling" then
				self:findGoodSale(star, shipId)
			elseif uni.ent[shipId].state == "Supplying" then
				self:sellWares(star, shipId)
			elseif uni.ent[shipId].state == "Filling" then
				self:buyWares(star, shipId)
			end
		end
	end
end

function ai:turn()
	
end

return ai