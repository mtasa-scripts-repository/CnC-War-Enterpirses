
sun = {}
sun.x,sun.y,sun.z = 0,0,0
sun.r,sun.g,sun.b = 0.8,0.8,0.8
sun.Limit = 0

function setSunPosition (xa,ya,za)
	sun.x,sun.y,sun.z = xa,ya,za
end

function getSunColor ()
	return sun.r,sun.g,sun.b
end


function getSunPosition ()
	return sun.x,sun.y,sun.z
end

function getNightLimit ()
	return sun.Limit
end


function setSunColor (ra,ga,ba)
	sun.r,sun.g,sun.b = (ra/255),(ga/255),(ba/255)
end

function setNightLimit (limit)
	sun.Limit = limit
end
