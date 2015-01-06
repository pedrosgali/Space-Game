local win = require "/Lib/screen"
local selection = require "/Game Windows/game_select"

local gameMenu = {}

function gameMenu:newMenu(id)
	local menu = win:newPane(menu, 128, 128)
	menu.priority = 10
	menu.isMoveable = true
	menu.id = id
	menu:box(1, 1, menu.width, menu.height, 0x99, 0x99, 0x99, 0xFF)
	menu:title("Menu", 0x00, 0x99, 0x99, 0xFF)
	menu:button("Resume", "close", 6, 22, menu.width - 10, 16, _, _, _, 0xFF, _, _, _, 0xFF)
	menu:button("New Game", "new", 6, 43, menu.width - 10, 16, _, _, _, 0xFF, _, _, _, 0xFF)
	menu:button("New Target", "load", 6, 66, menu.width - 10, 16, _, _, _, 0xFF, _, _, _, 0xFF)
	menu:button("Toggle Move", "save", 6, 88, menu.width - 10, 16, _, _, _, 0xFF, _, _, _, 0xFF)
	menu:button("Exit", "quit", 6, 110, menu.width - 10, 16, _, _, _, 0xFF, _, _, _, 0xFF)
	menu:center()
	menu:render()

	function menu:mousePressed(x, y, btn)
		if self:isClicked(x, y) then
			local ret = self:buttonClicked(x, y)
			if ret ~= false then
				if ret == "close" then
					self.isVisible = false
				elseif ret == "new" then
                    local id = #cWin + 1
					cWin[id] = selection:newMenu(id)
                    self.isVisible = false
				elseif ret == "load" then
                    
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

	return menu
end

return gameMenu