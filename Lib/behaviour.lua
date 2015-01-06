local PASSED = "passed"
local FAILED = "failed"
local RUNNING = "running"

local bt = {}

bt.node = {}

--INHERITANCE--

function bt.inheritsFrom(parent, name)
  local newClass = {}
  local classLookup = {__index = newClass}
  function newClass:create(id)
    local newinst = {}
    setmetatable(newinst, classLookup)
    newinst.name = name
    newinst.id = id
    newinst.state = "running"
    newinst.branches = 0
    newinst.tick = 1
    newinst.ch = {}
    return newinst
  end
  if parent then
    setmetatable(newClass, {__index = parent})
  end
  return newClass
end

--NODES--

function bt.node:add(object, name, id)
  if self.branches == nil then
    self.ch = {}
    self.branches = 1
  else
    self.branches = self.branches + 1
  end
  self.ch[self.branches] = {}
  self.ch[self.branches] = object:create(id)
  self.ch[self.branches].name = name
end

function bt.node:init()
  self.tick = 1
  self.state = RUNNING
  for i = 1, #self.ch do
    self.ch[i].state = RUNNING
    self.ch[i]:init()
  end
end

function bt.node:run()
  
end

--MAIN LOOP--

bt.loop = bt.inheritsFrom(bt.node, "Loop")
function bt.loop:run()
  local ch = self.ch[self.tick]
  local state = ch.state
  gameUtils.debug(self.name.."["..self.tick.."]: "..ch.name, "c")
  if state == RUNNING then
    self.ch[self.tick].state = RUNNING
    self.ch[self.tick]:run()
  elseif state == PASSED or state == FAILED then
    if self.tick == #self.ch then
      self.tick = 0
    end
    self.tick = self.tick + 1
    self.ch[self.tick]:init()
  end
end

--SEQUENCE--

bt.sequence = bt.inheritsFrom(bt.node, "Sequence")
function bt.sequence:run()
  if self.state == RUNNING then
    local ch = self.ch[self.tick]
    gameUtils.debug(self.name.." ["..self.tick.."]: "..ch.name)
    local state = ch.state
    if state == RUNNING then
      self.ch[self.tick]:run()
    elseif state == FAILED then
      self.state = FAILED
    elseif state == PASSED then
      if self.tick == #self.ch then
        self.state = PASSED
      else
        self.tick = self.tick + 1
      end
    end
  end
end

--SELECTOR--

bt.selector = bt.inheritsFrom(bt.node, "Selector")
function bt.selector:run(ai)
  if self.state == RUNNING then
    local ch = self.ch[self.tick]
    gameUtils.debug(self.name.." ["..self.tick.."]: "..ch.name)
    local state = ch.state
    if state == RUNNING then
      self.ch[self.tick]:run(ai)
    elseif state == FAILED then
      if self.tick == #self.ch then
        self.state = FAILED
      else
        self.tick = self.tick + 1
      end
    elseif state == PASSED then
      self.state = PASSED
    end
  end
end

--CONDITION--

return bt