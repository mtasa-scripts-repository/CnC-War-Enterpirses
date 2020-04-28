--lSecession.Teams['Red'] = {255,0,0}
table.insert(menus.right['New Element'].lists['Gameplay'],{'list','Weapon Spawns'})

-- Functions --
functions.populateObjective = function ()
	menus.right['New Element'].lists['Weapon Spawns'] = {}
	table.insert(menus.right['New Element'].lists['Weapon Spawns'],{'Weapon','Weapon'})
end
functions.populateObjective()


for i,v in pairs(getElementsByType('object')) do
	if (getElementData(v,'eType') == 'Weapon') then
		setElementAlpha(v,255)
		setElementCollisionsEnabled(v,true)
	end
end
	
mRender.ObjectiveMarkers = function()
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'eType') == 'Weapon') then
			local x,y,z = getElementPosition(v)
			dxDrawMaterialLine3D(x,y,z+1.5,x,y,z+0.5,functions.prepImage('Weapon'),1,tocolor(200,200,200,200))
		end
	end
end

--#Objective Creation
functions['Weapon'] = function(arguments,x,y,w,h,side,_,_,fadePercent)
	local fadePercent = tonumber(fadePercent) or 1
	local width = h/2
	
	local image = functions.prepImage(arguments[1])
	
	local hover = functions.isCursorOnElement(x,y,w,h,'Place Weapon',arguments[2],arguments[2],arguments[3],'Weapon' )
	
	if image then
		dxDrawImage(x+(h/5),y,h,h,image, 0, 0, 0, tocolor(255,255,255, (200-(hover*50))*fadePercent),true)	
	end
	
	dxDrawText(arguments[2], x+(10*s)+(h*1.2),y,x+w,y+h, tocolor(255, 255, 255, 220*fadePercent), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)	
end

functions['Place Weapon'] = function (spawnType)
	local x,y,z = getWorldFromScreenPosition ( xSize/2, ySize/2, lSecession.variables['Depth'][1] )
	local px,py,pz = getCameraMatrix()
	local _,xa,ya,za = processLineOfSight ( px, py, pz,  x,y,z)
	if _ then
		functions.server('createWeapon',spawnType,xa,ya,za)
	else
		functions.server('createWeapon',spawnType,x,y,z)
	end
end


lSecession.cDefaults['Wep Type'] = 'Weapon Spawn'
lSecession.cDefaults['Weapon'] = 'AR'
lSecession.cDefaults['Ammo Count'] = 36
lSecession.cDefaults['wep_Respawn'] = 25

local wepList = {'Weapon Spawn','Weapon Drop','Ammo Spawn','Ammo Drop'}
local weaponList = {'AR','BR','Shot Gun','Pistol','Sniper','Rocket Launcher','Small','Medium','Large'}

functions.prepCustomization['Weapon'] = function ()
	table.insert(menus.right.items['Customize'],{'Option','Wep Type',wepList})
		local wType = functions.findSetting('data','Wep Type') or lSecession.cDefaults['Wep Type']
		lSecession.variables['Wep Type'] = {wType,functions.findTable(wepList,wType)}
		
	table.insert(menus.right.items['Customize'],{'Option','Weapon',weaponList})
		local wWeapon = functions.findSetting('data','Weapon') or lSecession.cDefaults['Weapon']
		lSecession.variables['Weapon'] = {wWeapon,functions.findTable(weaponList,wWeapon)}
		
		
	table.insert(menus.right.items['Customize'],{'Number Box','Ammo Count'})
		lSecession.variables['Ammo Count'] = {functions.findSetting('data','Ammo Count') or lSecession.cDefaults['Ammo Count']}
		
	table.insert(menus.right.items['Customize'],{'Number Box','wep_Respawn'})
		lSecession.variables['wep_Respawn'] = {functions.findSetting('data','wep_Respawn') or lSecession.cDefaults['wep_Respawn']}
end



