images = {}

-- Values --
size = 0.3
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize

-- Gen Functions --

lists = {}

lists['Small'] = {'Pistol'}
lists['Medium'] = {'AR','BR','Shotgun'}
lists['Large'] = {'Sniper','Rocket Launcher'}

renameWep = {}
renameWep['Shot Gun'] = 'Shotgun'

function prepImage(path,mip)
	if path then
		if fileExists ( 'Weapon Icons/'..path..'.png' ) then
			images[path] = images[path] or dxCreateTexture('Weapon Icons/'..path..'.png','dxt5',mip)
			return images[path]
		end
	end
end


function getWeaponSpawns ()
	local Weapons = {}
	for i,v in pairs(getElementsByType('object',true)) do
		if (getElementData(v,'eType') == 'Weapon') then
			if (getElementData(v,'Wep Type') == 'Weapon Spawn') or (getElementData(v,'Wep Type') == 'Weapon Drop')  then
				if not getElementData(v,'pickedup') then
					if (lists[getElementData(v,'Weapon')] and (not getElementData(v,'newWeapon'))) then
						setElementData(v,'newWeapon',lists[getElementData(v,'Weapon')][math.random(1,#lists[getElementData(v,'Weapon')])])
						table.insert(Weapons,v)
					else
						table.insert(Weapons,v)
					end
				end
			end
		end
	end
	return Weapons
end

function getAmmoSpawns ()
	local Weapons = {}
	for i,v in pairs(getElementsByType('object',true)) do
		if (getElementData(v,'eType') == 'Weapon') then
			if (getElementData(v,'Wep Type') == 'Ammo Spawn') or (getElementData(v,'Wep Type') == 'Ammo Drop') then
				if not getElementData(v,'pickedup') then
					table.insert(Weapons,v)
				end
			end
		end
	end
	return Weapons
end


weaponSize  = {}
weaponSize['Pistol'] = 'Small'
weaponSize['Sniper'] = 'Large'
weaponSize['Rocket Launcher'] = 'Massive'

toggle = false

function getActionKey()
	if getKeyState((getElementData(localPlayer,'Interact') or 'e')) and (not toggle) then
		if (not isMTAWindowActive()) and (not isCursorShowing()) then
			toggle = true
			return true
		end
	end
end


function pickup(weaponName,ammoCount,ammoonly,element)
	local weaponName = renameWep[weaponName] or weaponName
	if ammoonly then
		if ((getElementData(localPlayer,'Weapon_Primary') == weaponName) or (getElementData(localPlayer,'Weapon_Secoundary') == weaponName)) then
			dxDrawText ('Hit ['..(getElementData(localPlayer,'Interact') or 'e')..'] to pickup '..ammoCount..' '..weaponName..' rounds.',xSize/2,ySize/2,xSize/2,ySize/2,tocolor(255,255,255,80), 1, 2, "clear",'center','center',false,false,false,true )
			if getActionKey() then
				toggle = true
				setElementData(localPlayer,'Rounds.'..weaponName,getElementData(localPlayer,'Rounds.'..weaponName)+ammoCount)
				setElementData(element,'pickedup',true)
				triggerEvent ("addNotification", root,'Picked up '..ammoCount..' rounds for '..weaponName..'.')
			end
		end
	else
		if ((getElementData(localPlayer,'Weapon_Primary') == weaponName) or (getElementData(localPlayer,'Weapon_Secoundary') == weaponName)) then
			dxDrawText ('Hit ['..(getElementData(localPlayer,'Interact') or 'e')..'] to pickup '..ammoCount..' '..weaponName..' rounds.',xSize/2,ySize/2,xSize/2,ySize/2,tocolor(255,255,255,80), 1, 2, "clear",'center','center',false,false,false,true )
			if getActionKey() then
				toggle = true
				setElementData(localPlayer,'Rounds.'..weaponName,getElementData(localPlayer,'Rounds.'..weaponName)+ammoCount)
				setElementData(element,'pickedup',true)
				triggerEvent ("addNotification", root,'Picked up '..ammoCount..' rounds for '..weaponName..'.')
			end
		else
			if not getElementData(localPlayer,'weapon_Slot') then
				dxDrawText ('You must be holding a weapon to swap it.',xSize/2,ySize/2,xSize/2,ySize/2,tocolor(255,255,255,80), 1, 2, "clear",'center','center',false,false,false,true )
			else
				dxDrawText ('Hit ['..(getElementData(localPlayer,'Interact') or 'e')..'] to swap '..getElementData(localPlayer,'weapon_Slot')..'\nwith '..weaponName..' containing '..ammoCount..' rounds.',xSize/2,ySize/2,xSize/2,ySize/2,tocolor(255,255,255,80), 1, 2, "clear",'center','center',false,false,false,true )
				if getActionKey() then
					toggle = true
					if (getElementData(localPlayer,'Weapon_Primary') == getElementData(localPlayer,'weapon_Slot')) then
						triggerEvent ("addNotification", root,'Swapped '..getElementData(localPlayer,'weapon_Slot')..' With '..weaponName..'.')
						setElementData(element,'respawn',true)
						setElementData(element,'newWeapon',getElementData(localPlayer,'weapon_Slot'))
						setElementData(element,'newAmmo',getElementData(localPlayer,'Rounds.'..getElementData(localPlayer,'weapon_Slot')))
						setElementData(localPlayer,'Ammo.'..getElementData(localPlayer,'weapon_Slot'),nil)
						setElementData(localPlayer,'Rounds.'..getElementData(localPlayer,'weapon_Slot'),nil)
						setElementData(localPlayer,'Weapon_Primary',weaponName)
						setElementData(localPlayer,'Rounds.'..weaponName,ammoCount)
						setElementData(localPlayer,'weapon_Slot',weaponName)
						setElementData(localPlayer,'wep.Size',weaponSize[weaponName])
						
					elseif (getElementData(localPlayer,'Weapon_Secoundary') == getElementData(localPlayer,'weapon_Slot')) then
						triggerEvent ("addNotification", root,'Swapped '..getElementData(localPlayer,'weapon_Slot')..' With '..weaponName..'.')
						
						setElementData(element,'respawn',true)
						setElementData(element,'newWeapon',getElementData(localPlayer,'weapon_Slot'))
						setElementData(element,'newAmmo',getElementData(localPlayer,'Rounds.'..getElementData(localPlayer,'weapon_Slot')))
						setElementData(localPlayer,'Ammo.'..getElementData(localPlayer,'weapon_Slot'),nil)
						setElementData(localPlayer,'Rounds.'..getElementData(localPlayer,'weapon_Slot'),nil)
						setElementData(localPlayer,'Weapon_Secoundary',weaponName)
						setElementData(localPlayer,'Rounds.'..weaponName,ammoCount)
						setElementData(localPlayer,'weapon_Slot',weaponName)
						setElementData(localPlayer,'wep.Size',weaponSize[weaponName])
					end
				end
			end
		end
	end
end

function drawIcons()
	if not isPedDead(localPlayer) then
		if toggle then
			toggle = getKeyState((getElementData(localPlayer,'Interact') or 'e'))
		end
		
		local xa,ya,za = getElementPosition(localPlayer)
		for i,v in pairs(getWeaponSpawns()) do
			local x,y,z = getElementPosition(v)
			if isElementOnScreen(v) then
				local distance = getDistanceBetweenPoints3D(xa,ya,za,x,y,z)
				if distance < 25 then
					local name = renameWep[(getElementData(v,'newWeapon') or getElementData(v,'Weapon'))] or (getElementData(v,'newWeapon') or getElementData(v,'Weapon'))
					local image = prepImage(name,true)
					if image then
						dxDrawMaterialLine3D(x, y, z+1, x, y, z+1-(2*size), image, size*4,tocolor(255, 255, 255, 50),false,nil,nil,z)
					end
					if distance < 2 then
						pickup(name,tonumber(getElementData(v,'newAmmo') or getElementData(v,'Ammo Count')),nil,v)
					end
				end
			end
		end
		
		
		for i,v in pairs(getElementsByType('Weapon_Drop')) do
			if not getElementData(v,'pickedup') then
				local x,y,z = getElementPosition(v)
				local distance = getDistanceBetweenPoints3D(xa,ya,za,x,y,z)
				if distance < 25 then
					local name = renameWep[(getElementData(v,'newWeapon') or getElementData(v,'Weapon'))] or (getElementData(v,'newWeapon') or getElementData(v,'Weapon'))
					local image = prepImage(name,true)
					if image then
						dxDrawMaterialLine3D(x, y, z+1, x, y, z+1-(2*size), image, size*4,tocolor(255, 255, 255, 50),false,nil,nil,z)
					end
					if distance < 2 then
						pickup(name,tonumber(getElementData(v,'newAmmo') or getElementData(v,'Ammo Count')),nil,v)
					end
				end
			end
		end
		
		for i,v in pairs(getAmmoSpawns()) do
			local x,y,z = getElementPosition(v)
			if isElementOnScreen(v) then
			local distance = getDistanceBetweenPoints3D(xa,ya,za,x,y,z)
				if distance < 25 then
					local name = renameWep[(getElementData(v,'newWeapon') or getElementData(v,'Weapon'))] or (getElementData(v,'newWeapon') or getElementData(v,'Weapon'))
					if ((getElementData(localPlayer,'Weapon_Primary') == name) or (getElementData(localPlayer,'Weapon_Secoundary') == name)) then
						local image = prepImage('Magazine',true)
						local image2 = prepImage(name,true)
						if image and image2 then
							dxDrawMaterialLine3D(x, y, z+1, x, y, z+1-(2*size), image, size*2,tocolor(255, 255, 255, 25),false,nil,nil,z)
							dxDrawMaterialLine3D(x, y, z+1.5, x, y, z+1.5-(2*size), image2, size*4,tocolor(255, 255, 255, 50),false,nil,nil,z)
						end
						if distance < 2 then
							pickup(name,tonumber(getElementData(v,'Ammo Count')),true,v)
						end
					end
				end
			end
		end
	end
	
	for i,v in pairs(getElementsByType('Weapon_Drop')) do
		if not getElementData(v,'pickedup') then
			if not getElementData(v,'Grounded') then
				local x,y,z = getElementPosition(v)
				local hit, x, y, z, elementHit = processLineOfSight ( x,y,z,x,y,z-10,true,true,true )
				if hit then
					setElementPosition(v,x,y,z)
					setElementData(v,'Grounded',true)
				end
			end
		end
	end
end

addEventHandler ( "onClientRender", root, drawIcons)
