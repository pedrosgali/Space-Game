local names = {}

names.start = {
	[1] = "Ka",
	[2] = "Re",
	[3] = "Na",
	[4] = "Be",
	[5] = "Tu",
	[6] = "En",
	[7] = "Ul",
	[8] = "Il",
	[9] = "Or",
	[10] = "Du",
}
names.middle = {
	[1] = "le",
	[2] = "re",
	[3] = "na",
	[4] = "be",
	[5] = "tu",
	[6] = "en",
	[7] = "ul",
	[8] = "il",
	[9] = "or",
	[10] = "ou",
}
names.finish = {
	[1] = "el",
	[2] = "r",
	[3] = "es",
	[4] = "'t",
	[5] = "et",
	[6] = "an",
	[7] = "th",
	[8] = "il",
	[9] = "oo",
	[10] = "du",
}

function names.randomName()
	local st = math.random(1, #names.start)
	local retName = names.start[st]
	local midNum = math.random(1, 3)
	for i = 1, midNum do
		local mid = math.random(1, #names.middle)
		retName = retName..names.middle[mid]
	end
	local fin = math.random(1, #names.finish)
	retName = retName..names.finish[fin]
	return retName
end

return names