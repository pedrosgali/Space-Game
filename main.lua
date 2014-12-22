local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local namegen = require "/Lib/namegen"
local menu = require "/Game Windows/menu"
local play = require "/Game Windows/player"
local map = require "/Game Windows/minimap"
local ec = require "/Game Windows/economy"

--SWITCHES--

dbgBool = false

--VARIABLES--

local version = 0.2
local maxPanes = 10
local scrollBorder = 10

--GLOBAL TABLES--
--Universe table...
uni = {}
uni.gameType = 0
uni.selected = 0
uni.isPaused = true
uni.player = "Human"
uni.mapChoice = 2
uni.mapSize = 800
uni.maxMoons = 10
uni.moonChance = 5
uni.starChance = 5000
uni.lifeChance = 20
uni.starClumping = 6000
uni.planetMinRad = 5000
uni.planetMaxRad = 25000
uni.minMoonRad = 500
uni.moonSpacing = 250
uni.atmoChance = 20
uni.statMinRad = 50
uni.statMaxRad = 150
uni.maxStartShips = 50
uni.stationTimer = 0
uni.stationTick = 10
uni.economyTimer = 0
uni.economyTick = 120
uni.factionTimer = 0
uni.factionTick = 60
uni.skimPerc = 1.1
uni.maxShipLog = 100
uni.maxAiLog = 1000
uni.fCount = 0
uni.fTog = 1
uni.factionCash = 10000000
uni.x = 0
uni.y = 0
uni.xOff = 1
uni.yOff = 1
uni.catchArea = 13
uni.scrollSpeed = 20
uni.gameSpeed = 1
uni.maxGameSpeed = 5
uni.opacity = 0x99
uni.selx1 = "none"
uni.selx2 = "none"
uni.sely1 = "none"
uni.sely2 = "none"
uni.scale = 0.2
uni.iconCutoff = 0.04
uni.atmoTypes = {[1] = "Oxygen", [2] = "Hydrogen", [3] = "Boron", [4] = "Helium",}
uni.shipSet = love.graphics.newImage("/Assets/Ships/ships.png")
uni.statSet = love.graphics.newImage("/Assets/Stations/stations.png")
uni.planSet = love.graphics.newImage("/Assets/Planets/planet1.png")

--Child window table...
cWin = {}

--Game utility table...
gameUtils = {}
gameUtils.applyVelocity = true

--RESOURCE LOADING FUNCTIONS--

