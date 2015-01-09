local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local it = require "/Classes/item"

local item = it:addItem(item)

item.name = "Iron Ingots"
item.cost = 500
item.type = "Refined"
item.batch = 30
item.bulk = 5
item.rarity = 2
item.recipe = {
	[1] = {name = "Iron Ore", amt = 15},
	[2] = {name = "Batteries", amt = 20},
}

item.flavourText = "Processed Iron has many uses throughout the Galaxy."

return item