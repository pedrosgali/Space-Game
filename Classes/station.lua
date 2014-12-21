local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local it = require "/Classes/item"

local stat = {}

function stat:spawnStation(newStat)
    local newStat = newStat or {}
    setmetatable(newStat, self)
    self.__index = self
    newStat.cash = 11000000
    return newStat
end

function stat:logEntry(msg)
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

function stat:inputTradeGood(item)
    local count = 1
    local amt = self.hpMax / 2
    if self.productList == nil then
        self.productList = {}
    else
        count = #self.productList + 1
    end
    self.productList[count] = {}
    self.productList[count].item = item
    self.productList[count].amt = amt
end

function stat:addComponentGoods(id)
    local count = 1
    if self.reagentList == nil then
        self.reagentList = {}
    else
        count = #self.reagentList + 1
    end
    for j = 1, #uni.items[self.productList[id].item].recipe do
        local itId = it.itemLookup(uni.items[self.productList[id].item].recipe[j].name)
        local amt = math.random(1, self.hpMax / 2)
        self.reagentList[count] = {}
        self.reagentList[count].item = itId
        self.reagentList[count].amt = amt
        self.reagentList[count].batch = uni.items[self.productList[id].item].recipe[j].amt
        count = count + 1
    end
end

function stat:assignTradeGoods()
    self.productList = {}
    local count = 1
    local rnd = it.randomItem(self.productType)
    self:inputTradeGood(rnd)
    pLeft = self.products - 1
    while pLeft > 0 do
        local rnd = it.randomItem(self.productType)
        local diffCount = 0
        for i = 1, #self.productList do
            if rnd ~= self.productList[i].item then
                diffCount = diffCount + 1
            end
        end
        if diffCount == #self.productList then
            self:inputTradeGood(rnd)
            pLeft = pLeft - 1
        end
    end
    for i = 1, #self.productList do
        self:addComponentGoods(i)
    end
end

function stat:canMake(itemType)
    if self.productType == itemType then return true end
    return false
end

function stat:hasItem(itId, amt)
    for i = 1, #self.productList do
        if self.productList[i].item == itId then
            if amt <= self.productList[i].amt then
                return true, i, amt
            else
                return true, i, self.productList[i].amt
            end
        end
    end
    return false
end

function stat:willBuy(itId, amt)
    for i = 1, #self.reagentList do
        if self.reagentList[i].item == itId then
            local spaceLeft = (self.hpMax / 2) - self.reagentList[i].amt
            if amt <= spaceLeft then
                return true, i, amt
            else
                return true, i, spaceLeft
            end
        end
    end
    return false
end

function stat:checkProduction(id, slot)
    local batch = uni.items[id].batch
    if self.productList[slot].amt + batch < self.hpMax / 2 then
        local rTab = {}
        local rCnt = #uni.items[id].recipe
        for item = 1, #uni.items[id].recipe do
            for r = 1, #self.reagentList do
                local itId = it.itemLookup(uni.items[id].recipe[item].name)
                if self.reagentList[r].item == itId then
                    if self.reagentList[r].amt >= uni.items[id].recipe[item].amt then
                        rTab[rCnt] = {}
                        rTab[rCnt].rSlot = r
                        rTab[rCnt].amt = uni.items[id].recipe[item].amt
                        rCnt = rCnt - 1
                    else
                        return false
                    end
                end
            end
        end
        for i = 1, #rTab do
            self.reagentList[rTab[i].rSlot].amt = self.reagentList[rTab[i].rSlot].amt - rTab[i].amt
        end
        self.productList[slot].amt = self.productList[slot].amt + batch
        local wOpen = gameUtils.checkOpen(self.id)
        if wOpen ~= false then
            cWin[wOpen]:render()
        end
        return true
    else
        return false
    end
end

function stat:addEqSlot(slot)
    local count = 1
    if self.eqTab == nil then
        self.eqTab = {}
    else
        count = #self.eqTab + 1
    end
    self.eqTab[count] = {}
    self.eqTab[count].slot = slot
end

