local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local it = require "/Classes/item"

local item = it:addItem(item)

item.name = "Citrus Essence"
item.cost = 120
item.type = "Refined"
item.batch = 30
item.bulk = 5
item.rarity = 2
item.recipe = {
	[1] = {name = "Space Lemons", amt = 25},
	[2] = {name = "Batteries", amt = 10},
}

item.flavourText = "If you see this I was too lazy to write something."

return item