local maths = {}

function maths.round(num, dp) --Rounds num to dp decimal places
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function maths.pyth(x, y) --Returns the hypotinuse of a right triangle x, y
    local xCub = x * x
    local yCub = y * y
  	return math.sqrt((xCub) + (yCub))
end

function maths.rectifyRads(heading) --Takes a radian and returns a value between 0 and 359
    heading = math.floor(math.deg(heading))
	  while heading < 0 do
  		heading = heading + 360
  	end
  	if heading >= 360 then heading = heading % 360 end
  	heading = heading + 90 --This line rotates the ship image 90 deg to account for LOVE assuming right is up.
  	return heading
end

function maths.percent(part, whole) --Returns the percentage value of part in whole. 0 - 100
    if part == 0 or whole == 0 then return 0 end
    return((part / whole) * 100)
end

return maths