


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

local screenWidth, screenHeight = guiGetScreenSize ( ) 



function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz+90
end


soundTable = {}

function playSound(sound,x,y,z,loop,volume,distance)
	local sound = playSound3D(sound, x,y,z,loop) 
	setSoundMaxDistance (sound,distance or 1000)
	setSoundVolume (sound,(volume or 1)*0.7)
	if not loop then
		soundTable[sound] = {getTickCount(),getSoundLength(sound)}
	end
	return sound
end
pelicanSound = playSound('Sounds/Pelican_Wind.wav',0,0,-300,true,15,450)
setSoundEffectEnabled(pelicanSound,'flanger',true)

previous = 0 

function debugA()
	local pelican = getPelican()
	

	
	local x,y,z = unpack(getElementData(pelican,'Target') or {0,0,0})
	local xa,ya,za = getElementPosition(pelican)
	local xr,yr,zr = findRotation3D(xa,ya,za,x,y,z) 
	
	local px,py,pz = getElementPosition(localPlayer)
	
	local distance = getDistanceBetweenPoints3D (xa,ya,za,px,py,pz )

	
	if (distance < 500) then
		local speed = (distance-previous)

		previous = distance
		
		

		setElementRotation(pelican,xr,yr,zr)
		if getLowLODElement ( pelican) then
			attachElements(getLowLODElement ( pelican ),pelican)
			setElementRotation(getLowLODElement ( pelican ),xr,yr,zr)
		end
		
		if pelicanSound then
			setElementPosition(pelicanSound,xa,ya,za)
			
			local pitch = (340.29/340.29+(speed))*6

			setSoundProperties(pelicanSound,0,3,pitch)
		end
	end
end

addEventHandler("onClientRender", root, debugA)


function soundGarbageCollect ( )

	for i,v in pairs(soundTable) do
		local length = v[2]*1000
		local playLength = (getTickCount()-(v[1]))
		if (playLength > length) then
			clearSound(i)
			soundTable[i] = nil
		end
	end
end
	
	
setTimer ( soundGarbageCollect, 500, 0)

function clearSound(sound)
	if isElement(sound) then
		stopSound(sound)
		if isElement(sound) then
			destroyElement(sound)
		end
	end
end
