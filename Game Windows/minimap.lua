local win = require "/Lib/screen"
local maths = require "/Lib/maths"

local mData = {}

function mData:newMap(id)
  local map = win:newPane(map, 512, 512)
  map.priority = 9
	map.isMoveable = true
	map.isVisible = false
	map.id = id
  map.zoom = .0000041
  map.x = 0
  map.y = 0
  
  function map:getMapCoordinates(x, y, scale)
    local wid, hig = self.width - 10, self.height - 27
    local hWid = wid / 2 * (1 / scale)
    local hHig = hig / 2 * (1 / scale)
    local xMin = maths.round(uni.x - hWid, 0)
    local yMin = maths.round(uni.y - hHig, 0)
    local retx = maths.round(xMin + (x * (1 / scale)), 0)
    local rety = maths.round(yMin + (y * (1 / scale)), 0)
    return retx, rety
  end

  function map:getScreenCoordinates(x, y, scale)
    local wid, hig = self.width - 10, self.height - 27
    local hWid = wid / 2 * (1 / scale)
    local hHig = hig / 2 * (1 / scale)
    local pxOf = maths.round(hWid + (x - self.x))
    local pyOf = maths.round(hHig + (y - self.y))
    return math.floor(pxOf), math.floor(pyOf)
  end
  
  function map:drawStars()
    love.graphics.setCanvas(self.canvas)
    love.graphics.push()
    love.graphics.scale(self.zoom, self.zoom)
    if uni ~= nil then
      if uni.ent ~= nil then
        for i = 1, #uni.starList do
          local pxOf, pyOf = self:getScreenCoordinates(uni.ent[uni.starList[i]].x, uni.ent[uni.starList[i]].y, self.zoom)
          love.graphics.setColor(0x99, 0x99, 0x99, 0x99)
          love.graphics.point(pxOf, pyOf)
        end
      end
    end
    self:drawViewBox()
    love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
    love.graphics.pop()
    love.graphics.setCanvas()
  end
  
  function map:drawViewBox()
    local sw, sh = love.window.getDesktopDimensions()
    local hw, hh = sw / 2 * (1 / uni.scale), sh / 2 * (1 / uni.scale)
    local vw, vh = (sw * (1 / uni.scale)), (sh * (1 / uni.scale))
    local sx, sy = self:getScreenCoordinates(uni.x - hw, uni.y - hh, self.zoom)
    love.graphics.setCanvas(self.canvas)
    love.graphics.setColor(0x00, 0x99, 0x00, 0x99)
    love.graphics.rectangle("line", sx, sy, vw, vh)
    love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
    love.graphics.setCanvas()
  end
  
  function map:renderSetup()
    self:clear()
    self:backdrop()
    self:title("Minimap")
    self:closeButton()
    self:box(6, 22, self.width - 10, self.height - 27, 0x00, 0x00, 0x00, uni.opacity)
  end
  
  function map:render()
    if self.isVisible then
      self:renderSetup()
      self:renderBoxes()
      self:renderButtons()
      self:renderButtonTables()
      self:renderText()
      self:renderLines()
      self:renderCamera()
      self:renderDropdowns()
      self:drawStars()
    end
  end
  
  function map:updateCall()
    self:render()
  end
  
  function map:mapClickCheck(x, y)
    x = x - self.x
    y = y - self.y
    if x >= 6 and x <= self.width - 10 then
      if y >= 27 and y <= self.height - 27 then
        local scale = self.zoom
        local wid, hig = self.width - 10, self.height - 27
        local hWid = wid / 2 * (1 / scale)
        local hHig = hig / 2 * (1 / scale)
        local xMin = maths.round(x - hWid, 0)
        local yMin = maths.round(y - hHig, 0)
        local xPos = maths.round(xMin + (x * (1 / scale)), 0)
        local yPos = maths.round(yMin + (y * (1 / scale)), 0)
        uni.setCamera(xPos, yPos)
        return true
      end
    end
  end
  
  function map:mousePressed(x, y, btn)
    if self:isClicked(x, y) then
      if btn == "l" then
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
        if self:mapClickCheck(x, y) then return true end
        self.grabbed = true
        self.grabPointX = x - self.x
        self.grabPointY = y - self.y
        return true
      elseif btn == "wu" then
        if self.zoom < .0000201 then
          self.zoom = self.zoom + .0000001
        end
      elseif btn == "wd" then
        if self.zoom > .0000201 then
          self.zoom = self.zoom - .0000001
        end
      end
      if self.zoom < .0000041 then
        self.zoom = .0000041
      end
      return true
    end
  end
  map:render()
  return map
end

return mData