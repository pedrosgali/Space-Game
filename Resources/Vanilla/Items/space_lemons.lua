local win = require "/Lib/screen"
local maths = require "/Lib/maths"
local it = require "/Classes/item"

local item = it:addItem(item)

item.name = "Space Lemons"
item.cost = 100
item.type = "Organic"
item.batch = 20
item.bulk = 5
item.rarity = 3
item.recipe = {
	[1] = {name = "Batteries", amt = 5},
}

item.flavourText = "If you can think of a better way to turn sunlight into electricity I'd like to hear it! - Dave Johnson, Boom Lemons(R) CEO."

return item