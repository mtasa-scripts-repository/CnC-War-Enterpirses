

Weapon = {}
WProp = {}
special = {}
Ammo = {}
shader = {}

function assignWeapon(player,wType)
	if wType then
		if Weapon[player] then
			if isElement(Weapon[player]['Model']) then
				if (not (Weapon[player]['Type'] == wType)) then
					for i,v in pairs(shader[Weapon[player]['Model']]) do
						if isElement(v) then
							destroyElement(v)
						end
					end
					shader[Weapon[player]['Model']] = nil
					destroyElement(Weapon[player]['Model'])
					Weapon[player]['Model'] = nil
					return assignWeapon(player,wType)
				end
				return Weapon[player]['Model']
			else
				Weapon[player] = {}
				Weapon[player]['Model'] = exports.cStream:CcreateObject(wType,0,0,0)
				setElementData(Weapon[player]['Model'],'Weapon',player)
				setElementData(Weapon[player]['Model'],'wType',wType)
				Weapon[player]['Type'] = wType
				setElementCollisionsEnabled(Weapon[player]['Model'],false)
				shader[Weapon[player]['Model']] = {}
				return Weapon[player]['Model']
			end
		else
			Weapon[player] = {}
			Weapon[player]['Model'] = exports.cStream:CcreateObject(wType,0,0,0)
			setElementData(Weapon[player]['Model'],'Weapon',player)
			setElementData(Weapon[player]['Model'],'wType',wType)
			Weapon[player]['Type'] = wType
			setElementCollisionsEnabled(Weapon[player]['Model'],false)
			shader[Weapon[player]['Model']] = {}
			return Weapon[player]['Model']
		end
	end
end


WProp['AR'] = {}
	local prop = WProp['AR']
	prop['Bloom'] = 310
	prop['Barrel'] = {}
	prop['Barrel'][1] = {-0.063,0.669,0.123}
	prop['Bones'] = {36,25,true,25,22,0}
	prop['Size'] = 'Medium'
	prop['Retical Mult'] = 1
	prop['Ammo'] = 60
	
WProp['BR'] = {}
	local prop = WProp['BR']
	prop['Bloom'] = 8
	prop['Barrel'] = {}
	prop['Barrel'][1] = {-0.049,0.756,0.118}
	prop['Bones'] = {36,25,true,25,22,0}
	prop['Size'] = 'Medium'
	prop['Retical Mult'] = 2
	prop['Ammo'] = 36
	prop['Zoom'] = 4.5
	
WProp['Shotgun'] = {}
	local prop = WProp['Shotgun']
	prop['Bloom'] = 40
	prop['Barrel'] = {}
	prop['Barrel'][1] = {-0.051,0.772,0.039}
	prop['Barrel'][2] = {-0.026,0.772,0.039}
	prop['Bones'] = {36,25,true,25,22,0}
	prop['Size'] = 'Medium'
	prop['Retical Mult'] = 1
	prop['Ammo'] = 180
	prop['Reload Amount'] = 4
	
WProp['Sniper'] = {}
	local prop = WProp['Sniper']
	prop['Bloom'] = 1
	prop['Barrel'] = {}
	prop['Barrel'][1] = {-0.064,1.529,0.137}
	prop['Bones'] = {36,25,true,25,22,0}
	prop['Size'] = 'Large'
	prop['Retical Mult'] = 3
	prop['Ammo'] = 24
	prop['Zoom'] = 5.2

WProp['Rocket Launcher'] = {}
	local prop = WProp['Rocket Launcher']
	prop['Bloom'] = 200
	prop['Barrel'] = {}
	prop['Barrel'][1] = {0.042,0.512,0.177}
	prop['Barrel'][2] = {-0.043,0.512,0.168}
	prop['Bones'] = {36,25,true,25,22,0}
	prop['Size'] = 'Massive'
	prop['Retical Mult'] = 1
	prop['Ammo'] = 2
	prop['Zoom'] = 1.5
	
WProp['Pistol'] = {}
	local prop = WProp['Pistol']
	prop['Bloom'] = 20
	prop['Barrel'] = {}
	prop['Barrel'][1] = {-0.065,0.206,0.131}
	prop['Bones'] = {25,22,false,25,22,-0.142}
	prop['Size'] = 'Small'
	prop['Retical Mult'] = 2
	prop['Ammo'] = 12
	prop['Zoom'] = 1.5
	

