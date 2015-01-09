local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local it = require "/Classes/item"

local item = it:addItem(item)

item.name = "Iron Casings"
item.cost = 100
item.type = "Product"
item.batch = 30
item.bulk = 5
item.rarity = 2
item.recipe = {
	[1] = {name = "Iron Ingots", amt = 10},
    [2] = {name = "Batteries", amt = 25},
    [3] = {name = "Machine Parts", amt = 5},
}

item.flavourText = "Used for many industrial purposes."

return item