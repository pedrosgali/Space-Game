local maths = require "/Lib/maths"

local screen = {}

function screen:newPane(object, w, h)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	object.x = 1
	object.y = 1
	object.width = w
	object.height = h
	object.isVisible = true
	object.isMoveable = true
	object.canvas = love.graphics.newCanvas(w, h)
	return object
end

function screen:move(x, y)
	self.x = x
	self.y = y
end

function screen:center()
	local width, height = love.graphics.getDimensions()
	local xOff = (width - self.width) / 2
	local yOff = (height - self.height) / 2
	self:move(xOff, yOff)
end

function screen:clear()
	self.bTab = nil
	self.tTab = nil
	self.lTab = nil
	self.buTab = nil
	self.canvas = nil
	self.camScreen = nil
	self.canvas = love.graphics.newCanvas(self.width, self.height)
end

--BASIC DRAW FUNCTIONS--

function screen:box(x, y, w, h, r, g, b, a)
	if self.bTab == nil then
		self.bTab = {}
		self.bCnt = 0
	end
	self.bCnt = self.bCnt + 1
	self.bTab[self.bCnt] = {}
	self.bTab[self.bCnt].x = x
	self.bTab[self.bCnt].y = y
	self.bTab[self.bCnt].w = w
	self.bTab[self.bCnt].h = h
	self.bTab[self.bCnt].r = r
	self.bTab[self.bCnt].g = g
	self.bTab[self.bCnt].b = b
	self.bTab[self.bCnt].a = a
end

function screen:line(x1, y1, x2, y2, r, g, b, a)
	if self.lTab == nil then
		self.lTab = {}
		self.lCnt = 0
	end
	self.lCnt = self.lCnt + 1
	self.lTab[self.lCnt] = {}
	self.lTab[self.lCnt].x1 = x1
	self.lTab[self.lCnt].y1 = y1
	self.lTab[self.lCnt].x2 = x2
	self.lTab[self.lCnt].y2 = y2
	self.lTab[self.lCnt].r = r
	self.lTab[self.lCnt].g = g
	self.lTab[self.lCnt].b = b
	self.lTab[self.lCnt].a = a
end

function screen:text(text, x, y, r, g, b, a, scale)
	if r == nil then r = 0x00 end
	if g == nil then g = 0x00 end
	if b == nil then b = 0x00 end
	if a == nil then a = uni.opacity end
	if scale == nil then scale = 1 end
	if self.tTab == nil then
		self.tTab = {}
		self.tCnt = 0
	end
	self.tCnt = self.tCnt + 1
	self.tTab[self.tCnt] = {}
	self.tTab[self.tCnt].x = x
	self.tTab[self.tCnt].y = y
	self.tTab[self.tCnt].r = r
	self.tTab[self.tCnt].g = g
	self.tTab[self.tCnt].b = b
	self.tTab[self.tCnt].a = a
	self.tTab[self.tCnt].sx = scale
	self.tTab[self.tCnt].sy = scale
	self.tTab[self.tCnt].text = text
end

function screen:backdrop(r, g, b, a)
	if r == nil then r = 0x99 end
	if g == nil then g = 0x99 end
	if b == nil then b = 0x99 end
	if a == nil then a = uni.opacity end
	self:box(1, 1, self.width, self.height, r, g, b, a)
end