function stat:update(dt)
    self.heading = self.heading + (((50000 - self.rad) / 100000000) * uni.gameSpeed)
    self.vizHeading = self.vizHeading + self.turn
    if self.sp < self.spMax then
        self.sp = math.min(self.sp + (self.shRecharge * dt), self.spMax)
    end
    if self.eqTab ~= nil then
      for i = 1, #self.eqTab do
        if self.eqTab[i].equipped ~= nil then
          self.eqTab[i].equipped:onUpdate(dt)
        end
      end
    end
end

function stat:move()
    self.x = uni.ent[self.homePlanetId].x + (self.rad * math.cos(self.heading))
    self.y = uni.ent[self.homePlanetId].y + (self.rad * math.sin(self.heading))
end

function stat:info(id)
	local info = win:newPane(info, 220, 340)
    info.shipId = self.id
    info.id = id
    info.name = uni.ent[info.shipId].name
    info.facId = uni.factionLookup(self.faction)
    info.facName = self.faction
    info.priority = 9
    info.navScreen = true
    info.cargoScreen = false
    info.logScreen = false
    info.logPoint = 1
    info:move(uni.xOff, uni.yOff)
	
    function info:checkPlayerDocked()
        local rTab = {}
        local count = 1
        for i = 1, uni.eCnt do
            if uni.ent[i].docked == self.shipId and uni.ent[i].faction == uni.player then
                rTab[count] = i
                count = count + 1
            end
        end
        return rTab
    end

    function info:statBars(x, y)
        self:box(x, y, self.width - (x * 2), 60, 0x00, 0x00, 0x00, uni.opacity)
        self:percentageBar(x + 2, y + 5, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].hp, uni.ent[self.shipId].hpMax)
        self:percentageBar(x + 2, y + 22, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].ap, uni.ent[self.shipId].apMax, 0x99, 0x99, 0x99, uni.opacity, 0x66, 0x66, 0x66, uni.opacity)
        self:percentageBar(x + 2, y + 39, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].sp, uni.ent[self.shipId].spMax, 0xFF, 0xFF, 0x00, uni.opacity, 0xFF, 0x00, 0x00, uni.opacity)
    end

    function info:tradeBox(id, pId, x, y, w)
        self:button(uni.items[id].name, "none", x + 1, y + 1, w - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
        local stId = uni.ent[self.shipId].homeStarId
        self:button(tostring(uni.ent[self.shipId].productList[pId].cost), "none", x + 1, y + 16, w - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
        self:percentageBar(x + 1, y + 32, w - 2, 16, uni.ent[self.shipId].productList[pId].amt, uni.ent[self.shipId].hpMax / 2, _, _, _, uni.opacity, _, _, _, uni.opacity, "n")
        local pDocked = self:checkPlayerDocked()
        if pDocked[1] ~= nil then
            self:button("Buy 1", "b_"..pId.."_1", x + 1, y + 48, (w / 4) - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
            self:button("Buy 10", "b_"..pId.."_10", x + (w / 4), y + 48, (w / 4) - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
            self:button("Buy 100", "b_"..pId.."_100", x + ((w / 4) * 2), y + 48, (w / 4) - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
            self:button("Buy 1000", "b_"..pId.."_1000", x + ((w / 4) * 3), y + 48, (w / 4) - 2, 16, 0x00, 0x99, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
        end
    end

    function info:saleBox(id, pId, x, y, w)
        self:button(uni.items[id].name, "none", x + 1, y + 1, w - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
        local stId = uni.ent[self.shipId].homeStarId
        local amtHave = uni.ent[self.shipId].reagentList[pId].amt
        local storeMax = uni.ent[self.shipId].hpMax / 2
        self:button(tostring(uni.ent[self.shipId].reagentList[pId].cost).." Um", "none", x + 1, y + 16, w - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
        self:percentageBar(x + 1, y + 32, w - 2, 16, uni.ent[self.shipId].reagentList[pId].amt, uni.ent[self.shipId].hpMax / 2, _, _, _, uni.opacity, _, _, _, uni.opacity, "n")
        local pDocked = self:checkPlayerDocked()
        if pDocked[1] ~= nil then
            self:button("Sell 1", "none", x + 1, y + 48, (w / 4) - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
            self:button("Sell 10", "none", x + (w / 4), y + 48, (w / 4) - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
            self:button("Sell 100", "none", x + ((w / 4) * 2), y + 48, (w / 4) - 2, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
            self:button("Sell 1000", "none", x + ((w / 4) * 3), y + 48, (w / 4) - 2, 16, 0x00, 0x99, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
        end
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

	function info:renderSetup()
		self:clear()
		self:backdrop()
		self:title(self.name, 0x00, 0x99, 0x99, uni.opacity)
		self:closeButton()
        local btnw = math.floor(self.width - 20) / 3
        if self.navScreen then
            self:button("Stats", "nav_screen", 6, 23, btnw, 16, 0x00, 0x66, 0x99, uni.opacity)
            self:button("Cargo", "cargo_screen", btnw + 10, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
            self:button("Log", "log_screen", (btnw * 2) + 15, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
            self:button("Dock", "follow_ship", 6, self.height - 22, self.width - 10, 16)
            self:statBars(6, self.height - 87)
            self:box(6, 44, self.width - 12, self.width - 12, 0x00, 0x00, 0x00, uni.opacity)
            self:setCamera(6, 44, self.width - 12, self.width - 12, uni.ent[self.shipId].x, uni.ent[self.shipId].y)
        elseif self.cargoScreen then
            self:button("Stats", "nav_screen", 6, 23, btnw, 16, 0x00, 0x66, 0x99, uni.opacity)
            self:button("Cargo", "cargo_screen", btnw + 10, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
            self:button("Log", "log_screen", (btnw * 2) + 15, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
            --self:box(6, 46, self.width - 10, self.height - 50, 0x00, 0x00, 0x00, uni.opacity)
            local yOff = 47
            for i = 1, #uni.ent[self.shipId].productList do
                if uni.ent[self.shipId].productList[i] ~= nil then
                    if uni.ent[self.shipId].productList[i].item ~= nil then
                        local itId = uni.ent[self.shipId].productList[i].item
                        self:tradeBox(itId, i, 6, yOff, self.width - 10)
                        yOff = yOff + 65
                    end
                end
            end
            for i = 1, #uni.ent[self.shipId].reagentList do
                local itId = uni.ent[self.shipId].reagentList[i].item
                self:saleBox(itId, i, 6, yOff, self.width - 10)
                yOff = yOff + 65
            end
        elseif self.logScreen then
            self:button("Stats", "nav_screen", 6, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
            self:button("Cargo", "cargo_screen", btnw + 10, 23, btnw, 16, 0x00, 0x99, 0x99, uni.opacity)
            self:button("Log", "log_screen", (btnw * 2) + 15, 23, btnw, 16, 0x00, 0x66, 0x99, uni.opacity)
            self:button("Follow", "follow_ship", 6, self.height - 22, self.width - 10, 16)
            self:logPrint(6, 46, self.width - 10, self.height - 74)
        end
	end

    function info:updateCall()
        if self.isVisible then
            self:render()
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
                elseif ret == "cargo_screen" then
                    self.navScreen = false
                    self.cargoScreen = true
                    self.logScreen = false
                elseif ret == "log_screen" then
                    self.navScreen = false
                    self.cargoScreen = false
                    self.logScreen = true
                elseif ret == "follow_ship" then
                    local list = uni.gatherSelectedTable()
                    for i = 1, #list do
                    	if uni.ent[list[i]].type == "ship" then
                            uni.ent[list[i]]:dockAtTarget(self.shipId)
                        end
                    end
                elseif string.sub(ret, 1, 2) == "b_" then
                    local pId = tonumber(string.sub(ret, 3, 3))
                    local amt = tonumber(string.sub(ret, 5, #ret))
                    local list = uni.gatherSelectedTable(self.facName)
                    for i = 1, #list do
                        if uni.ent[list[i]].type == "ship" then
                            uni.ent[list[i]]:buyWares(self.shipId, pId, amt)
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

return stat