function getBarrelLocation(weapon,allowRandom)
	if allowRandom then
		local offsets = WProp[weapon]['Barrel']
		local pos = (#offsets > 1) and math.random(1,#offsets) or 1
		return offsets[pos][1],offsets[pos][2],offsets[pos][3]
	else
		oX,oY,oZ = 0,0,0
		for i,v in pairs(WProp[weapon]['Barrel']) do
			oX,oY,oZ = oX+v[1],oY+v[2],oZ+v[3]
		end
		return (oX/(#WProp[weapon]['Barrel'])),(oY/(#WProp[weapon]['Barrel'])),(oZ/(#WProp[weapon]['Barrel']))
	end
end

function Spawn()
	for i,v in pairs(WProp) do
		setElementData(localPlayer,'Ammo.'..i,nil)
		setElementData(localPlayer,'Rounds.'..i,nil)
		Ammo[localPlayer] = nil
	end
	local rWeapon = math.random(1,2)
	local weapon = (rWeapon == 1) and 'AR' or 'BR'
	setElementData(localPlayer,'Weapon_Primary',weapon)
	setElementData(localPlayer,'Weapon_Secoundary','Pistol')
	setElementData(localPlayer,'Reload',nil)
end
addEventHandler("onClientPlayerSpawn", localPlayer, Spawn) 


toggleReload = nil

function reload(weaponType,rounds)
	setElementData(localPlayer,'Rounds.'..weaponType,getElementData(localPlayer,'Rounds.'..weaponType)-rounds)
	setElementData(localPlayer,'Ammo.'..weaponType,getElementData(localPlayer,'Ammo.'..weaponType)+rounds)
	toggleReload = nil
	setElementData(localPlayer,'Reload',nil)
end

soundTable = {}
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

function playReload(x,y,z,wep)
	local sound = playSound3D('ReloadSounds/'..wep..'.wav', x,y,z) 
	setSoundMaxDistance (sound,10)
	setSoundVolume (sound,2)
	soundTable[sound] = {getTickCount(),getSoundLength(sound)}
	return getSoundLength(sound)
end

function playReloads(x,y,z,wep,ammo)
	reload(wep,ammo)
	playReload(x,y,z,wep)
end


function positionWeaponR()

	if not (getResourceFromName('cStream') and getResourceFromName('man_Weapon')) then
		return
	end
	
	for i,v in pairs(Weapon) do
		if (not isElement(i)) then
			if Weapon[i] then
				if isElement(v['Model']) then
					destroyElement(v['Model'])
				end
				Weapon[i] = nil
			end
		end
	end	
			
	local aiming = tonumber(getElementData(localPlayer,'State.Weapon_Aim')) or -1

	if (aiming >= 1 ) then
		local ped = getElementData(localPlayer,'Ped')
		Weapon[localPlayer] = Weapon[localPlayer] or {}
			
		local currentWep = Weapon[localPlayer]['Type']
		local weaponType = (getElementData(localPlayer,'weapon_Slot_E') or Weapon[localPlayer]['Type'] or getElementData(localPlayer,'weapon_Slot'))
	
		if not weaponType then
			return
		end
		
		local weapon = assignWeapon(localPlayer,weaponType)

		if isElement(weapon) then
			local weaponTable = WProp[weaponType]
	
			
			if Ammo[localPlayer] then
				if not Ammo[localPlayer][weaponType] then
					Ammo[localPlayer][weaponType] = weaponTable['Ammo']
					if not getElementData(localPlayer,'Ammo.'..weaponType) then
						setElementData(localPlayer,'Ammo.'..weaponType,weaponTable['Ammo'])
					end
					if not getElementData(localPlayer,'Rounds.'..weaponType) then
						setElementData(localPlayer,'Rounds.'..weaponType,weaponTable['Ammo']*3)
					end
				else
					Ammo[localPlayer][weaponType] = getElementData(localPlayer,'Ammo.'..weaponType)
				end
			else
				Ammo[localPlayer] = {}
			end
			
			setElementData(localPlayer,'Weapon',weapon)
					
			if getKeyState(getElementData(localPlayer,'Reload Key') or 'r') then
				if (not isCursorShowing()) and (not isMTAWindowActive ()) then
					if not toggleReload then
						if (weaponTable['Ammo'] > getElementData(localPlayer,'Ammo.'..weaponType)) and (getElementData(localPlayer,'Rounds.'..weaponType) > 0) then
							toggleReload = true
							
							
							local rounds = math.min(math.min(tonumber(getElementData(localPlayer,'Rounds.'..weaponType)),weaponTable['Ammo']),(weaponTable['Ammo']-tonumber(getElementData(localPlayer,'Ammo.'..weaponType))))
							
							
							local x,y,z = getElementPosition(weapon)
	
							setElementData(localPlayer,'Reload',true)
							if weaponTable['Reload Amount'] then
								local timer = playReload(x,y,z,weaponType)
								setTimer ( playReloads, timer*1000,(weaponTable['Reload Amount']-1), x,y,z, weaponType,(rounds/(weaponTable['Reload Amount']-1)) )
							else
								local timer = playReload(x,y,z,weaponType)
								setTimer ( reload, timer*1000, 1,weaponType,rounds )
							end
						end
					end
				end
			end
					
					
			if (tonumber(getElementData(localPlayer,'Ammo.'..weaponType)) or 0) < 0 then
				setElementData(localPlayer,'Ammo.'..weaponType,0)
			end
			
			if (tonumber(getElementData(localPlayer,'Rounds.'..weaponType)) or 0) < 0 then
				setElementData(localPlayer,'Rounds.'..weaponType,0)
			end
					
			local offX,offY,offZ = getBarrelLocation(weaponType,true)
			local offset = getOffset(weapon,offX,offY,offZ)
			local offset2 = getOffset(weapon,offX,offY+1,offZ)
					
			setElementData(localPlayer,'wep.Pos',{offset.x,offset.y,offset.z})
			setElementData(localPlayer,'wep.Target',{offset2.x+(math.random(-weaponTable['Bloom'],weaponTable['Bloom'])/10000),offset2.y+(math.random(-weaponTable['Bloom'],weaponTable['Bloom'])/10000),offset2.z+(math.random(-weaponTable['Bloom'],weaponTable['Bloom'])/10000)})
					
			local offX,offY,offZ = getBarrelLocation(weaponType)
			local offset = getOffset(weapon,offX,offY*20*weaponTable['Retical Mult'],offZ)
			local x,y = getScreenFromWorldPosition(offset.x,offset.y,offset.z,1,false)
					
			setElementData(localPlayer,'wep.Offset',{offX,offY,offZ})
			setElementData(localPlayer,'wep.Zoom',(weaponTable['Zoom'] or 1))	
			if x then
				screenX = blend (screenX,y,25,15,50)
				local size = 25+(200*(getElementData(localPlayer,'chSize') or 0))
				setElementData(localPlayer,'CY',screenX-size)
				if fileExists ('Crosshairs/'..weaponType..'.png') then
					dxDrawImage ( x-size,screenX-size,size*2,size*2, 'Crosshairs/'..weaponType..'.png',0,0,0,tocolor(255,255,255,150) )
				else
					dxDrawImage ( x-size,screenX-size,size*2,size*2, 'crosshair.png',0,0,0,tocolor(255,255,255,150) )
				end
			end
		end
	end
end

addEventHandler ( "onClientRender", root, positionWeaponR)


function positionWeapon()

	if not (getResourceFromName('cStream') and getResourceFromName('man_Weapon')) then
		return
	end
	
	for i,v in pairs(getElementsByType('player',false)) do
		local aiming = tonumber(getElementData(v,'State.Weapon_Aim')) or -1

		if (aiming >= 0 ) then
			local ped = getElementData(v,'Ped')
			if isElement(ped) then
				Weapon[v] = Weapon[v] or {}
				
				local weaponType = (getElementData(v,'weapon_Slot_E') or Weapon[v]['Type'] or getElementData(v,'weapon_Slot'))

				local weapon = assignWeapon(v,weaponType)

				if isElement(weapon) then
					local weaponTable = WProp[weaponType]
						
						
					if special[weaponType] then
						special[weaponType](weapon,v)
					end

					local x,y,z = getPedBonePosition ( ped,weaponTable['Bones'][aiming < 3 and 4 or 1] )
					local xA,yA,zA = getPedBonePosition ( ped,weaponTable['Bones'][aiming < 3 and 5 or 2] )
					if not weaponTable['Bones'][3] then
						local px,py,pz = getPedBonePosition ( ped,weaponTable['Bones'][1] )
						local xra,yra,zra = findRotation3D( xA,yA,zA+weaponTable['Bones'][6],x,y,z ) 
						local xr,yr,zr = getElementRotation(ped)
						local xrB,yrB,zrB = getElementRotation(weapon)
							
						local zrC = blend (zrB,zr,65,35,50)
						local xrC = blend (xrB,xra,65,35,50)
							
						setElementPosition(weapon,px,py,pz)
						setElementRotation(weapon,xrC,yr,zrC)
					else
						local px,py,pz = getPedBonePosition ( ped,weaponTable['Bones'][2] )
						local xra,yra,zra = findRotation3D( xA,yA,zA+weaponTable['Bones'][6],x,y,z ) 
						local xr,yr,zr = getElementRotation(ped)
						local xrB,yrB,zrB = getElementRotation(weapon)
							
						local zrC = blend (zrB,zr,65,35,50)
						local xrC = blend (xrB,xra,65,35,50)
							
						setElementPosition(weapon,px,py,pz)
						setElementRotation(weapon,xrC,yr,zrC)
					end
				end
			end
		else
			if Weapon[v] then
				if isElement(Weapon[v]['Model']) then
					destroyElement(Weapon[v]['Model'])
				end
				Weapon[v] = nil
			end
		end
	end
end

addEventHandler ( "onClientPreRender", root, positionWeapon,false,"low+1" )
