local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local it = require "/Classes/item"

local item = it:addItem(item)

item.name = "Batteries"
item.cost = 100
item.type = "Product"
item.batch = 50
item.rarity = 6
item.bulk = 1
item.recipe = {
	[1] = {name = "Iron Casings", amt = 20},
    [2] = {name = "Citrus Essence", amt = 15},
}

item.flavourText = "Used for many industrial purposes."

return item