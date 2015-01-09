local win = require "/Lib/screen"
local bt = require "/Lib/behaviour"
local leaves = require "/Classes/ai"

local maxExplorers = 5
local maxColonists = 1

--AI SETUP--
local ai = bt.inheritsFrom(bt.loop, "Main Trunk")

--AI SPAWNING--

function ai:newAi(id, name)
  local newFac = {}
	setmetatable(newFac, self)
	self.__index = self
	newFac.id = id
  newFac.name = name
  newFac:add(bt.sequence, "Explore", id)
    newFac.ch[1]:add(leaves.checkSystems, "Check Systems", id)
    newFac.ch[1]:add(bt.sequence, "Ship Sequence", id)
      newFac.ch[1].ch[2]:add(leaves.getShipLists, "Gather Ships", id)
      newFac.ch[1].ch[2]:add(bt.selector, "Do I have Ships?", id)
        newFac.ch[1].ch[2].ch[2]:add(leaves.checkShipCount, "Explorer check", id, maxExplorers, "explorer")
        newFac.ch[1].ch[2].ch[2]:add(leaves.buildShip, "Build Explorer", id, "Shuttle", "explorer")
  newFac:init()
	return newFac
end

return ai