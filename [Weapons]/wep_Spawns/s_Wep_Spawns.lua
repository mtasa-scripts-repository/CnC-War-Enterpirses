function getWeaponSpawns ()
	local Weapons = {}
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'eType') == 'Weapon') then
			if (getElementData(v,'Wep Type') == 'Weapon Spawn') or (getElementData(v,'Wep Type') == 'Weapon Drop') then
				table.insert(Weapons,v)
			end
		end
	end
	return Weapons
end

function getAmmoSpawns ()
	local Weapons = {}
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'eType') == 'Weapon') then
			if (getElementData(v,'Wep Type') == 'Ammo Spawn') or (getElementData(v,'Wep Type') == 'Ammo Drop') then
				table.insert(Weapons,v)
			end
		end
	end
	return Weapons
end

reload = {}
despawn = {}
function reloadSpawns()
	for i,v in pairs(getWeaponSpawns()) do
		if getElementData(v,'pickedup') or getElementData(v,'respawn') then
			local respawn = getElementData(v,'wep_Respawn')
			if not reload[v] then
				reload[v] = tonumber(getElementData(v,'wep_Respawn'))
			else
				reload[v] = reload[v] - 1
				if (reload[v] < 0) then
					reload[v] = nil
					setElementData(v,'pickedup',nil)
					setElementData(v,'newWeapon',nil)
					setElementData(v,'newAmmo',nil)
				end
			end
		end
	end
	
	
	for i,v in pairs(getElementsByType('Weapon_Drop')) do
		if not despawn[v] then
			despawn[v] = 60
		else
			despawn[v] = despawn[v] - 1
			if (despawn[v] < 0) then
				despawn[v] = nil
				destroyElement(v)
			end
		end
	end
	
	for i,v in pairs(getAmmoSpawns()) do
		if getElementData(v,'pickedup') then
			if not reload[v] then
				reload[v] = tonumber(getElementData(v,'wep_Respawn'))
			else
				reload[v] = reload[v] - 1
				if (reload[v] < 0) then
					reload[v] = nil
					setElementData(v,'pickedup',nil)
				end
			end
		end
	end
end


setTimer ( reloadSpawns, 1000, 0 )

function player_Wasted ( )
	local x,y,z = getElementPosition(source)
	local mainWeapon = getElementData(source,('Weapon_Primary'))
	local mainRounds = tonumber(getElementData(source,'Rounds.'..mainWeapon)) or 0
	
	if (mainRounds > 0) then
		local weaponA =  createElement( "Weapon_Drop")
		setElementData(weaponA,'Weapon',mainWeapon)
		setElementData(weaponA,'Ammo Count',mainRounds)
		setElementPosition(weaponA,x+math.random(-3,3),y+math.random(-3,3),z)
	end
	
	local secoundWeapon = getElementData(source,('Weapon_Secoundary'))
	local secoundRounds = tonumber(getElementData(source,'Rounds.'..secoundWeapon)) or 0
	if (secoundRounds > 0) then
		local weaponB =  createElement( "Weapon_Drop")
		setElementData(weaponB,'Weapon',secoundWeapon)
		setElementData(weaponB,'Ammo Count',secoundRounds)
		setElementPosition(weaponB,x+math.random(-3,3),y+math.random(-3,3),z)
	end
end
addEventHandler ( "onPlayerWasted", getRootElement(), player_Wasted )
