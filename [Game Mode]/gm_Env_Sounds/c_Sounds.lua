soundTable = {}

function playSound(sound,x,y,z,loop,volume,distance)
	local sound = playSound3D(sound, x,y,z,loop) 
	setSoundMaxDistance (sound,distance or 1000)
	setSoundVolume (sound,(volume or 1)*0.7)
	setSoundPanningEnabled(sound,false)
	if not loop then
		soundTable[sound] = {getTickCount(),getSoundLength(sound)}
	end
end
playSound('Sounds/Loop/sound1.wav',0,0,250,true,0.3)

function soundGarbageCollect ( )
	if getElementData(localPlayer,'Teleport') then
		setElementData(localPlayer,'Teleport',nil)
		playSound('Sounds/teleport.wav',0,0,250,false,5)
	end
	
	for i,v in pairs(soundTable) do
		local length = v[2]*1000
		local playLength = (getTickCount()-(v[1]))
		if (playLength > length) then
			clearSound(i)
			soundTable[i] = nil
		end
	end
end

function playEnvSound(x,y,z,sound)
	playSound(sound or 'Sounds/teleport.wav',x,y,z,false,5,40)
end
addEvent( "teleportSound", true )
addEventHandler( "teleportSound", localPlayer, playEnvSound )
	
	
setTimer ( soundGarbageCollect, 500, 0)

sounds = {'Sounds/bird/sound1.wav','Sounds/thunder/sound1.wav','Sounds/wind/sound1.wav','Sounds/bird/sound2.wav','Sounds/thunder/sound2.wav','Sounds/wind/sound2.wav'}

function playRandomSound ( )
	local play = math.random(1,5)
	if play > 3 then
		playSound(sounds[math.random(1,#sounds)],0,0,250,false,0.4)
	end

	setTimer ( playRandomSound, math.random(1,2000)+1000, 1 )
end

setTimer ( playRandomSound, 1000, 1 )



function clearSound(sound)
	if isElement(sound) then
		stopSound(sound)
		if isElement(sound) then
			destroyElement(sound)
		end
	end
end
