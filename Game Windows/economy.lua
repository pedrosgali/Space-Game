local win = require "/Lib/screen"
local maths = require "/Lib/maths"

local pData = {}

function pData:newSheet(id)
	local menu = win:newPane(menu, 1024, 512)
	menu.priority = 9
	menu.isMoveable = true
	menu.isVisible = false
	menu.id = id
	menu.stLine = 1
  menu.stId = "all"
  menu.timer = 0
  menu.tick = 10
  menu:newDropdown("Faction", 6, 22, 80, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0xFF, 0x00, uni.opacity)
  menu:addDropdownItem("Faction", "All", "all")
  for i = 1, #uni.factions do
    menu:addDropdownItem("Faction", uni.factions[i].name, uni.factions[i].name)
  end

	function menu:updateCall(dt)
    dt = dt * uni.gameSpeed
    self.timer = self.timer + dt
    if self.timer >= self.tick then
      self:render()
    end
	end
  
  function menu:gatherAllData()
    local count = 1
    local rTab = {}
    for i = 1, #uni.factions do
      local sData = self:gatherData(uni.factions[i].name)
      for j = 1, #sData do
        rTab[count] = sData[j]
        count = count + 1
      end
    end
    return rTab
  end
  
  function menu:gatherData(faction)
    local fId = uni.factionLookup(faction)
    local starId = uni.factions[fId].homeStarId
    local rTab = {}
    local count = 1
    if uni.ent[starId].stTab ~= nil then
      for j = 1, #uni.ent[starId].stTab do
        local stId = uni.ent[starId].stTab[j]
        rTab[count] = {}
        rTab[count].name = uni.items[uni.ent[stId].productList[1].item].name
        rTab[count].id = stId
        rTab[count].cash = uni.ent[stId].cash
        rTab[count].item = itemName
        rTab[count].amt = uni.ent[stId].productList[1].amt
        rTab[count].cost = uni.ent[stId].productList[1].cost
        rTab[count].ing = {}
        for k = 1, 3 do
          rTab[count].ing[k] = {}
          if uni.ent[stId].reagentList[k] ~= nil then
            rTab[count].ing[k].item = uni.items[uni.ent[stId].reagentList[k].item].name
            rTab[count].ing[k].amt = uni.ent[stId].reagentList[k].amt
            rTab[count].ing[k].cost = uni.ent[stId].reagentList[k].cost
          else
            rTab[count].ing[k].item = "None"
            rTab[count].ing[k].amt = "N/A"
            rTab[count].ing[k].cost = "N/A"
          end
        end
        count = count + 1
      end
    end
    return rTab
  end
  
  function menu:jumpToStar(faction)
    local fId = uni.factionLookup(faction)
    local starId = uni.factions[fId].homePlanetId
    uni.selected = starId
  end
  
  function menu:renderSetup()
		self:clear()
		self:backdrop(0x99, 0x99, 0x99, self.opacity)
		self:title("Wigs Economic Window", 0x00, 0x99, 0x99, uni.opacity)
		self:closeButton()
    --self:box(6, 44, self.width - 10, self.height - 49, 0x00, 0x00, 0x00, uni.opacity)
    local xOff = 7
    local yOff = 44
    local stWidth = 80
    local numWidth = 60
    if self.stId ~= "all" then
      self:button("Focus", "jump", xOff + 85, 22, stWidth + xOff - 1, 16)
    end
    self:button("Product", "none", xOff, yOff, stWidth + xOff - 1, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    local offset = xOff + stWidth
    self:button("ID", "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + numWidth + 1
    self:button("Amount", "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + numWidth + 1
    self:button("Cost", "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + numWidth + 1
    self:button("Reagent 1", "none", xOff + offset, yOff, stWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + stWidth + 1
    self:button("Amount", "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + numWidth + 1
    self:button("Cost", "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + numWidth + 1
    self:button("Reagent 2", "none", xOff + offset, yOff, stWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + stWidth + 1
    self:button("Amount", "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + numWidth + 1
    self:button("Cost", "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + numWidth + 1
    self:button("Reagent 3", "none", xOff + offset, yOff, stWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + stWidth + 1
    self:button("Amount", "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + numWidth + 1
    self:button("Cost", "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    offset = offset + numWidth + 1
    self:button("Funds", "none", xOff + offset, yOff, 99, 16, 0x00, 0x99, 0x00, uni.opacity, _, _, _, uni.opacity)
    yOff = yOff + 17
    local vizRows = math.floor((self.height - 49) / 17) - 2
    if self.stId == "all" then
      self.data = self:gatherAllData()
    else
      self.data = self:gatherData(self.stId)
    end
		for i = self.stLine, self.stLine + vizRows do
      if self.data[i] ~= nil then
        offset = xOff
        self:button(self.data[i].name, "none", xOff, yOff, stWidth + xOff, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
        offset = offset + stWidth + 1
        self:button(self.data[i].id, "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
        offset = offset + numWidth + 1
        local fPerc = maths.percent(self.data[i].amt, uni.ent[self.data[i].id].hpMax / 2)
        if fPerc < 5 then
          self:button(self.data[i].amt, "none", xOff + offset, yOff, numWidth, 16, 0x99, 0x00, 0x00, uni.opacity)
        elseif fPerc < 33 then
          self:button(self.data[i].amt, "none", xOff + offset, yOff, numWidth, 16, 0xFF, 0xFF, 0x00, uni.opacity)
        elseif fPerc < 66 then
          self:button(self.data[i].amt, "none", xOff + offset, yOff, numWidth, 16, 0xFF, 0x99, 0x00, uni.opacity)
        else
          self:button(self.data[i].amt, "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
        end
        offset = offset + numWidth + 1
        self:button(self.data[i].cost, "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
        offset = offset + numWidth + 1
        for j = 1, #self.data[i].ing do
          self:button(self.data[i].ing[j].item, "none", xOff + offset, yOff, stWidth, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
          offset = offset + stWidth + 1
          if self.data[i].ing[j].item ~= "None" then
            local fPerc = maths.percent(self.data[i].ing[j].amt, uni.ent[self.data[i].id].hpMax / 2)
            if fPerc < 5 then
              self:button(self.data[i].ing[j].amt, "none", xOff + offset, yOff, numWidth, 16, 0x99, 0x00, 0x00, uni.opacity)
            elseif fPerc < 33 then
              self:button(self.data[i].ing[j].amt, "none", xOff + offset, yOff, numWidth, 16, 0xFF, 0xFF, 0x00, uni.opacity)
            elseif fPerc < 66 then
              self:button(self.data[i].ing[j].amt, "none", xOff + offset, yOff, numWidth, 16, 0xFF, 0x99, 0x00, uni.opacity)
            else
              self:button(self.data[i].ing[j].amt, "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
            end
          else
            self:button(self.data[i].ing[j].amt, "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
          end
          offset = offset + numWidth + 1
          self:button(self.data[i].ing[j].cost, "none", xOff + offset, yOff, numWidth, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
          offset = offset + numWidth + 1
        end
        self:button(self.data[i].cash, "none", xOff + offset, yOff, 99, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0x99, 0x00, uni.opacity)
        yOff = yOff + 17
      end
    end
	end

  function menu:mousePressed(x, y, btn)
		if self:isClicked(x, y) then
			if btn == "l" then
        local ret = self:dropdownClicked(x, y)
				if ret ~= false then
          self.stId = ret
          if ret == "all" then
            self.data = nil
            self.data = self:gatherAllData()
          else
            self.data = nil
            self.data = self:gatherData(self.stId)
          end
          self.stLine = 1
          return true
				end
				ret = self:buttonClicked(x, y)
				if ret ~= false then
					if ret == "close" then
						self.isVisible = false
          elseif ret == "jump" then
            self:jumpToStar(self.stId)
					end
					return true
				end
			elseif btn == "r" then
				--Right click code to be added here.
			elseif btn == "wu" then
				if self.stLine > 1 then self.stLine = self.stLine - 1 end
				return true
			elseif btn == "wd" then
				if self.stLine < #self.data - math.floor((self.height - 26) / 17) - 2 then self.stLine = self.stLine + 1 end
				return true
			end
			self.grabbed = true
			self.grabPointX = x - self.x
			self.grabPointY = y - self.y
			return true
		end
	end

  menu.data = menu:gatherAllData()
	menu:render()

	return menu
end

return pData