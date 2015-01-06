local win = require "/Lib/screen"

local moon = {}

function moon:spawnMoon()
  local newMoon = {}
  setmetatable(newMoon, self)
  self.__index = self
  newMoon.xVel = 0
  newMoon.yVel = 0
  newMoon.turn = math.random(0, 1)
  newMoon.wind = math.random(1, 5) / 50
  newMoon.spin = math.random(1, 10) / 50
  newMoon.cloudAng = 0
  newMoon.landAng = 0
  newMoon.shadeAng = 0
  newMoon.tw = 305
  newMoon.th = 305
  newMoon.waterImage = love.graphics.newQuad(1, 1, newMoon.tw, newMoon.th, uni.planSet:getDimensions())
  newMoon.landImage = love.graphics.newQuad(306, 1, newMoon.tw, newMoon.th, uni.planSet:getDimensions())
  newMoon.cloudImage = love.graphics.newQuad(611, 1, newMoon.tw, newMoon.th, uni.planSet:getDimensions())
  newMoon.shadeImage = love.graphics.newQuad(916, 1, newMoon.tw, newMoon.th, uni.planSet:getDimensions())
  newMoon.scale = math.random(25, 33) / 100
  return newMoon
end

function moon:generateAtmosphere()
  local rnd = math.random(1, uni.atmoChance)
  if rnd == uni.atmoChance then
    self.atmo = uni.randomAtmo()
  else
    self.atmo = "None"
  end
end

function moon:setAtmoColour(atmo)
  if atmo == "Oxygen" then
    self.ar = 255
    self.ag = 255
    self.ab = 255
  elseif atmo == "Hydrogen" then
    self.ar = math.random(127, 255)
    self.ag = 0
    self.ab = 0
  elseif atmo == "Helium" then
    self.ar = math.random(127, 255)
    self.ag = math.random(127, 255)
    self.ab = 0
  elseif atmo == "Boron" then
    self.ar = 0
    self.ag = math.random(127, 255)
    self.ab = math.random(127, 255)
  else
    self.ar = 255
    self.ag = 255
    self.ab = 255
  end
end

function moon:setHome(id)
  self.home = id
  self.homeStarId = uni.ent[id].homeStarId
end

function moon:move(dt)
  self.x = uni.ent[self.home].x + (self.rad * math.cos(self.heading))
	self.y = uni.ent[self.home].y + (self.rad * math.sin(self.heading))
end

function moon:update(dt)
  dt = dt * uni.gameSpeed
	self.heading = self.heading + (((5000000 - self.rad) / uni.planetSpeed) * dt)
  self.cloudAng = self.cloudAng - ((self.spin + self.wind) * dt)
  self.landAng = self.landAng + (self.spin * dt)
  local dx = uni.ent[self.homeStarId].x - self.x
  local dy = uni.ent[self.homeStarId].y - self.y
  local bearing = math.deg(math.atan2(dy,dx))
  self.shadeAng = math.rad(bearing + 135)
end

function moon:info(id)
    local info = win:newPane(info, 220, 340)
    info.shipId = self.id
    info.id = id
    info.name = uni.ent[info.shipId].name
    info.priority = 9
    info.navScreen = true
    info.cargoScreen = false
    info:move(uni.xOff, uni.yOff)
    
    function info:statBars(x, y)
        self:box(x, y, self.width - (x * 2), 60, 0x00, 0x00, 0x00, uni.opacity)
        self:percentageBar(x + 2, y + 5, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].hp, uni.ent[self.shipId].hpMax)
        self:percentageBar(x + 2, y + 22, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].ap, uni.ent[self.shipId].apMax, 0x99, 0x99, 0x99, uni.opacity, 0x66, 0x66, 0x66, uni.opacity)
        self:percentageBar(x + 2, y + 39, self.width - ((x * 2) + 4), 16, uni.ent[self.shipId].sp, uni.ent[self.shipId].spMax, 0xFF, 0xFF, 0x00, uni.opacity, 0xFF, 0x00, 0x00, uni.opacity)
    end

    function info:renderSetup()
        self:clear()
        self:backdrop()
        self:title(self.name, 0x00, 0x99, 0x99, uni.opacity)
        self:closeButton()
        if self.navScreen then
            self:button("Navigation", "nav_screen", 6, 23, (self.width - 15) / 2, 16, 0x00, 0x66, 0x99, uni.opacity)
            self:button("Trade", "cargo_screen", (self.width / 2) + 5, 23, (self.width - 15) / 2, 16, 0x00, 0x99, 0x99, uni.opacity)
            self:button("Dock", "follow_ship", 6, self.height - 22, self.width - 10, 16)
            self:statBars(6, self.height - 87)
            self:box(6, 44, self.width - 12, self.width - 12, 0x00, 0x00, 0x00, uni.opacity)
            self:setCamera(6, 44, self.width - 12, self.width - 12, uni.ent[self.shipId].x, uni.ent[self.shipId].y)
        elseif self.cargoScreen then
            self:button("Navigation", "nav_screen", 6, 23, (self.width - 15) / 2, 16, 0x00, 0x99, 0x99, uni.opacity)
            self:button("Trade", "cargo_screen", (self.width / 2) + 5, 23, (self.width - 15) / 2, 16, 0x00, 0x66, 0x99, uni.opacity)
            self:box(6, 46, self.width - 10, self.height - 50, 0x00, 0x00, 0x00, 255)
            if uni.ent[self.shipId].cargo ~= nil then
                local yOff = 46
                for i = 1, #uni.ent[self.shipId].cargo do
                    local amt = uni.ent[self.shipId].cargo[i].amt
                    local name = uni.items[uni.ent[self.shipId].cargo[i].id].name
                    self:text(amt.." x "..name..".", 8, yOff, 0x00, 0x99, 0x00, uni.opacity)
                    yOff = yOff + 22
                end
            end
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
                elseif ret == "cargo_screen" then
                    self.navScreen = false
                    self.cargoScreen = true
                elseif ret == "follow_ship" then
                    local list = uni.gatherSelectedTable()
                    for i = 1, #list do
                        if uni.ent[list[i]].type == "ship" then
                            uni.ent[list[i]]:dockAtTarget(self.shipId)
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

return moon