local win = require "/Lib/screen"
local bt = require "/Lib/behaviour"
local leaves = require "/Classes/ai"

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
      newFac.ch[1].ch[2]:add(leaves.passLeaf, "Assign fleet ships", id)
      newFac.ch[1].ch[2]:add(bt.sequence, "Move Ships Sequence", id)
        newFac.ch[1].ch[2].ch[3]:add(leaves.passLeaf, "Explorer Ships", id)
        newFac.ch[1].ch[2].ch[3]:add(leaves.passLeaf, "Colony Ships", id)
  newFac:add(bt.sequence, "Exchange", id)
    newFac.ch[2]:add(leaves.passLeaf, "Trade Stuff", id)
    newFac.ch[2]:add(leaves.passLeaf, "Build Stuff", id)
  newFac:init()
	return newFac
end

return ai