function addMaps(path)
	local list = love.filesystem.getDirectoryItems(path)
	local count = 0
	if uni.maps == nil then
    uni.maps = {}
  else
    count = #uni.maps
  end
  for _, v in ipairs(list) do
    count = count + 1
    local file = path.."/"..string.sub(v, 1, #v - 4)
    uni.maps[count] = require(file)
    gameUtils.debug("Adding "..path.."/"..v)
  end
	gameUtils.debug("All ships added from "..path..".")
end

function addShips(path)
	local list = love.filesystem.getDirectoryItems(path)
	local count = 0
	if uni.shipyard == nil then
    uni.shipyard = {}
  else
    count = #uni.shipyard
  end
  for _, v in ipairs(list) do
    count = count + 1
    local file = path.."/"..string.sub(v, 1, #v - 4)
    uni.shipyard[count] = require(file)
    gameUtils.debug("Adding "..path.."/"..v)
  end
	gameUtils.debug("All ships added from "..path..".")
end

function addStations(path)
	local list = love.filesystem.getDirectoryItems(path)
    local count = 0
	if uni.sTypes == nil then
    	uni.sTypes = {}
    else
    	count = #uni.sTypes
    end
    for _, v in ipairs(list) do
        count = count + 1
        local file = path.."/"..string.sub(v, 1, #v - 4)
        uni.sTypes[count] = require(file)
        gameUtils.debug("Adding "..path.."/"..v)
    end
	gameUtils.debug("All stations added from "..path..".")
end

function addPlanets(path)
	local list = love.filesystem.getDirectoryItems(path)
  local count = 0
	if uni.pTypes == nil then
    uni.pTypes = {}
  else
    count = #uni.pTypes
  end
  for _, v in ipairs(list) do
    count = count + 1
    local file = path.."/"..string.sub(v, 1, #v - 4)
    uni.pTypes[count] = require(file)
    gameUtils.debug("Adding "..path.."/"..v)
  end
	gameUtils.debug("All planets added from "..path..".")
end

function addMoons(path)
  local list = love.filesystem.getDirectoryItems(path)
  local count = 0
	if uni.mTypes == nil then
    uni.mTypes = {}
  else
    count = #uni.mTypes
  end
  for _, v in ipairs(list) do
    count = count + 1
    local file = path.."/"..string.sub(v, 1, #v - 4)
    uni.mTypes[count] = require(file)
    gameUtils.debug("Adding "..path.."/"..v)
  end
	gameUtils.debug("All planets added from "..path..".")
end

function addStars(path)
	local list = love.filesystem.getDirectoryItems(path)
    local count = 0
	if uni.starTypes == nil then
    	uni.starTypes = {}
    else
    	count = #uni.starTypes
    end
    for _, v in ipairs(list) do
        count = count + 1
        local file = path.."/"..string.sub(v, 1, #v - 4)
        uni.starTypes[count] = require(file)
        gameUtils.debug("Adding "..path.."/"..v)
    end
	gameUtils.debug("All planets added from "..path..".")
end

function addItems(path)
    local list = love.filesystem.getDirectoryItems(path)
    local count = 0
	if uni.items == nil then
    	uni.items = {}
    else
    	count = #uni.items
    end
    for _, v in ipairs(list) do
        count = count + 1
        local file = path.."/"..string.sub(v, 1, #v - 4)
        uni.items[count] = require(file)
        gameUtils.debug("Adding "..path.."/"..v)
    end
	gameUtils.debug("All Items added from "..path..".")
end

function addEquipment(path)
    local list = love.filesystem.getDirectoryItems(path)
    local count = 0
    if uni.eqList == nil then
        uni.eqList = {}
    else
        count = #uni.eqList
    end
    for _, v in ipairs(list) do
        count = count + 1
        local file = path.."/"..string.sub(v, 1, #v - 4)
        uni.eqList[count] = require(file)
        gameUtils.debug("Adding "..path.."/"..v)
    end
    gameUtils.debug("All Equipment added from "..path..".")
end

function addRaces(path)
    local list = love.filesystem.getDirectoryItems(path)
    local count = 0
	if uni.factionList == nil then
    	uni.factionList = {}
    else
    	count = #uni.factionList
    end
    for _, v in ipairs(list) do
        count = count + 1
        local file = path.."/"..string.sub(v, 1, #v - 4)
        uni.factionList[count] = require(file)
        gameUtils.debug("Adding "..path.."/"..v)
    end
	gameUtils.debug("All Races added from "..path..".")
end

function addScenarios(path)
    local list = love.filesystem.getDirectoryItems(path)
    local count = 0
	if uni.scenarios == nil then
    	uni.scenarios = {}
    else
    	count = #uni.scenarios
    end
    for _, v in ipairs(list) do
        count = count + 1
        local file = path.."/"..string.sub(v, 1, #v - 4)
        uni.scenarios[count] = require(file)
        gameUtils.debug("Adding "..path.."/"..v)
    end
	gameUtils.debug("All Scenarios added from "..path..".")
end

function addFactionAi(path)
    local list = love.filesystem.getDirectoryItems(path)
    local count = 0
	if uni.aiList == nil then
    	uni.aiList = {}
    else
    	count = #uni.aiList
    end
    for _, v in ipairs(list) do
        count = count + 1
        local file = path.."/"..string.sub(v, 1, #v - 4)
        uni.aiList[count] = require(file)
        gameUtils.debug("Adding "..path.."/"..v)
    end
	gameUtils.debug("All AIs added from "..path..".")
end

function addStationAi(path)
    local list = love.filesystem.getDirectoryItems(path)
    local count = 0
	if uni.statAiList == nil then
    	uni.statAiList = {}
    else
    	count = #uni.statAiList
    end
    for _, v in ipairs(list) do
        count = count + 1
        local file = path.."/"..string.sub(v, 1, #v - 4)
        uni.statAiList[count] = require(file)
        gameUtils.debug("Adding "..path.."/"..v)
    end
	gameUtils.debug("All AIs added from "..path..".")
end

function loadResources(path)
	local list = love.filesystem.getDirectoryItems(path)
  for _, v in ipairs(list) do
    local data = path.."/"..v.."/"
    addMaps(data.."Mapgen")
    addItems(data.."Items")
    addEquipment(data.."Equipment")
    addShips(data.."Ships")
    addStations(data.."Stations")
    addPlanets(data.."Planets")
    addMoons(data.."Moons")
    addStars(data.."Stars")
    addScenarios(data.."Scenarios")
    addRaces(data.."Races")
    addFactionAi(data.."Faction AI")
    addStationAi(data.."Station AI")
  end
	gameUtils.debug("All resources added.")
end


--GAME UTILITY SETUP--

function gameUtils.debug(message, clear)
	if dbgBool then
		if clear ~= nil then gameUtils.dbgMsg = nil end
		if gameUtils.dbgMsg == nil then
			gameUtils.dbgMsg = {}
			gameUtils.cnt = 1
		end
		gameUtils.cnt = gameUtils.cnt + 1
		gameUtils.dbgMsg[gameUtils.cnt] = message
	end
end

function gameUtils.debugPane(id)
	local dbg = win:newPane(dbg, 360, 700)
	dbg:center()
	dbg.priority = 9
  dbg.id = id

	function dbg:renderSetup()
		self:clear()
		self:backdrop()
		self:title("Debug Window")
		self:closeButton()
		self:box(6, 22, self.width - 10, self.height - 26, 0x00, 0x00, 0x00, uni.opacity)
		local height = self.height - 26
		local xPos = 8
		local yOff = 22
		local tHeight = 15
		if gameUtils.dbgMsg ~= nil then
			local startLine = 1
			if #gameUtils.dbgMsg > math.floor(height / tHeight) then
				startLine = #gameUtils.dbgMsg - math.floor(height / tHeight) + 1
			end
			for i = startLine, #gameUtils.dbgMsg do
				if gameUtils.dbgMsg[i] ~= nil then
					self:text(gameUtils.dbgMsg[i], xPos, yOff, 0x00, 0x99, 0x00, uni.opacity)
					yOff = yOff + tHeight
				end
			end
		end
	end
	--dbg:render()
	return dbg
end

function gameUtils.checkOpen(id)
	for i = 2, #cWin do
		if cWin[i].shipId == id then return i end
	end
	return false
end

function gameUtils.closeWindow(wId)
  if wId < 6 then
    cWin[wId].isVisible = false
  else
    local cWinMax = #cWin
    local newTab = {}
    local count = 1
    cWin[wId] = nil
    for i = 1, cWinMax do
      if cWin[i] ~= nil then
        newTab[count] = cWin[i]
        newTab[count].id = count
        count = count + 1
      end
    end
    cWin = newTab
  end
end

function gameUtils.sortPriority()
	for i = 2, #cWin do
		if cWin[i].priority > 1 then
			cWin[i].priority = cWin[i].priority - 1
		end
	end
end

function gameUtils.entitySearch(type, fact)
	local rTab = {}
	local c = 1
	for i = 1, #uni.ent do
		if fact == nil then
			if uni.ent[i].type == type then
				rTab[c] = i
				c = c + 1
			end
		else
		    if uni.ent[i].type == type and uni.ent[i].faction == fact then
				rTab[c] = i
				c = c + 1
			end
		end
	end
	return rTab
end

function gameUtils.searchList(list, key, value)
	local count = 1
	local rTab = {}
	for i = 1, #list do
		for k, v in pairs(uni.ent[list[i]]) do
			if k == key then
				if value == nil or value == "all" or v == value then
					rTab[count] = list[i]
				end
			end
		end
	end
	return rTab
end

function gameUtils.newGame(id)
	uni.factions = nil
  uni.maps[uni.mapChoice]:generate()
	uni.scenarios[id]:init()
	uni.starList = uni.searchList("star", "all")
	for i = 1, #uni.factions do
		uni.factions[i]:init()
	end
  uni.updateEconomy()
  uni.updateStations()
	cWin = nil
	cWin = {}
	cWin[1] = menu:newMenu(1)
	cWin[1].isVisible = false
  cWin[2] = gameUtils.debugPane(2)
	cWin[3] = play:newSheet(3)
  cWin[4] = ec:newSheet(4)
  cWin[5] = map:newMap(5)
	if not dbgBool then cWin[2].isVisible = false end
  uni.isPaused = false
end


--UNIVERSE FUNCTIONS SETUP--
--Map/Camera functions...

function uni.setCamera(x, y)
	uni.x = x
	uni.y = y
end

function uni.clearSelected(id, bool)
	if id == nil then
		for i = 1, #uni.ent do
			uni.ent[i].selected = false
		end
		return
	end
	if not love.keyboard.isDown("rctrl") and not love.keyboard.isDown("lctrl") then
		for i = 1, #uni.ent do
			uni.ent[i].selected = false
		end
		uni.ent[id].selected = true
		if bool then
			uni.selected = id
		end
	else
		uni.ent[id].selected = not uni.ent[id].selected
		if bool then
			uni.selected = id
		end
	end
end

function uni.getMapCoordinates(x, y)
	local wid, hig = love.window.getDesktopDimensions()
	local hWid = wid / 2 * (1 / uni.scale)
	local hHig = hig / 2 * (1 / uni.scale)
	local xMin = maths.round(uni.x - hWid, 0)
	local yMin = maths.round(uni.y - hHig, 0)
	local retx = maths.round(xMin + (x * (1 / uni.scale)))
	local rety = maths.round(yMin + (y * (1 / uni.scale)))
	return retx, rety
end

function uni.getScreenCoordinates(x, y)
	local wid, hig = love.window.getDesktopDimensions()
	local hWid = wid / 2 * (1 / uni.scale)
	local hHig = hig / 2 * (1 / uni.scale)
	local pxOf = maths.round(hWid + (x - uni.x))
	local pyOf = maths.round(hHig + (y - uni.y))
	return math.floor(pxOf), math.floor(pyOf)
end

function uni.getDistance(selfx, selfy, objx, objy)
	local xDiff = objx - selfx
	local yDiff = objy - selfy
	return maths.pyth(xDiff, yDiff)
end

function uni.selectionBox(x1, y1, x2, y2)
	for i = 1, #uni.ent do
		local x = uni.ent[i].x
		local y = uni.ent[i].y
		if x >= x1 and x <= x2 then
			if y >= y1 and y <= y2 then
				if uni.ent[i].type == "ship" then
					uni.ent[i].selected = true
				end
			end
		end
	end
end

function uni.gatherSelectedTable(faction)
    --if faction == nil then faction = uni.player end --Lines taken out for testing.
	local rTab = {}
	local c = 1
	for i = 1, #uni.ent do
		--if uni.ent[i].faction == faction then
			if uni.ent[i].selected and uni.ent[i].type == "ship" then
				rTab[c] = i
				c = c + 1
			end
		--end
	end
	return rTab
end


--Class lookups etc...

function uni.searchList(eType, class, faction)
	if class == nil then class = "all" end
	if faction == nil then faction = "all" end
	local rTab = {}
	local c = 1
	for i = 1, #uni.ent do
		if uni.ent[i].type == eType then
			if class ~= "all" then
				if uni.ent[i].class == class then
					if uni.ent[i].faction == faction or faction == "all" then
						rTab[c] = i
						c = c + 1
					end
				end
			else
				if uni.ent[i].faction == faction or faction == "all" then
					rTab[c] = i
					c = c + 1
				end
			end
		end
	end
	return rTab
end

function uni.mapLookup(name)
  for i = 1, #uni.shipyard do
    if uni.maps[i].name == name then return i end
  end
end

function uni.shipClassLookup(class)
    for i = 1, #uni.shipyard do
        if uni.shipyard[i].class == class then return i end
    end
end

function uni.statClassLookup(class)
    for i = 1, #uni.sTypes do
        if uni.sTypes[i].class == class then return i end
    end
end

function uni.planetClassLookup(class)
    for i = 1, #uni.pTypes do
        if uni.pTypes[i].class == class then return i end
    end
end

function uni.moonClassLookup(class)
  for i = 1, #uni.mTypes do
    if uni.mTypes[i].class == class then return i end
  end
end

function uni.stellarClassLookup(class)
    for i = 1, #uni.starTypes do
        if uni.starTypes[i].class == class then return i end
    end
end

function uni.raceLookup(name)
    for i = 1, #uni.factionList do
        if uni.factionList[i].name == name then return i end
    end
end

function uni.factionLookup(name)
    for i = 1, #uni.factions do
        if uni.factions[i].name == name then return i end
    end
end

function uni.shipLookup(name)
    for i = 1, #uni.ent do
        if uni.ent[i].name == name then return i end
    end
end

function uni.equipmentLookup(name)
    for i = 1, #uni.eqList do
        if uni.eqList[i].name == name then return i end
    end
end

function uni.statAiLookup(name)
    for i = 1, #uni.statAiList do
        if uni.statAiList[i].type == name then return i end
    end
end

function uni.countEntities()
  if uni.ent ~= nil then
    local pCount = 0
    local shipCount = 0
    local statCount = 0
    for i = 1, #uni.ent do
      if uni.ent[i].type == "planet" then
        pCount = pCount + 1
      elseif uni.ent[i].type == "station" then
        statCount = statCount + 1
      elseif uni.ent[i].type == "ship" then
        shipCount = shipCount + 1
      end
    end
    gameUtils.debug("Stars    : "..#uni.starList, "c")
    gameUtils.debug("Planets  : "..pCount)
    gameUtils.debug("Factions : "..#uni.factions)
    gameUtils.debug("Stations : "..statCount)
    gameUtils.debug("Ships    : "..shipCount)
  end
end

--Spawning functions...

function uni.incrementTable()
    if uni.ent == nil then
        uni.ent = {}
        uni.eCnt = 1
    else
        uni.eCnt = #uni.ent + 1
    end
end

function uni.spawnFaction(name, raceId, homePlanet, hp, ap, sp)
	local count = 1
	if uni.factions == nil then
		uni.factions = {}
	else
		count = #uni.factions + 1
	end
	uni.factions[count] = uni.factionList[raceId]:newFaction(uni.factions[count], count, name, homePlanet, hp, ap, sp)
	uni.fCount = count
	uni.selected = homePlanet
end

function uni.spawnShip(name, class, faction, home)
	uni.incrementTable()
    local id = uni.shipClassLookup(class)
	uni.ent[uni.eCnt] = uni.shipyard[id]:spawnShip(uni.ent[uni.eCnt], name, faction, home)
	uni.ent[uni.eCnt].id = uni.eCnt
	uni.ent[uni.eCnt].home = home
  uni.ent[uni.eCnt].star = uni.ent[uni.eCnt]:findClosestStar()
	if uni.ent[home].type == "planet" then
		uni.ent[uni.eCnt]:setOrbit(home)
	elseif uni.ent[home].type == "station" then
		uni.ent[uni.eCnt]:dockAtTarget(home)
	end
end

function uni.newStationAi(type, id)
	local aiId = uni.statAiLookup(type)
	local ai = uni.statAiList[aiId]:newAi(uni.ent[id].ai, id)
	return ai
end

function uni.spawnStation(name, class, radius, homePlanet, faction, x, y)
    uni.incrementTable()
    local id = uni.statClassLookup(class)
    uni.ent[uni.eCnt] = uni.sTypes[id]:spawnStation()
    uni.ent[uni.eCnt].name = name
    uni.ent[uni.eCnt].faction = faction
    uni.ent[uni.eCnt].heading = math.random(0, 359)
    uni.ent[uni.eCnt].vizHeading = 0
    uni.ent[uni.eCnt].bearing = 0
    uni.ent[uni.eCnt].x = x + uni.ent[uni.eCnt].tw / 2
    uni.ent[uni.eCnt].y = y + uni.ent[uni.eCnt].th / 2
    uni.ent[uni.eCnt].id = uni.eCnt
    uni.ent[uni.eCnt].rad = radius * uni.ent[homePlanet].scale
    uni.ent[uni.eCnt].homePlanetId = homePlanet
    uni.ent[uni.eCnt].homeStarId = uni.ent[homePlanet].homeStarId
    uni.ent[uni.eCnt].ai = uni.equipItem(uni.eCnt, "Supplier AI")
    uni.ent[uni.ent[homePlanet].homeStarId]:addStation(uni.eCnt)
end

function uni.getEquipment(name, id, slot)
    local eqId = uni.equipmentLookup(name)
    local retEq = uni.eqList[eqId]:equipItem(uni.ent[id].eqTab[slot].equipped)
    return retEq
end

function uni.equipItem(shipId, itemName)
    uni.ent[shipId]:logEntry("Equipping "..itemName.." on ship "..shipId, "clear")
    local eqId = uni.equipmentLookup(itemName)
    uni.ent[shipId]:logEntry("Equipment ID: "..eqId)
    if uni.ent[shipId].eqTab ~= nil then
        uni.ent[shipId]:logEntry("Equipment enabled on ship...")
        for i = 1, #uni.ent[shipId].eqTab do
            uni.ent[shipId]:logEntry("Checking slot "..i)
            if uni.ent[shipId].eqTab[i].slot == uni.eqList[eqId].slot then
                uni.ent[shipId]:logEntry("Matching slot found.")
                --if uni.ent[shipId].eqTab[i].id == nil then
                    uni.ent[shipId]:logEntry("Slot is empty...")
                    uni.ent[shipId].eqTab[i].equipped = uni.getEquipment(itemName, shipId, i)
                    uni.ent[shipId].eqTab[i].equipped.id = shipId
                    uni.ent[shipId].eqTab[i].equipped:onEquip()
                    uni.ent[shipId]:logEntry(uni.ent[shipId].eqTab[i].equipped.name)
                    uni.ent[shipId]:logEntry("Equipment ready.")
                --else
                    --gameUtils.debug("Slot full.")
                --end
            else
                uni.ent[shipId]:logEntry("Wrong Type.")
            end
        end
    end
end

function uni.randomAtmo()
	local rAt = math.random(1, #uni.atmoTypes)
	return uni.atmoTypes[rAt]
end

function uni.spawnPlanet(name, class, radius, homeStar, faction, x, y)
	uni.incrementTable()
  local myId = uni.eCnt
  local id = uni.planetClassLookup(class)
	uni.ent[myId] = uni.pTypes[id]:spawnPlanet(uni.ent[uni.eCnt], name, faction, x, y)
	uni.ent[myId].id = myId
	uni.ent[myId].rad = radius
	uni.ent[myId].homeStarId = homeStar
  local rad = uni.minMoonRad * uni.ent[myId].scale
  for i = 1, uni.maxMoons do
    local mChance = math.random(1, uni.moonChance)
    if mChance == uni.moonChance then
      local angle = math.random(0, 359)
      local xPos, yPos = uni.ent[myId].x + (rad * math.cos(angle)), (uni.ent[myId].y + (rad * math.sin(angle)) / 2)
      local rcl = math.random(1, #uni.mTypes)
      local mClass = uni.mTypes[rcl].class
      uni.spawnMoon(namegen.randomName(), mClass, rad, myId, faction, xPos, yPos)
      rad = (rad + math.random(uni.moonSpacing / 3, uni.moonSpacing) * uni.ent[myId].scale)
    end
  end
end

function uni.spawnMoon(name, class, radius, homePlanet, faction, x, y)
  uni.incrementTable()
  local id = uni.moonClassLookup(class)
	uni.ent[uni.eCnt] = uni.mTypes[id]:spawnMoon(name, faction, x, y)
	uni.ent[uni.eCnt].id = uni.eCnt
	uni.ent[uni.eCnt].rad = radius
  uni.ent[uni.eCnt]:setHome(homePlanet)
end

function uni.spawnStar(name, class, faction, x, y, ang)
	uni.incrementTable()
    local id = uni.stellarClassLookup(class)
	uni.ent[uni.eCnt] = uni.starTypes[id]:spawnStar(uni.ent[uni.eCnt], name, faction, x, y)
	uni.ent[uni.eCnt].id = uni.eCnt
  uni.ent[uni.eCnt].heading = ang
  uni.ent[uni.eCnt].rad = uni.getDistance(x, y, 1, 1)
	uni.ent[uni.eCnt]:generateSystem()
end


--Update and economy stuff...

function uni.gatherStarProduction(id)
    local rTab = {}
    for i = 1, #uni.items do
        rTab[i] = {}
        rTab[i].amt = 0
        if uni.ent[id].stTab ~= nil then
	        for st = 1, #uni.ent[id].stTab do
	            local stId = uni.ent[id].stTab[st]
	            for pr = 1, #uni.ent[stId].productList do
	                if uni.ent[stId].productList[pr].item == i then
	                	rTab[i].amt = rTab[i].amt + uni.items[i].batch
	                end
	            end
	        end
	    end
    end
    return rTab
end

function uni.gatherStarReagents(id)
    local rTab = {}
    for i = 1, #uni.items do
        rTab[i] = {}
        rTab[i].amt = 0
        if uni.ent[id].stTab ~= nil then
	        for st = 1, #uni.ent[id].stTab do
	            local stId = uni.ent[id].stTab[st]
	            for pr = 1, #uni.ent[stId].reagentList do
	                if uni.ent[stId].reagentList[pr].item == i then
	            		rTab[i].amt = rTab[i].amt + uni.ent[stId].reagentList[pr].batch
	                end
	            end
	        end
	    end
    end
    return rTab
end

function uni.updateEconomy()
    for st = 1, #uni.starList do
        local solarProduct = uni.gatherStarProduction(uni.starList[st])
        local solarRequire = uni.gatherStarReagents(uni.starList[st])
        uni.ent[uni.starList[st]].econ = {}
        for i = 1, #uni.items do
            uni.ent[uni.starList[st]].econ[i] = math.max((200 - maths.percent(solarProduct[i].amt, solarRequire[i].amt)) / 100, .3)
        end
    end
end

function uni.updateStations()
	for st = 1, #uni.starList do
		local stId = uni.starList[st]
		if uni.ent[stId].stTab ~= nil then
			for s = 1, #uni.ent[stId].stTab do
				local statId = uni.ent[stId].stTab[s]
				for i = 1, #uni.ent[statId].productList do
					local id = uni.ent[statId].productList[i].item
					local amtHave = uni.ent[statId].productList[i].amt
	        		local storeMax = uni.ent[statId].hpMax / 2
					uni.ent[statId]:checkProduction(id, i)
					uni.ent[statId].productList[i].cost = math.floor((uni.items[id].cost * uni.ent[stId].econ[id]) * (200 - maths.percent(amtHave, storeMax)) / 100)
				end
				for i = 1, #uni.ent[statId].reagentList do
					local id = uni.ent[statId].reagentList[i].item
					local amtHave = uni.ent[statId].reagentList[i].amt
	        		local storeMax = uni.ent[statId].hpMax / 2
					uni.ent[statId].reagentList[i].cost = math.floor((uni.items[id].cost * uni.ent[stId].econ[id]) * (200 - maths.percent(amtHave, storeMax)) / 100)
				end
			end
		end
	end
end

function uni.updateFactions()
  local stList = uni.searchList("station")
  for i = 1, #stList do
      if uni.ent[stList[i]].ai ~= nil then
        uni.ent[stList[i]].ai:turn()
      end
  end
	for i = 1, #uni.factions do
		--uni.factions[i].ai:turn()
	end
end


--CALLBACK FUNCTIONS--

function love.load()
	math.randomseed(os.time())
	local x, y = love.window.getDesktopDimensions()
	local success = love.window.setMode(x, y)
	local success = love.window.setFullscreen(true)
    font = love.graphics.newFont("/Fonts/larabiefont rg.ttf", 12)
    love.graphics.setFont(font)
	love.window.setTitle("Space Game Version: "..version)
    loadResources("/Resources")
    cWin[1] = menu:newMenu(1)
	cWin[2] = gameUtils.debugPane(2)
	if not dbgBool then cWin[2].isVisible = false end
	gameUtils.debug("Debug pane initialized...")
end

function love.mousepressed(x, y, button)
	for p = maxPanes, 1, -1 do
		for i = 1, #cWin do
			if cWin[i].priority == p then
				if cWin[i]:mousePressed(x, y, button) then
					gameUtils.sortPriority()
					if cWin[i] ~= nil then
						cWin[i].priority = 9
					end
					return true
				end
			end
		end
	end
  if uni ~= nil then
    if uni.ent ~= nil then
      for i = 1, #uni.ent do
        local scrx, scry = uni.getMapCoordinates(x, y)
        local offx = uni.ent[i].tw / 2
        local offy = uni.ent[i].th / 2
        local xmin = scrx - offx
        local ymin = scry - offy
        local xmax = scrx + offx
        local ymax = scry + offy
        if uni.ent[i].x >= xmin and uni.ent[i].x <= xmax then
          if uni.ent[i].y >= ymin and uni.ent[i].y <= ymax then
            uni.getScreenCoordinates(uni.ent[i].x, uni.ent[i].y)
            if button == "l" then
              uni.clearSelected(i)
              if not gameUtils.checkOpen(i) then
                gameUtils.sortPriority()
                cWin[#cWin + 1] = uni.ent[i]:info(#cWin + 1)
              end
              return true
            elseif button == "r" then
              if uni.ent[i].type == "station" or uni.ent[i].type == "planet" then
                local list = uni.gatherSelectedTable()
                for j = 1, #list do
                  if uni.ent[list[j]].type == "ship" then
                    uni.ent[list[j]]:dockAtTarget(i)
                  end
                end
                return true
              end
            end
          end
        end
      end
      uni.selx1, uni.sely1 = uni.getMapCoordinates(x, y)
      if button == "r" then
        local list = uni.gatherSelectedTable()
        local xPos = love.mouse.getX()
        local yPos = love.mouse.getY()
        local tgtx, tgty = uni.getMapCoordinates(love.mouse.getPosition())
        if list[1] ~= nil then
          for i = 1, #list do
            local tx = tgtx - math.random(-#list, #list)
            local ty = tgty - math.random(-#list, #list)
            uni.ent[list[i]]:setTarget(tx, ty)
          end
        end
        uni.selx1 = "none"
        return true
      end
    end
  end
  if button == "wu" then
    if uni.scale < 2 then
      uni.scale = uni.scale + 0.001
    end
    uni.selx1 = "none"
    uni.selx2 = "none"
    uni.sely1 = "none"
    uni.sely2 = "none"
  elseif button == "wd" then
    if uni.scale > 0.02 then
      uni.scale = uni.scale - 0.01
    elseif uni.scale > 0.002 then
      uni.scale = uni.scale - 0.001
    elseif uni.scale > 0.0007 then
      uni.scale = uni.scale - 0.0001
    end
  if uni.scale < 0.0007 then uni.scale = 0.0007 end
    uni.selx1 = "none"
    uni.selx2 = "none"
    uni.sely1 = "none"
    uni.sely2 = "none"
  end
end

function love.mousereleased()
	for i = 1, #cWin do
		cWin[i]:mouseReleased()
	end
    if uni.ent ~= nil then
        if uni.selx1 ~= "none" and uni.selx2 ~= "none" then
            uni.clearSelected()
            local bx = math.max(uni.selx1, uni.selx2)
            local lx = math.min(uni.selx1, uni.selx2)
            local by = math.max(uni.sely1, uni.sely2)
            local ly = math.min(uni.sely1, uni.sely2)
            uni.selectionBox(lx, ly, bx, by)
        end
    end
	uni.selx1 = "none"
	uni.selx2 = "none"
	uni.sely1 = "none"
	uni.sely2 = "none"
end

function love.keypressed(key)
	--text input stuff goes here...

	--Hotkeys
	if key == "escape" then
		gameUtils.sortPriority()
		cWin[1].isVisible = not cWin[1].isVisible
	elseif key == "p" or key == "P" then
		gameUtils.sortPriority()
		cWin[3].isVisible = not cWin[3].isVisible
  elseif key == "m" or key == "M" then
		gameUtils.sortPriority()
		cWin[5].isVisible = not cWin[5].isVisible
  elseif key == "e" or key == "E" then
		gameUtils.sortPriority()
		cWin[4].isVisible = not cWin[4].isVisible
	elseif key == "i" or key == "I" then
		local list = uni.gatherSelectedTable()
    for j = 1, #list do
      local new = #cWin + 1
      cWin[new] = uni.ent[list[j]]:info(cWin[new])
      cWin[new].id = new
    end
  elseif key == "." then
    uni.gameSpeed = math.min(uni.gameSpeed + .5, uni.maxGameSpeed)
  elseif key == "," then
    uni.gameSpeed = math.max(uni.gameSpeed - .5, 0.5)
  elseif key == "pageup" then
    if uni.fTog >= #uni.factions then
      uni.fTog = 1
    else
      uni.fTog = uni.fTog + 1
    end
    uni.selected = uni.factions[uni.fTog].homePlanetId
  elseif key == "pagedown" then
    if uni.fTog <= 1 then
      uni.fTog = #uni.factions
    else
      uni.fTog = uni.fTog - 1
    end
    uni.selected = uni.factions[uni.fTog].homePlanetId
  --Ctrl key Hotkeys
  elseif love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
    if key == "d" then
      dbgBool = not dbgBool
      cWin[2].isVisible = dbgBool
      cWin[2]:render()
    end
	end
end

function checkMouseScroll(dt)
	if uni.x ~= nil then
		local mx, my = love.mouse.getPosition()
		local sw, sh = love.window.getDesktopDimensions()
		if mx <= scrollBorder then
			uni.selected = 0
			uni.x = uni.x - (uni.scrollSpeed * (1 / uni.scale))
		elseif mx >= sw - scrollBorder then
			uni.selected = 0
			uni.x = uni.x + (uni.scrollSpeed * (1 / uni.scale))
		end
		if my <= scrollBorder then
			uni.selected = 0
			uni.y = uni.y - (uni.scrollSpeed * (1 / uni.scale))
		elseif my >= sh - scrollBorder then
			uni.selected = 0
			uni.y = uni.y + (uni.scrollSpeed * (1 / uni.scale))
		end
	end
end

function love.update(dt)
  uni.countEntities()
	if dbgBool then
		cWin[2]:render()
	end
	if not uni.isPaused then
		if uni ~= nil then
			if uni.ent ~= nil then
				uni.stationTimer = uni.stationTimer + (dt * uni.gameSpeed)
				uni.economyTimer = uni.economyTimer + (dt * uni.gameSpeed)
				uni.factionTimer = uni.factionTimer + (dt * uni.gameSpeed)
				if uni.stationTimer > uni.stationTick then
					uni.stationTimer = 0
					uni.updateStations()
				end
				if uni.economyTimer > uni.economyTick then
					uni.economyTimer = 0
					uni.updateEconomy()
				end
				if uni.factionTimer > uni.factionTick then
					uni.factionTimer = 0
					uni.updateFactions()
				end
	            uni.scenarios[uni.gameMode]:update()
				if uni.selected ~= 0 then
					uni.setCamera(uni.ent[uni.selected].x, uni.ent[uni.selected].y)
				end
				for i = 1, #uni.ent do
          uni.ent[i]:update(dt)
					uni.ent[i]:move(dt)
				end
				if uni.selx1 ~= "none" then
					uni.selx2, uni.sely2 = uni.getMapCoordinates(love.mouse.getPosition())
				end
			end
		end
	end
	for i = 1, #cWin do
		cWin[i]:update(dt)
	end
	checkMouseScroll(dt)
end


--RENDERING--

function drawStars()
	love.graphics.push()
	love.graphics.scale(.001, .001)
	if uni ~= nil then
		if uni.ent ~= nil then
			for i = 1, #uni.starList do
				local pxOf, pyOf = uni.getScreenCoordinates(uni.ent[uni.starList[i]].x, uni.ent[uni.starList[i]].y)
				local angle = math.rad(uni.ent[uni.starList[i]].vizHeading)
				local w = uni.ent[uni.starList[i]].tw * 2
				love.graphics.setColor(0x99, 0x99, 0x99, 0x99)
				love.graphics.circle("fill", pxOf, pyOf, w)
			end
		end
	end
	love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
	love.graphics.pop()
end

function drawMap()
	if uni ~= nil then
		if uni.ent ~= nil then
			for i = 1, #uni.ent do
				local wid, hig = love.window.getDesktopDimensions()
				local hWid = wid / 2 * (1 / uni.scale)
				local hHig = hig / 2 * (1 / uni.scale)
				local xMin = math.floor(uni.x - hWid)
				local xMax = math.floor(uni.x + hWid)
				local yMin = math.floor(uni.y - hHig)
				local yMax = math.floor(uni.y + hHig)
				local offx = uni.ent[i].tw / 2
				local offy = uni.ent[i].th / 2
				local pxOf, pyOf = uni.getScreenCoordinates(uni.ent[i].x, uni.ent[i].y)
				local angle = math.rad(uni.ent[i].vizHeading)
				if uni.ent[i].x >= xMin and uni.ent[i].x <= xMax then
					if uni.ent[i].y >= yMin and uni.ent[i].y <= yMax then
            uni.ent[i].scrw = math.floor(uni.ent[i].tw * (1 / uni.scale))
            uni.ent[i].scrh = math.floor(uni.ent[i].th * (1 / uni.scale))
            if uni.ent[i].type == "ship" then
              if uni.ent[i].docked == 0 then
                if uni.scale > uni.iconCutoff then
                  love.graphics.draw(uni.shipSet, uni.ent[i].image, pxOf, pyOf, angle, 1, 1, offx, offy)
                end
              end
            elseif uni.ent[i].type == "station" then
              if uni.scale > uni.iconCutoff then
                love.graphics.draw(uni.statSet, uni.ent[i].image, pxOf, pyOf, angle, 1, 1, offx, offy)
              end
            elseif uni.ent[i].type == "planet" then
              offx = (uni.ent[i].tw / uni.ent[i].scale) / 2
              offy = (uni.ent[i].th / uni.ent[i].scale) / 2
              love.graphics.setColor(uni.ent[i].wr, uni.ent[i].wg, uni.ent[i].wb, 0xFF)
              love.graphics.draw(uni.planSet, uni.ent[i].waterImage, pxOf, pyOf, angle, uni.ent[i].scale, uni.ent[i].scale, offx, offy)
              love.graphics.setColor(uni.ent[i].lr, uni.ent[i].lg, uni.ent[i].lb, 0xFF)
              love.graphics.draw(uni.planSet, uni.ent[i].landImage, pxOf, pyOf, uni.ent[i].landAng, uni.ent[i].scale, uni.ent[i].scale, offx, offy)
              love.graphics.setColor(uni.ent[i].ar, uni.ent[i].ag, uni.ent[i].ab, 0xFF)
              love.graphics.draw(uni.planSet, uni.ent[i].cloudImage, pxOf, pyOf, uni.ent[i].cloudAng, uni.ent[i].scale, uni.ent[i].scale, offx, offy)
              love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
              love.graphics.draw(uni.planSet, uni.ent[i].shadeImage, pxOf, pyOf, uni.ent[i].shadeAng, uni.ent[i].scale, uni.ent[i].scale, offx, offy)
              love.graphics.setColor(0x99, 0x99, 0x99, 0x33)
              local hStar = uni.ent[i].homeStarId
              pxOf, pyOf = uni.getScreenCoordinates(uni.ent[hStar].x, uni.ent[hStar].y)
              love.graphics.circle("line", pxOf, pyOf, uni.ent[i].rad, 360)
              love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
            elseif uni.ent[i].type == "moon" then
              offx = (uni.ent[i].tw / uni.ent[i].scale) / 2
              offy = (uni.ent[i].th / uni.ent[i].scale) / 2
              love.graphics.setColor(uni.ent[i].wr, uni.ent[i].wg, uni.ent[i].wb, 0xFF)
              love.graphics.draw(uni.planSet, uni.ent[i].waterImage, pxOf, pyOf, angle, uni.ent[i].scale, uni.ent[i].scale, offx, offy)
              love.graphics.setColor(uni.ent[i].lr, uni.ent[i].lg, uni.ent[i].lb, 0xFF)
              love.graphics.draw(uni.planSet, uni.ent[i].landImage, pxOf, pyOf, uni.ent[i].landAng, uni.ent[i].scale, uni.ent[i].scale, offx, offy)
              love.graphics.setColor(uni.ent[i].ar, uni.ent[i].ag, uni.ent[i].ab, 0xFF)
              love.graphics.draw(uni.planSet, uni.ent[i].cloudImage, pxOf, pyOf, uni.ent[i].cloudAng, uni.ent[i].scale, uni.ent[i].scale, offx, offy)
              love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
              love.graphics.draw(uni.planSet, uni.ent[i].shadeImage, pxOf, pyOf, uni.ent[i].shadeAng, uni.ent[i].scale, uni.ent[i].scale, offx, offy)
              love.graphics.setColor(0x99, 0x99, 0x99, 0x33)
              local hStar = uni.ent[i].home
              pxOf, pyOf = uni.getScreenCoordinates(uni.ent[hStar].x, uni.ent[hStar].y)
              love.graphics.circle("line", pxOf, pyOf, uni.ent[i].rad, 36)
              love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
            elseif uni.ent[i].type == "star" then
              local r = math.max(offx * 2, 22)
              love.graphics.circle("fill", pxOf, pyOf, r, 36)
            end
            if uni.ent[i].sp == uni.ent[i].spMax then
              love.graphics.setColor(0x00, 0x66, 0x66, 0xFF)
            elseif uni.ent[i].sp > uni.ent[i].spMax * .75 then
              love.graphics.setColor(0x00, 0xFF, 0x00, 0xFF)
            elseif uni.ent[i].sp > uni.ent[i].spMax * .50 then
              love.graphics.setColor(0xFF, 0x99, 0x00, 0xFF)
            elseif uni.ent[i].sp > uni.ent[i].spMax * .25 then
              love.graphics.setColor(0xFF, 0xFF, 0x00, 0xFF)
            elseif uni.ent[i].sp > 0 then
              love.graphics.setColor(0xFF, 0x00, 0x00, 0xFF)
            end
            if uni.ent[i].sp > 0 and uni.ent[i].selected then
              if uni.ent[i].type == "ship" then
                if uni.ent[i].docked == 0 then
                  love.graphics.circle("line", pxOf, pyOf, uni.ent[i].tw)
                end
              elseif uni.ent[i].type == "station" then
                love.graphics.circle("line", pxOf - 1, pyOf - 1, (uni.ent[i].tw / 2) + 5)
              elseif uni.ent[i].type == "planet" then
                love.graphics.circle("line", pxOf - 1, pyOf - 1, (uni.ent[i].tw / 2) + 5)
              elseif uni.ent[i].type == "star" then
                love.graphics.circle("line", pxOf - 1, pyOf - 1, (uni.ent[i].tw / 2) + 5)
              end
            end
            if uni.ent[i].selected then
              love.graphics.setColor(0x00, 0xFF, 0x00, 0xFF)
                if uni.ent[i].type == "ship" then
                  if uni.ent[i].docked == 0 then
                    love.graphics.circle("line", pxOf, pyOf, uni.ent[i].tw + 5, 6)
                  end
                  if uni.ent[i].tgtx ~= "none" then
                    local x2, y2 = uni.getScreenCoordinates(uni.ent[i].tgtx, uni.ent[i].tgty)
                    love.graphics.line(pxOf, pyOf, x2, y2)
                  end
                elseif uni.ent[i].type == "station" then
                  love.graphics.circle("line", pxOf - 1, pyOf, (uni.ent[i].tw / 2) + 15, 6)
                elseif uni.ent[i].type == "planet" then
                  love.graphics.circle("line", pxOf - 1, pyOf, (uni.ent[i].tw / 2) + 15, 6)
                elseif uni.ent[i].type == "star" then

                end
            end
            love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
          else
            uni.ent[i].scrx = "none"
            uni.ent[i].scry = "none"
					end
        else
          uni.ent[i].scrx = "none"
          uni.ent[i].scry = "none"
				end
			end
			if uni.selx1 ~= "none" and uni.selx2 ~= "none" then
				local bx = math.max(uni.selx1, uni.selx2)
				local lx = math.min(uni.selx1, uni.selx2)
				local by = math.max(uni.sely1, uni.sely2)
				local ly = math.min(uni.sely1, uni.sely2)
				local stx, sty = uni.getScreenCoordinates(lx, ly)
				local wid = bx - lx
				local hig = by - ly
				love.graphics.setColor(0x00, 0xFF, 0x00, 0xFF)
				love.graphics.rectangle("line", stx, sty, wid, hig)
				love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
			end
		end
	end
end

function love.draw()
	drawStars()
	love.graphics.push()
	love.graphics.scale(uni.scale, uni.scale)
	drawMap()
	love.graphics.pop()
	for p = 1, maxPanes do
		for i = 1, #cWin do
			if cWin[i].priority == p then
				if cWin[i].isVisible then
					love.graphics.draw(cWin[i].canvas, cWin[i].x, cWin[i].y)
				end
			end
		end
	end
end