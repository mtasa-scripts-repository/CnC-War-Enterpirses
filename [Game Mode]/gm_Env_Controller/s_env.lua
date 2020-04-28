

Pelican = nil

function getPelican ()
	if isElement(Pelican) then
		return Pelican
	else
		for i,v in pairs(getElementsByType('object')) do 
			if getElementID(v) == 'Pelican' then
				Pelican = v
				return v
			end
		end
	end
end


function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end



function move ()
	local negative = math.random(1,2)
	local number = (negative == 1) and -1 or 1
	startx,starty,startz = (math.random(0,500)+1000),(math.random(0,500)+1000),math.random(250,500)
	targetx,targety,targetz =(-math.random(0,500)-1000),(-math.random(0,500)-1000),math.random(250,500)
	return startx*number,starty*number,startz,targetx*number,targety*number,targetz
end


function trigger()
	local pelican = getPelican ()

	local x,y,z,xa,ya,za = move()
	
	setElementPosition(pelican,x,y,z)
	
	local xr,yr,zr = findRotation3D( x,y,z,xa,ya,za ) 
	
	setElementRotation(pelican,xr,yr,zr+90)

	setTimer ( trigger2, 1000, 1,x,y,z,xa,ya,za )
	setElementData(pelican,'Target',{xa,ya,za})
end

function trigger2(x,y,z,xa,ya,za)
	local pelican = getPelican ()

	moveObject ( pelican, 20000, xa,ya,za )
	
	
	setTimer ( trigger, math.random(80000,150000), 1 )
end

setTimer ( trigger, 1000, 1 )