
soundTable = {}

function playSound(sound,x,y,z,loop,volume,distance)
	local sound = playSound3D(sound, x,y,z,loop) 
	setSoundMaxDistance (sound,distance or 1000)
	setSoundVolume (sound,(volume or 1))
	if not loop then
		soundTable[sound] = {getTickCount(),getSoundLength(sound)}
	end
	return sound
end

previous = {} 
idle = {}
engine = {}

function calculateDoopler(veh,speeda,volume)
	local px,py,pz = getElementPosition(localPlayer)
	local x,y,z = getElementPosition(veh)
	local distance = getDistanceBetweenPoints3D (x,y,z,px,py,pz)
	if (distance < 400) then
		if not isElement(idle[veh]) then
			idle[veh] = playSound('Sounds/idle.wav',x,y,z,true,1,300)
			engine[veh] = playSound('Sounds/hi.wav',x,y,z,true,0.5,300)
		else
			setSoundSpeed (engine[veh],math.min(speeda,0.7))

			
			local speed = distance-(previous[veh] or 0)
			previous[veh] = distance

			local pitch = math.max((340.29/340.29+(speed))*6,-(340.29/340.29+(speed))*6,1)
			setSoundProperties(idle[veh],0,3,pitch)

			setSoundProperties(engine[veh],0,3,pitch)
			
			setElementPosition(idle[veh],x,y,z)
			setElementPosition(engine[veh],x,y,z)
			setSoundVolume(engine[veh],volume)
		end
	else
		if isElement(idle[veh]) then
			destroyElement(idle[veh])
			idle[veh] = nil
		end
		if isElement(engine[veh]) then
			destroyElement(engine[veh])
			engine[veh] = nil
		end
	end
end

function getDifference(firstAngle,secondAngle)

local difference = secondAngle - firstAngle;
	if (difference < -180) then
		return difference + 360
	end
		
	if (difference > 180) then
		return difference - 360
	end
	return difference
end

function getDifference2 (firstAngle,secoundAngle)
	return 180 - math.abs(180- math.abs(firstAngle - secoundAngle))
end

 
previousRot = {}
function getRPM(v,c,r)
	previousRot[v][c] = previousRot[v][c] or r


	local size = (0.7*(math.pi))
	
	
	local diff = getDifference(previousRot[v][c],r)*size
	previousRot[v][c] = r
	return math.max(diff,-diff)
end

local screenWidth, screenHeight = guiGetScreenSize ( ) -- Get the screen resolution (width and height)

RPM = 0
counter = 0
old =  getTickCount ()

countera = 60

avgRpm = {}

multiplier = 500
limter = 1.05

function controlSounds()
	for i,v in pairs(getElementsByType('vehicle')) do
		previousRot[v] = previousRot[v] or {}

		local rx1 = getVehicleComponentRotation(v, 'wheel_rf_dummy','parent')
		local rx2 = getVehicleComponentRotation(v, 'wheel_lf_dummy','parent')
		local rx3 = getVehicleComponentRotation(v, 'wheel_rb_dummy','parent')
		local rx4 = getVehicleComponentRotation(v, 'wheel_lb_dummy','parent')
		
		local rpm = ((math.max(getRPM(v,'rf',rx1),getRPM(v,'lf',rx2))+math.max(getRPM(v,'rb',rx3)+getRPM(v,'lb',rx4)))/getVehicleCurrentGear(v))/multiplier
		
		countera = countera + 1
		if countera > 10 then
			RPM = math.floor(rpm)
			countera = 0
		end
		dxDrawText ( RPM, 44, screenHeight - 43, screenWidth, screenHeight, tocolor ( 255, 255, 255, 255 ), 1, "pricedown" )
		
		calculateDoopler(v,rpm,rpm*2)
	end
end

addEventHandler("onClientRender", root, controlSounds)


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
