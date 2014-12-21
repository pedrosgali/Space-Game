local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local it = require "/Classes/item"

local item = it:addItem(item)

item.name = "Iron Ore"
item.cost = 100
item.type = "Ore"
item.batch = 15
item.bulk = 5
item.rarity = 3
item.recipe = {
	[1] = {name = "Machine Parts", amt = 5},
	[2] = {name = "Batteries", amt = 10},
}

item.flavourText = "Iron Ore is found throughout the Galaxy.  It is used for many industrial purposes."

return item