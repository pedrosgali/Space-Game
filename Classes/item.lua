local win = require "/Lib/screen"
local maths = require "/Lib/maths"

local item = {}

--ITEM API FUNCTIONS--

function item.itemLookup(name)
    for i = 1, #uni.items do
        if uni.items[i].name == name then return i end
    end
end

function item.randomItem(type)
    while true do
        local rnd = math.random(1, #uni.items)
        if type == uni.items[rnd].type then
            return rnd
        end
    end
end

--ITEM CLASS FUNCTIONS--

function item:addItem(newItem)
    local newItem = newItem or {}
    setmetatable(newItem, self)
    self.__index = self
    return newItem
end

function item:recipeSearch(itId)
    for i = 1, #self.recipe do
        if self.recipe[i].name == uni.items[itId].name then return i end
    end
end

function item:update(id)

end

function item:info()

end

return item