function screen:title(text, r, g, b, a)
	if r == nil then r = 0x00 end
	if g == nil then g = 0x99 end
	if b == nil then b = 0x99 end
	if a == nil then a = uni.opacity end
	self:box(1, 1, self.width, 16, r, g, b, a)
	self:text(text, (self.width - ((#text - 1) * 8)) / 2, 1)
end

--ADVANCED DRAW FUNCTIONS--

function screen:percentageBar(x, y, w, h, part, whole, r, g, b, a, r1, g1, b1, a1, dis)
    if r == nil then r = 0x00 end
	if g == nil then g = 0x99 end
	if b == nil then b = 0x00 end
	if a == nil then a = uni.opacity end
	if r1 == nil then r1 = 0x99 end
	if g1 == nil then g1 = 0x00 end
	if b1 == nil then b1 = 0x00 end
	if a1 == nil then a1 = uni.opacity end
    local boxPerc = w / 100
    local valPerc = maths.percent(part, whole)
    local display = boxPerc * valPerc
    if whole == 0 then
        self:box(x, y, w, h, r1, g1, b1, a1)
    else
        if part > 0 then
            self:box(x, y, display, h, r, g, b, a)
        end
        self:box(x + display, y, w - display, h, r1, g1, b1, a1)
    end
    if dis == "p" or dis == nil then
    	self:text(math.floor(valPerc), x + (w - ((#tostring(math.floor(valPerc)) - 1) * 8)) / 2, y)
    elseif dis == "n" then
    	local str = tostring(math.floor(part).."/"..math.floor(whole))
    	self:text(str, x + (w - ((#str - 1) * 8)) / 2, y)
    end
end

--BUTTONS--

function screen:button(label, returnVal, x, y, w, h, r, g, b, a, r1, g1, b1, a1, scale)
	if r == nil then r = 0x00 end
	if g == nil then g = 0x99 end
	if b == nil then b = 0x99 end
	if a == nil then a = uni.opacity end
	if r1 == nil then r1 = 0x00 end
	if g1 == nil then g1 = 0x00 end
	if b1 == nil then b1 = 0x00 end
	if a1 == nil then a1 = uni.opacity end
	if scale == nil then scale = 1 end
	label = tostring(label)
	if self.buTab == nil then
		self.buTab = {}
		self.buCnt = 0
	end
	self.buCnt = self.buCnt + 1
	self.buTab[self.buCnt] = {}
	self.buTab[self.buCnt].label = label
	self.buTab[self.buCnt].returnVal = returnVal
	self.buTab[self.buCnt].x = x
	self.buTab[self.buCnt].y = y
	self.buTab[self.buCnt].w = w
	self.buTab[self.buCnt].h = h
	self.buTab[self.buCnt].r = r
	self.buTab[self.buCnt].g = g
	self.buTab[self.buCnt].b = b
	self.buTab[self.buCnt].a = a
	self.buTab[self.buCnt].tr = r1
	self.buTab[self.buCnt].tg = g1
	self.buTab[self.buCnt].tb = b1
	self.buTab[self.buCnt].ta = a1
	self.buTab[self.buCnt].scale = scale
end

function screen:closeButton()
	--this comment so I can fold the function, no other reason.  Sorry for wasting your time.
	self:button("X", "close", self.width - 17, 2, 16, 14, 0x99, 0x99, 0x99, uni.opacity)
end

function screen:newDropdown(label, x, y, w, h, r, g, b, a, r1, g1, b1, a1, scale)
	if r == nil then r = 0x00 end
	if g == nil then g = 0x99 end
	if b == nil then b = 0x99 end
	if a == nil then a = uni.opacity end
	if r1 == nil then r1 = 0x00 end
	if g1 == nil then g1 = 0x00 end
	if b1 == nil then b1 = 0x00 end
	if a1 == nil then a1 = uni.opacity end
	if scale == nil then scale = 1 end
	if self.ddTab == nil then
		self.ddTab = {}
		self.ddCnt = 0
	end
	self.ddCnt = self.ddCnt + 1
	self.ddTab[self.ddCnt] = {}
	self.ddTab[self.ddCnt].label = label
	self.ddTab[self.ddCnt].x = x
	self.ddTab[self.ddCnt].y = y
	self.ddTab[self.ddCnt].w = w
	self.ddTab[self.ddCnt].h = h
	self.ddTab[self.ddCnt].r = r
	self.ddTab[self.ddCnt].g = g
	self.ddTab[self.ddCnt].b = b
	self.ddTab[self.ddCnt].a = a
	self.ddTab[self.ddCnt].tr = r1
	self.ddTab[self.ddCnt].tg = g1
	self.ddTab[self.ddCnt].tb = b1
	self.ddTab[self.ddCnt].ta = a1
	self.ddTab[self.ddCnt].scale = scale
	self.ddTab[self.ddCnt].maxLen = 0
	self.ddTab[self.ddCnt].open = false
end

function screen:addDropdownItem(menuName, label, retVal)
	if self.ddTab ~= nil then
		for i = 1, #self.ddTab do
			if self.ddTab[i].label == menuName then
				local count = 1
				if self.ddTab[i].list == nil then
					self.ddTab[i].list = {}
				else
					count = #self.ddTab[i].list + 1
				end
				self.ddTab[i].list[count] = {}
				self.ddTab[i].list[count].label = label
				self.ddTab[i].list[count].returnVal = retVal
				if count == 1 then self.ddTab[i].returnVal = retVal end
				if #label > self.ddTab[i].maxLen then
					self.ddTab[i].maxLen = #label
				end
				return true
			end
		end
	end
end

function screen:newButtonTable(label, x, y, w, h, r, g, b, a, r1, g1, b1, a1)
	if r == nil then r = 0x00 end
	if g == nil then g = 0x99 end
	if b == nil then b = 0x99 end
	if a == nil then a = uni.opacity end
	if r1 == nil then r1 = 0x00 end
	if g1 == nil then g1 = 0x00 end
	if b1 == nil then b1 = 0x00 end
	if a1 == nil then a1 = uni.opacity end
	local count = 1
	if self.blTab == nil then
		self.blTab = {}
	else
		count = #self.blTab + 1
	end
	self.blTab[count] = {}
	self.blTab[count].label = label
	self.blTab[count].x = x
	self.blTab[count].y = y
	self.blTab[count].w = w
	self.blTab[count].h = h
	self.blTab[count].r = r
	self.blTab[count].g = g
	self.blTab[count].b = b
	self.blTab[count].a = a
	self.blTab[count].r1 = r1
	self.blTab[count].g1 = g1
	self.blTab[count].b1 = b1
	self.blTab[count].a1 = a1
	self.blTab[count].startPoint = 1
end

function screen:addTableButton(id, label, returnVal)
	if self.blTab ~= nil then
		for i = 1, #self.blTab do
			if self.blTab[i].label == id then
				local count = 1
				if self.blTab[i].list == nil then
					self.blTab[i].list = {}
				else
					count = #self.blTab[i].list + 1
				end
				self.blTab[i].list[count] = {}
				self.blTab[i].list[count].label = label
				self.blTab[i].list[count].returnVal = returnVal
				self.blTab[i].list[count].selected = false
			end
		end
	end
end

--CLICK CHECKING FUNCTIONS--

function screen:isClicked(x, y)
	if self.isVisible then
		local xmax = self.x + self.width
		local ymax = self.y + self.height
		if x >= self.x and x <= xmax then
		    if y >= self.y and y <= ymax then
		        return true
		    end
		end
	end
	return false
end

function screen:buttonClicked(x, y)
	if self.isVisible then
		if self.buTab ~= nil then
			for i = 1, #self.buTab do
				local xmin = self.x + self.buTab[i].x
				local xmax = xmin + self.buTab[i].w
				local ymin = self.y + self.buTab[i].y
				local ymax = ymin + self.buTab[i].h
				if x >= xmin and x <= xmax then
					if y >= ymin and y <= ymax then
						return(self.buTab[i].returnVal)
					end
				end
			end
		end
	end
	return false
end

function screen:closeDropdowns(id)
	if self.ddTab ~= nil then
		for i = 1, #self.ddTab do
			self.ddTab[i].open = false
		end
		if id ~= nil then
			self.ddTab[id].open = true
		end
	end
end

function screen:dropdownClicked(x, y)
	if self.isVisible then
		if self.ddTab ~= nil then
			for i = 1, #self.ddTab do
				if self.ddTab[i].list ~= nil then
					local xmin = self.x + self.ddTab[i].x
					local xmax = xmin + self.ddTab[i].w
					local ymin = self.y + self.ddTab[i].y
					local ymax = ymin + self.ddTab[i].h
					if x >= xmin and x <= xmax then
						if y >= ymin and y <= ymax then
							if self.ddTab[i].open then
								self:closeDropdowns()
							else
								self:closeDropdowns(i)
							end
							return false
						end
					end
					if self.ddTab[i].open then
						xmin = self.x + self.ddTab[i].x
						xmax = (xmin + (self.ddTab[i].maxLen * 8)) + 10
						ymin = self.y + (self.ddTab[i].y + 16)
						ymax = ymin + 16
						for j = 1, #self.ddTab[i].list do
							if x >= xmin and x <= xmax then
								if y >= ymin and y <= ymax then
									self.ddTab[i].returnVal = self.ddTab[i].list[j].returnVal
									self.ddTab[i].open = false
									return self.ddTab[i].list[j].returnVal
								end
							else
								self.ddTab[i].open = false
							end
							ymin = ymin + 16
							ymax = ymin + 16
						end
						self.ddTab[i].open = false
					end
				end
			end
		end
	end
	return false
end

--CAMERA FUNCTIONS--

function screen:setCamera(x, y, w, h, unix, uniy)
    self.camScreen = true
    self.camx = x
    self.camy = y
    self.camWidth = w
    self.camHeight = h
    self.unix = unix
    self.uniy = uniy
end

function screen:camera(x, y, w, h, unix, uniy)
    local cameraCanvas = love.graphics.newCanvas(w, h)
    local hWid = w / 2
    local hHig = h / 2
    local xMin = math.floor(unix - hWid)
    local xMax = math.floor(unix + hWid)
    local yMin = math.floor(uniy - hHig)
    local yMax = math.floor(uniy + hHig)
    love.graphics.setCanvas(cameraCanvas)
    love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
    for i = 1, #uni.ent do
        local sw, sh = uni.ent[i].tw, uni.ent[i].th
        local offx = sw / 2
        local offy = sh / 2
        local pxOf = math.floor(hWid + (uni.ent[i].x - unix))
        local pyOf = math.floor(hHig + (uni.ent[i].y - uniy))
        local angle = math.rad(uni.ent[i].vizHeading)
        if uni.ent[i].x >= xMin and uni.ent[i].x <= xMax then
            if uni.ent[i].y >= yMin and uni.ent[i].y <= yMax then
                self.scrx = pxOf
                self.scry = pyOf
                if uni.ent[i].type == "ship" then
                	if uni.ent[i].docked == 0 then
                    	love.graphics.draw(uni.shipSet, uni.ent[i].image, pxOf, pyOf, angle, 1, 1, offx, offy)
                    end
                elseif uni.ent[i].type == "station" then
                    love.graphics.draw(uni.statSet, uni.ent[i].image, pxOf, pyOf, angle, 1, 1, offx, offy)
                elseif uni.ent[i].type == "planet" then
                	offx = (uni.ent[i].tw / uni.ent[i].scale) / 2
                  offy = (uni.ent[i].th / uni.ent[i].scale) / 2
                  love.graphics.setColor(uni.ent[i].wr, uni.ent[i].wg, uni.ent[i].wb, 0xFF)
                  love.graphics.draw(uni.planSet, uni.ent[i].waterImage, pxOf, pyOf, angle, 1, 1, offx, offy)
                  love.graphics.setColor(uni.ent[i].lr, uni.ent[i].lg, uni.ent[i].lb, 0xFF)
                  love.graphics.draw(uni.planSet, uni.ent[i].landImage, pxOf, pyOf, uni.ent[i].landAng, 1, 1, offx, offy)
                  love.graphics.setColor(uni.ent[i].ar, uni.ent[i].ag, uni.ent[i].ab, 0xFF)
                  love.graphics.draw(uni.planSet, uni.ent[i].cloudImage, pxOf, pyOf, uni.ent[i].cloudAng, 1, 1, offx, offy)
                  love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
                  love.graphics.draw(uni.planSet, uni.ent[i].shadeImage, pxOf, pyOf, uni.ent[i].shadeAng, 1, 1, offx, offy)
                elseif uni.ent[i].type == "star" then
                  love.graphics.setColor(0xFF, 0x99, 0x00, 255)
                  love.graphics.circle("fill", pxOf, pyOf, 500)
                  love.graphics.setColor(0xFF, 0xFF, 0xFF, 255)
                end
                if uni.ent[i].sp == uni.ent[i].spMax then
                  love.graphics.setColor(0x00, 0x66, 0x66, 255)
                elseif uni.ent[i].sp > uni.ent[i].spMax * .75 then
                  love.graphics.setColor(0x00, 0xFF, 0x00, 255)
                elseif uni.ent[i].sp > uni.ent[i].spMax * .50 then
                  love.graphics.setColor(0xFF, 0x99, 0x00, 255)
                elseif uni.ent[i].sp > uni.ent[i].spMax * .25 then
                  love.graphics.setColor(0xFF, 0xFF, 0x00, 255)
                elseif uni.ent[i].sp > 0 then
                  love.graphics.setColor(0xFF, 0x00, 0x00, 255)
                end
                if uni.ent[i].sp > 0 then
                	if uni.ent[i].type == "ship" then
                		if uni.ent[i].docked == 0 then
                      love.graphics.circle("line", pxOf, pyOf, uni.ent[i].tw)
                    end
                  elseif uni.ent[i].type == "station" then
                    love.graphics.circle("line", pxOf, pyOf, (uni.ent[i].tw / 2) + 5)
                  elseif uni.ent[i].type == "planet" then

                  elseif uni.ent[i].type == "star" then

                  end
                end
                love.graphics.setColor(0xFF, 0xFF, 0xFF, 255)
                if uni.ent[i].selected then
                  love.graphics.setColor(0x00, 0xFF, 0x00, 255)
                  if uni.ent[i].type == "ship" then
                    if uni.ent[i].docked == 0 then
                      love.graphics.circle("line", pxOf, pyOf, uni.ent[i].tw + 5, 6)
                    end
                  elseif uni.ent[i].type == "station" then
                    love.graphics.circle("line", pxOf, pyOf, (uni.ent[i].tw / 2) + 15, 6)
                  elseif uni.ent[i].type == "planet" then

                  elseif uni.ent[i].type == "star" then

                  end
                  love.graphics.setColor(0xFF, 0xFF, 0xFF, 255)
                end
            else
                self.scrx = "none"
                self.scry = "none"
            end
        else
            self.scrx = "none"
            self.scry = "none"
        end
        love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
    end
    return cameraCanvas
end

--RENDER FUNCTIONS--

function screen:renderBoxes()
	if self.bTab ~= nil then
		love.graphics.setCanvas(self.canvas)
		for i = 1, #self.bTab do
			love.graphics.setColor(self.bTab[i].r, self.bTab[i].g, self.bTab[i].b, self.bTab[i].a)
			love.graphics.rectangle("fill", self.bTab[i].x - 1, self.bTab[i].y - 1, self.bTab[i].w, self.bTab[i].h)
		end
		love.graphics.setColor(0xFF, 0xFF, 0xFF, 255)
		love.graphics.setCanvas()
	end
end

function screen:renderText()
	if self.tTab ~= nil then
		love.graphics.setCanvas(self.canvas)
		for i = 1, #self.tTab do
			love.graphics.setColor(self.tTab[i].r, self.tTab[i].g, self.tTab[i].b, self.tTab[i].a)
			love.graphics.print(self.tTab[i].text, self.tTab[i].x, self.tTab[i].y, 0, self.tTab[i].sx, self.tTab[i].sy, 0, 0, 0, 0)
		end
		love.graphics.setColor(0xFF, 0xFF, 0xFF, 255)
		love.graphics.setCanvas()
	end
end

function screen:renderLines()
	if self.lTab ~= nil then
		love.graphics.setCanvas(self.canvas)
		for i = 1, #self.lTab do
			love.graphics.setColor(self.lTab[i].r, self.lTab[i].g, self.lTab[i].b, self.lTab[i].a)
			love.graphics.line(self.lTab[i].x1, self.lTab[i].y1, self.lTab[i].x2, self.lTab[i].y2)
			love.graphics.setColor(0xFF, 0xFF, 0xFF, 255)
		end
		love.graphics.setCanvas()
	end
end

function screen:renderButtons()
	if self.buTab ~= nil then
		love.graphics.setCanvas(self.canvas)
		for i = 1, #self.buTab do
			love.graphics.setColor(self.buTab[i].r, self.buTab[i].g, self.buTab[i].b, self.buTab[i].a)
			love.graphics.rectangle("fill", self.buTab[i].x - 1, self.buTab[i].y - 1, self.buTab[i].w, self.buTab[i].h)
      local str = self.buTab[i].label
      local stLen = ((#str - 1) * 8)
      if stLen > self.buTab[i].w then
        local cWid = math.floor(self.buTab[i].w / 8)
        str = string.sub(str, 1, cWid)
      end
			local xOff = math.floor((self.buTab[i].w - ((#str - 1) * 8)) / 2) - 1
			local yOff = math.floor((self.buTab[i].h - 16) / 2)
			love.graphics.setColor(self.buTab[i].tr, self.buTab[i].tg, self.buTab[i].tb, self.buTab[i].ta)
			love.graphics.print(str, self.buTab[i].x + xOff, self.buTab[i].y + yOff, 0, self.buTab[i].sx, self.buTab[i].sy, 0, 0, 0, 0)
			love.graphics.setColor(0xFF, 0xFF, 0xFF, 255)
		end
		love.graphics.setCanvas()
	end
end

function screen:renderSetup()
	--Rewrite this function to draw to your screen.
	--It should start with a self:clear() to wipe all the tables then establish your window as normal.
end

function screen:renderCamera()
    if self.camScreen then
        local mapView = self:camera(self.camx, self.camy, self.camWidth, self.camHeight, self.unix, self.uniy)
        love.graphics.setCanvas(self.canvas)
        love.graphics.draw(mapView, self.camx, self.camy)
        love.graphics.setCanvas()
    end
end

function screen:renderDropdowns()
	if self.ddTab ~= nil then
		love.graphics.setCanvas(self.canvas)
		for i = 1, #self.ddTab do
			if self.ddTab[i].open then
				love.graphics.setColor(self.ddTab[i].tr, self.ddTab[i].tg, self.ddTab[i].tb, self.ddTab[i].ta)
			else
				love.graphics.setColor(self.ddTab[i].r, self.ddTab[i].g, self.ddTab[i].b, self.ddTab[i].a)
			end
			love.graphics.rectangle("fill", self.ddTab[i].x - 1, self.ddTab[i].y - 1, self.ddTab[i].w, self.ddTab[i].h)
			local xOff = math.floor((self.ddTab[i].w - ((#tostring(self.ddTab[i].returnVal) - 1) * 8)) / 2) - 1
			local yOff = math.floor((self.ddTab[i].h - 16) / 2)
			if self.ddTab[i].open then
				love.graphics.setColor(self.ddTab[i].r, self.ddTab[i].g, self.ddTab[i].b, self.ddTab[i].a)
			else
				love.graphics.setColor(self.ddTab[i].tr, self.ddTab[i].tg, self.ddTab[i].tb, self.ddTab[i].ta)
			end
			love.graphics.print(self.ddTab[i].returnVal, self.ddTab[i].x + xOff, self.ddTab[i].y + yOff, 0, self.ddTab[i].sx, self.ddTab[i].sy, 0, 0, 0, 0)
		end
		for i = 1, #self.ddTab do
			if self.ddTab[i].open then
				local pixWidth = (self.ddTab[i].maxLen * 8) + 10
				local pixHeight = (#self.ddTab[i].list * 16)
				local yOff = 16
				love.graphics.setColor(self.ddTab[i].r, self.ddTab[i].g, self.ddTab[i].b, self.ddTab[i].a)
				love.graphics.rectangle("fill", self.ddTab[i].x, self.ddTab[i].y + yOff, pixWidth, pixHeight)
				love.graphics.setColor(self.ddTab[i].tr, self.ddTab[i].tg, self.ddTab[i].tb, self.ddTab[i].ta)
				for j = 1, #self.ddTab[i].list do
					love.graphics.print(self.ddTab[i].list[j].label, self.ddTab[i].x + 5, self.ddTab[i].y + yOff, 0, self.ddTab[i].sx, self.ddTab[i].sy, 0, 0, 0, 0)
					yOff = yOff + 16
				end
			end
		end
	end
	love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
	love.graphics.setCanvas()
end

function screen:renderButtonTables()
	if self.blTab ~= nil then
		love.graphics.setCanvas(self.canvas)
		for i = 1, #self.blTab do
			if self.blTab[i].list ~= nil then
				local yOff = 0
				local tLayers = math.floor(self.blTab[i].h / 16)
				for j = self.blTab[i].startPoint, self.blTab[i].startPoint + tLayers do
					if self.blTab[i].list[j] ~= nil then
						if self.blTab[i].list[j].selected then
							love.graphics.setColor(self.blTab[i].r, self.blTab[i].g, self.blTab[i].b, self.blTab[i].a)
						else
							love.graphics.setColor(self.blTab[i].r1, self.blTab[i].g1, self.blTab[i].b1, self.blTab[i].a1)
						end
						love.graphics.rectangle("fill", self.blTab[i].x, self.blTab[i].y + yOff, self.blTab[i].w, self.blTab[i].h)
						if self.blTab[i].list[j].selected then
							love.graphics.setColor(self.blTab[i].r1, self.blTab[i].g1, self.blTab[i].b1, self.blTab[i].a1)
						else
							love.graphics.setColor(self.blTab[i].r, self.blTab[i].g, self.blTab[i].b, self.blTab[i].a)
						end
						local xOff = math.floor((self.blTab[i].w - ((#self.blTab[i].list[j].label - 1) * 8)) / 2) - 1
						love.graphics.print(self.blTab[i].list[j].label, self.blTab[i].x + xOff, self.blTab[i].y + yOff)
						yOff = yOff + 17
					end
				end
			end
		end
	end
end

function screen:render()
	if self.isVisible then
		self:renderSetup()
		self:renderBoxes()
		self:renderButtons()
		self:renderButtonTables()
		self:renderText()
		self:renderLines()
	    self:renderCamera()
	    self:renderDropdowns()
	end
end

--CALLBACK FUNCTIONS--

function screen:mousePressed(x, y)
	if self:isClicked(x, y) then
		local ret = self:dropdownClicked(x, y)
		if ret ~= false then
			if ret == "close" then
				self.isVisible = false
			--elseif ret == "your button return value" then
			end
			return true
		end
		ret = self:buttonClicked(x, y)
		if ret ~= false then
			if ret == "close" then
				self.isVisible = false
			--elseif ret == "your button return value" then
			end
			return true
		end
		self.grabbed = true
		self.grabPointX = x - self.x
		self.grabPointY = y - self.y
		return true
	end
end

function screen:mouseReleased()
	--this comment so I can fold the function, no other reason.  Sorry for wasting your time.
	self.grabbed = false
end

function screen:updateCall(dt)
	--You rewrite this in your object to have it update your code while retaining click and drag movement.
	--It gets called at the end of screen:update().
end

function screen:update(dt)
	if self.grabbed and self.isMoveable then
		local width, height = love.graphics.getDimensions() 
		local x = love.mouse.getX()
		local y = love.mouse.getY()
		self:move(x - self.grabPointX, y - self.grabPointY)
		if self.y < 1 then
			self:move(self.x, 1)
		end
		if self.x < 1 then
			self:move(1, self.y)
		end
		if self.y + self.height > height then
			self:move(self.x, height - self.height)
		end
		if self.x + self.width > width then
		    self:move(width - self.width, self.y)
		end
		return true
	end
	self:updateCall(dt)
end

return screen