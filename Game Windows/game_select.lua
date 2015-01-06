local win = require "/Lib/screen"

local gameMenu = {}

function gameMenu:newMenu(id)
  local sx, sy = love.window.getDesktopDimensions()
	local menu = win:newPane(menu, 1024, 512)
	menu.priority = 9
	menu.isMoveable = false
	menu.id = id
  menu.gameMode = 1
	menu:center()
    
    function menu:updateCall()
        self:render()
    end
    
    function menu:renderSetup()
        self:clear()
        menu:backdrop(0x99, 0x99, 0x99, 0xFF)
        local sx, sy = self.width, self.height
        local bWidth = math.floor((sx - 20) / 4)
        local xOff = 6
        local yOff = 6
        local col2 = (xOff * 2) + bWidth
        local col3 = (bWidth * 3) + (xOff * 3)
        local bHeight = sy - (yOff * 2)
        local sbHeight = math.floor((sy - 15) / 2)
        local modOff = yOff
        --Faction list
        self:box(xOff, yOff, bWidth, bHeight, 0x00, 0x00, 0x00, 0xFF)
        --Faction/Player info
        self:box(col2, yOff, bWidth * 2, sbHeight, 0x00, 0x00, 0x00, 0xFF)
        --Game Scenario info
        self:box(col2, sbHeight + (yOff * 2), bWidth * 2, sbHeight, 0x00, 0x00, 0x00, 0xFF)
        self:text(uni.scenarios[self.gameMode].description, col2, yOff, 0x00, 0x99, 0x00, 0xFF)
        --Game Mode List
        modOff = yOff
        self:box(col3, yOff, bWidth, bHeight - 26, 0x00, 0x00, 0x00, 0xFF)
        self:newButtonTable("Scenarios", col3, yOff, bWidth, 16, 0x00, 0x99, 0x00, 0xFF, _, _, _, 0xFF)
        for i = 1, #uni.scenarios do
            self:addTableButton("Scenarios", uni.scenarios[i].name, "sc_"..i)
        end
        self:button("Start Game", "new", self.width - 105, self.height - 22, 100, 16, _, _, _, 0xFF, _, _, _, 0xFF)
    end

	function menu:mousePressed(x, y, btn)
		if self:isClicked(x, y) then
			local ret = self:buttonClicked(x, y)
			if ret ~= false then
				if ret == "close" then
					self.isVisible = false
				elseif ret == "new" then
                    uni.gameMode = self.gameMode
					gameUtils.newGame(self.gameMode)
          self.isVisible = false
				elseif string.sub(ret, 1, 3) == "sc_" then
                    local i = tonumber(string.sub(ret, 4, #ret))
					self.gameMode = i
				elseif ret == "save" then
					
				elseif ret == "quit" then
					love.event.quit()
				end
				return true
			end
			self.grabbed = true
			self.grabPointX = x - self.x
			self.grabPointY = y - self.y
			return true
		end
	end

    menu:render()
	return menu
end

return gameMenu