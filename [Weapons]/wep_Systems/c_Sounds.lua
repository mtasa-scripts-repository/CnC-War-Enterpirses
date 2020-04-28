
weaponSounds = {}

weaponSounds['AR'] = {}
weaponSounds['AR']['Close'] = {'Sounds/BR/Close.wav',1.5,1.3}
weaponSounds['AR']['Far'] = 'Sounds/AR/Far.wav'
weaponSounds['AR']['Generic'] = {'Eject'}
weaponSounds['AR']['Echo Delay'] = 200

weaponSounds['BR'] = {}
weaponSounds['BR']['Close'] = {'Sounds/BR/Close.wav'}
weaponSounds['BR']['Far'] = 'Sounds/BR/Far.wav'
weaponSounds['BR']['Generic'] = {'Eject'}
weaponSounds['BR']['Echo Delay'] = 130

weaponSounds['Shotgun'] = {}
weaponSounds['Shotgun']['Close'] = {'Sounds/Shotgun/Close.wav',0.5,0.3}
weaponSounds['Shotgun']['Far'] = 'Sounds/Shotgun/Far.wav'
weaponSounds['Shotgun']['Generic'] = {'Eject'}
weaponSounds['Shotgun']['Echo Delay'] = 200

weaponSounds['Pistol'] = {}
weaponSounds['Pistol']['Close'] = {'Sounds/Pistol/Close.wav',1.4,1.2}
weaponSounds['Pistol']['Far'] = 'Sounds/Pistol/Far.wav'
weaponSounds['Pistol']['Generic'] = {'Eject'}
weaponSounds['Pistol']['Echo Delay'] = 200

weaponSounds['Sniper'] = {}
weaponSounds['Sniper']['Close'] = {'Sounds/Sniper/Close.wav'}
weaponSounds['Sniper']['Far'] = 'Sounds/Sniper/Far.wav'
weaponSounds['Sniper']['Generic'] = {'Eject'}
weaponSounds['Sniper']['Echo Delay'] = 50

weaponSounds['Rocket Launcher'] = {}
weaponSounds['Rocket Launcher']['Close'] = {'Sounds/Rocket Launcher/Close.wav',1,1,1.5}
weaponSounds['Rocket Launcher']['Far'] = 'Sounds/Rocket Launcher/Far.wav'
weaponSounds['Rocket Launcher']['Projectile'] = 'Sounds/Rocket Launcher/Projectile.wav'
weaponSounds['Rocket Launcher']['Impact Close'] = 'Sounds/Rocket Launcher/Impact Close.wav'
weaponSounds['Rocket Launcher']['Impact Far'] = 'Sounds/Rocket Launcher/Impact Far.wav'
weaponSounds['Rocket Launcher']['Echo Delay'] = 200
weaponSounds['Rocket Launcher']['Generic'] = {}

weaponSounds['Generic'] = {}
weaponSounds['Generic']['Eject'] = {'Sounds/Generic/Eject 1.wav','Sounds/Generic/Eject 2.wav'}

soundTable = {}
echoTable = {}
wistleTable = {}

function playShotSound(weapon,x,y,z)
	if weapon then
		local xa,ya,za = getElementPosition(localPlayer)
		
		local closeS = weaponSounds[weapon]['Close']
		
		if (getDistanceBetweenPoints3D ( x,y,z,xa,ya,za ) < 150) then
			local sound,tempo,pitch,volume = unpack(closeS)
			
			local close = playSound3D(sound, x,y,z, false) 
			soundTable[close] = {getTickCount(),getSoundLength(close)}
			local Osample,Otempo,Opitch = getSoundProperties( close )
			setSoundProperties(close,0,Otempo*(tempo or 1),Opitch*(pitch or 1))
			if volume then
				setSoundVolume (close,volume or 1)
			end
			setSoundMaxDistance (close,100)
			
			if weaponSounds[weapon]['Generic'] then
				for i,v in pairs(weaponSounds[weapon]['Generic']) do
					local genericSound = playSound3D(weaponSounds['Generic'][v][math.random(1,#weaponSounds['Generic'][v])], x,y,z, false) 
					soundTable[genericSound] = {getTickCount(),getSoundLength(genericSound)}
					setSoundMaxDistance (genericSound,100)
				end
			end
		end

		setTimer ( playEchoSound, weaponSounds[weapon]['Echo Delay'] or 150, 1,weapon,x,y,z)
	end
end

function createFlyBy(x,y,z,sType)
	if (sType == 'Rocket Launcher') then
		local sound = playSound3D('Sounds/Rocket Launcher/Projectile.wav', x,y,z, true) 
		setSoundMaxDistance (sound,100)
		setSoundVolume (sound,5)
		setSoundEffectEnabled (sound,'reverb',true)
		soundTable[sound] = {getTickCount(),5000}
		return sound
	else
		local sound = playSound3D('Sounds/Generic/Flyby_Far/Flyby '..math.random(1,2)..'.wav', x,y,z, true) 
		setSoundMaxDistance (sound,10)
		setSoundVolume (sound,1)
		soundTable[sound] = {getTickCount(),5000}
		return sound
	end
end

function playEchoSound(weapon,x,y,z)
	local far = playSound3D(weaponSounds[weapon]['Far'], x,y,z, false) 
	soundTable[far] = {getTickCount(),getSoundLength(far)}
	setSoundEffectEnabled (far,'reverb',true)
	setSoundMaxDistance (far,700)
	setSoundVolume (far,0.8)
end

ImpactSounds = {}
ImpactSounds['default'] = 'Sounds/Generic/Impact/Dirt/Impact.wav'
ImpactSounds[10] = 'Sounds/Generic/Impact/Dirt/Impact.wav'
ImpactSounds[0] = 'Sounds/Generic/Impact/Metal/Impact.wav'
ImpactSounds['blood'] = 'Sounds/Generic/Impact/Flesh/Impact.wav'

function playImpactSound(x,y,z,material,player)
	local impact = playSound3D(player and ImpactSounds['blood'] or (ImpactSounds[material] or ImpactSounds['default']), x,y,z, false) 
	soundTable[impact] = {getTickCount(),getSoundLength(impact)}
	setSoundMaxDistance (impact,110)
	setSoundVolume (impact,0.4)
end

function playExplosion(x,y,z)
	local impact = playSound3D('Sounds/Rocket Launcher/Impact Close.wav', x,y,z, false) 
	soundTable[impact] = {getTickCount(),getSoundLength(impact)}
	setSoundMaxDistance (impact,200)
	setSoundVolume (impact,3)
	
	local impact = playSound3D('Sounds/Rocket Launcher/Impact Far.wav', x,y,z, false) 
	soundTable[impact] = {getTickCount(),getSoundLength(impact)}
	setSoundMaxDistance (impact,500)
	setSoundVolume (impact,8)
end


function playDryFire(x,y,z)
	local sound = playSound3D('Sounds/Generic/Dry Fire.wav', x,y,z) 
	setSoundMaxDistance (sound,10)
	setSoundVolume (sound,2)
	soundTable[sound] = {getTickCount(),getSoundLength(sound)}
end

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


