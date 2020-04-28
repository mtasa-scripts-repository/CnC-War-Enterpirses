-- Tables --
table.insert(menus.right.items['New Element'],{'list','Gameplay'})
menus.right['New Element'].lists['Gameplay'] = {}
table.insert(menus.right['New Element'].lists['Gameplay'],{'list','Spawn Points'})

lSecession.PSpawnSettings = {}

lSecession.Teams = {}

lSecession.Teams['Red'] = {255,0,0}
lSecession.Teams['Green'] = {0,255,0}
lSecession.Teams['Blue'] = {0,0,255}
lSecession.Teams['Yellow'] = {255,255,0}
lSecession.Teams['Neutral'] = {65,65,65}

-- Functions --
functions.populateSpawns = function (list)
	menus.right['New Element'].lists['Spawn Points'] = {}
	table.insert(menus.right['New Element'].lists['Spawn Points'],{'Player Spawn','Spawn Point'})
end
functions.populateSpawns()

for i,v in pairs(getElementsByType('object')) do
	if (getElementData(v,'eType') == 'Spawn Point') then
		setElementAlpha(v,255)
		setElementCollisionsEnabled(v,true)
	end
end
	
mRender.SpawnMarkers = function()
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'eType') == 'Spawn Point') then
			local x,y,z = getElementPosition(v)
			local team = getElementData(v,'Team')
			local r,g,b = unpack(lSecession.Teams[team])
			dxDrawMaterialLine3D(x,y,z+1.5,x,y,z+0.5,functions.prepImage('Player Spawn'),1,tocolor(r,g,b,200))
			
			
			local matrix = v.matrix

			local m1 = matrix:transformPosition(Vector3(1,0,0)) 
			local m2 = matrix:transformPosition(Vector3(-1,0,0)) 
			
			dxDrawMaterialLine3D(m1.x,m1.y,m1.z,m2.x,m2.y,m2.z,functions.prepImage('Spawn Arrow'),2,tocolor(r,g,b,200),false,x,y,z+5)
		end
	end
end

--#Player Spawn Creation
functions['Player Spawn'] = function(arguments,x,y,w,h,side,_,_,fadePercent)
	local fadePercent = tonumber(fadePercent) or 1
	local width = h/2
	
	local image = functions.prepImage(arguments[1])
	
	local hover = functions.isCursorOnElement(x,y,w,h,'Place Player Spawn',arguments[2],arguments[2],arguments[3],'Player Spawn' )
	
	if image then
		dxDrawImage(x+(h/5),y,h,h,image, 0, 0, 0, tocolor(255,255,255, (200-(hover*50))*fadePercent),true)	
	end
	
	dxDrawText(arguments[2], x+(10*s)+(h*1.2),y,x+w,y+h, tocolor(255, 255, 255, 220*fadePercent), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)	
end

functions['Place Player Spawn'] = function (spawnType)
	local x,y,z = getWorldFromScreenPosition ( xSize/2, ySize/2, lSecession.variables['Depth'][1] )
	local px,py,pz = getCameraMatrix()
	local _,xa,ya,za = processLineOfSight ( px, py, pz,  x,y,z)
	if _ then
		functions.server('createSpawn',spawnType,xa,ya,za)
	else
		functions.server('createSpawn',spawnType,x,y,z)
	end
end

lSecession.cDefaults['Allow Respawn'] = true
lSecession.cDefaults['Allow Spawn'] = true
lSecession.cDefaults['Team'] = 'Red'

functions.prepCustomization['Spawn Point'] = function ()
	table.insert(menus.right.items['Customize'],{'Option','Team',{'Red','Green','Blue','Yellow','Neutral'}})
		local Team = functions.findSetting('data','Team') or lSecession.cDefaults['Team']
		lSecession.variables['Team'] = {Team,functions.findTable({'Red','Green','Blue','Yellow','Neutral'},Team)}
		
	table.insert(menus.right.items['Customize'],{'Check Box','Allow Respawn'})
		lSecession.variables['Allow Respawn'] = {functions.findSetting('data','Allow Respawn')}

	table.insert(menus.right.items['Customize'],{'Check Box','Allow Spawn'})
		lSecession.variables['Allow Spawn'] = {functions.findSetting('data','Allow Spawn')}
end


