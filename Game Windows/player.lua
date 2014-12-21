local win = require "/Lib/screen"
local maths = require "/Lib/maths"

local pData = {}

function pData:newSheet(id)
	local menu = win:newPane(menu, 800, 605)
	menu.priority = 9
	menu.isMoveable = true
	menu.isVisible = false
	menu.faction = uni.player
	menu.id = id
	menu.bWidth = math.floor((menu.width - 97) / 8) - 1
	menu.stLine = 1
	menu:newDropdown("Type", menu.width - 85, 22, 80, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0xFF, 0x00, uni.opacity)
	menu:addDropdownItem("Type", "Ships", "ship")
	menu:addDropdownItem("Type", "Stations", "station")

	function menu:updateCall()
		self:render()
	end

	function menu:populateDropdowns()
		for i = 2, #self.ddTab do
			self.ddTab[i] = nil
			self.ddCnt = self.ddCnt - 1
		end
		self:newDropdown("Class", self.width - 85, 43, 80, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0xFF, 0x00, uni.opacity)
		self:addDropdownItem("Class", "All", "all")
		if self.ddTab[1].returnVal == "ship" then
			for i = 1, #uni.shipyard do
				self:addDropdownItem("Class", uni.shipyard[i].class, uni.shipyard[i].class)
			end
		elseif self.ddTab[1].returnVal == "station" then
			for i = 1, #uni.sTypes do
				self:addDropdownItem("Class", uni.sTypes[i].class, uni.sTypes[i].class)
			end
		end
	end

	function menu:addEntityData(x, y, w, id)
		if uni.ent[id].selected then
			self:button(uni.ent[id].name, id, x, y, w, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
			self:button(uni.ent[id].class, id, x + (w + 1), y, w, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
			self:button(uni.ent[id].state, id, x + ((w * 2) + 2), y, w, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
			self:button(tostring(maths.round(uni.ent[id].x), 2), id, x + ((w * 3) + 3), y, w - 3, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
			self:button(tostring(maths.round(uni.ent[id].y), 2), id, x + ((w * 4) + 1), y, w, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
			self:percentageBar(x + ((w * 5) + 2), y, w + 2, 16, uni.ent[id].hp, uni.ent[id].hpMax)
	        self:percentageBar(x + ((w * 6) + 5), y, w + 2, 16, uni.ent[id].ap, uni.ent[id].apMax, 0x99, 0x99, 0x99, uni.opacity, 0x66, 0x66, 0x66, uni.opacity)
	        self:percentageBar(x + ((w * 7) + 8), y, w + 5, 16, uni.ent[id].sp, uni.ent[id].spMax, 0xFF, 0xFF, 0x00, uni.opacity, 0xFF, 0x00, 0x00, uni.opacity)
		else
			self:button(uni.ent[id].name, id, x, y, w, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0xFF, 0x00, uni.opacity)
			self:button(uni.ent[id].class, id, x + (w + 1), y, w, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0xFF, 0x00, uni.opacity)
			self:button(uni.ent[id].state, id, x + ((w * 2) + 2), y, w, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0xFF, 0x00, uni.opacity)
			self:button(tostring(maths.round(uni.ent[id].x), 2), id, x + ((w * 3) + 3), y, w - 3, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0xFF, 0x00, uni.opacity)
			self:button(tostring(maths.round(uni.ent[id].y), 2), id, x + ((w * 4) + 1), y, w, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0xFF, 0x00, uni.opacity)
			self:percentageBar(x + ((w * 5) + 2), y, w + 2, 16, uni.ent[id].hp, uni.ent[id].hpMax)
	        self:percentageBar(x + ((w * 6) + 5), y, w + 2, 16, uni.ent[id].ap, uni.ent[id].apMax, 0x99, 0x99, 0x99, uni.opacity, 0x66, 0x66, 0x66, uni.opacity)
	        self:percentageBar(x + ((w * 7) + 8), y, w + 5, 16, uni.ent[id].sp, uni.ent[id].spMax, 0xFF, 0xFF, 0x00, uni.opacity, 0xFF, 0x00, 0x00, uni.opacity)
	    end
	end

	function menu:renderSetup()
		self:clear()
		self:backdrop(0x99, 0x99, 0x99, self.opacity)
		self:title("Property Data", 0x00, 0x99, 0x99, self.opacity)
		self:closeButton()
        self:button("Info", "show_info", self.width - 85, self.height - 22, 80, 16, 0x00, 0x00, 0x00, uni.opacity, 0x00, 0xFF, 0x00, uni.opacity)
		local yOff = 23
		self.shipTab = uni.searchList(self.ddTab[1].returnVal, self.ddTab[2].returnVal, self.faction)
		self:box(6, 22, self.width - 97, self.height - 26, 0x00, 0x00, 0x00, uni.opacity)
		self:button("ID", "none", 7, yOff, self.bWidth, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
		self:button("Class", "none", 7 + (self.bWidth + 1), yOff, self.bWidth, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
		self:button("Task", "none", 7 + ((self.bWidth * 2) + 2), yOff, self.bWidth, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
		self:button("X", "none", 7 + ((self.bWidth * 3) + 3), yOff, self.bWidth - 3, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
		self:button("Y", "none", 7 + ((self.bWidth * 4) + 1), yOff, self.bWidth, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
		self:button("Hull", "none", 7 + ((self.bWidth * 5) + 2), yOff, self.bWidth + 2, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
		self:button("Armour", "none", 7 + ((self.bWidth * 6) + 5), yOff, self.bWidth + 2, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
		self:button("Shields", "none", 7 + ((self.bWidth * 7) + 8), yOff, self.bWidth + 5, 16, 0x00, 0xFF, 0x00, uni.opacity, 0x00, 0x00, 0x00, uni.opacity)
		yOff = yOff + 17
		local vizRows = math.floor((self.height - 26) / 17) - 2
		for i = self.stLine, self.stLine + vizRows do
			if self.shipTab[i] ~= nil then
				if uni.ent[self.shipTab[i]].faction == self.faction then
					self:addEntityData(7, yOff, self.bWidth, self.shipTab[i])
					yOff = yOff + 17
				end
			end
		end
	end

	function menu:mousePressed(x, y, btn)
		if self:isClicked(x, y) then
			if btn == "l" then
				local ret = self:dropdownClicked(x, y)
				if ret ~= false then
					if ret == "ship" or ret == "station" then
						self:populateDropdowns()
						return true
					end
				end
				ret = self:buttonClicked(x, y)
				if ret ~= false then
					if ret == "close" then
						self.isVisible = false
	                elseif ret == "show_info" then
	                    local list = uni.gatherSelectedTable()
	                    for i = 1, #list do
	                        gameUtils.debug(list[i])
	                        if gameUtils.checkOpen(list[i]) == false then
	                            gameUtils.sortPriority()
	                            cWin[#cWin + 1] = uni.ent[list[i]]:info(#cWin + 1)
	                            cWin[#cWin]:move(i * 20, i * 20)
	                        else
	                            local id = gameUtils.checkOpen(list[i])
	                            gameUtils.sortPriority()
	                            cWin[id].priority = 9
	                            cWin[id]:move(i * 20, i * 20)
	                        end
	                    end
	                    return true
					elseif ret ~= false then
						uni.clearSelected(ret)
					end
					return true
				end
			elseif btn == "r" then
				--Right click code to be added here.
			elseif btn == "wu" then
				if self.stLine > 1 then self.stLine = self.stLine - 1 end
				return true
			elseif btn == "wd" then
				if self.stLine < #self.shipTab - math.floor((self.height - 26) / 17) - 2 then self.stLine = self.stLine + 1 end
				return true
			end
			self.grabbed = true
			self.grabPointX = x - self.x
			self.grabPointY = y - self.y
			return true
		end
	end
	menu:populateDropdowns()
	menu:render()

	return menu
end

return pData