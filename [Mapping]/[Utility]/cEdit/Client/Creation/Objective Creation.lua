--lSecession.Teams['Red'] = {255,0,0}
table.insert(menus.right['New Element'].lists['Gameplay'],{'list','Objectives'})

-- Functions --
functions.populateObjective = function ()
	menus.right['New Element'].lists['Objectives'] = {}
	table.insert(menus.right['New Element'].lists['Objectives'],{'Objective','Objective'})
end
functions.populateObjective()


for i,v in pairs(getElementsByType('object')) do
	if (getElementData(v,'eType') == 'Objective') then
		setElementAlpha(v,255)
		setElementCollisionsEnabled(v,true)
	end
end
	
mRender.ObjectiveMarkers = function()
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'eType') == 'Objective') then
			local x,y,z = getElementPosition(v)
			local team = getElementData(v,'Team')
			local r,g,b = unpack(lSecession.Teams[team])
			dxDrawMaterialLine3D(x,y,z+1.5,x,y,z+0.5,functions.prepImage('objective'),1,tocolor(r,g,b,200))
		end
	end
end

--#Objective Creation
functions['Objective'] = function(arguments,x,y,w,h,side,_,_,fadePercent)
	local fadePercent = tonumber(fadePercent) or 1
	local width = h/2
	
	local image = functions.prepImage(arguments[1])
	
	local hover = functions.isCursorOnElement(x,y,w,h,'Place Objective',arguments[2],arguments[2],arguments[3],'Objective' )
	
	if image then
		dxDrawImage(x+(h/5),y,h,h,image, 0, 0, 0, tocolor(255,255,255, (200-(hover*50))*fadePercent),true)	
	end
	
	dxDrawText(arguments[2], x+(10*s)+(h*1.2),y,x+w,y+h, tocolor(255, 255, 255, 220*fadePercent), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)	
end

functions['Place Objective'] = function (spawnType)
	local x,y,z = getWorldFromScreenPosition ( xSize/2, ySize/2, lSecession.variables['Depth'][1] )
	local px,py,pz = getCameraMatrix()
	local _,xa,ya,za = processLineOfSight ( px, py, pz,  x,y,z)
	if _ then
		functions.server('createObjective',spawnType,xa,ya,za)
	else
		functions.server('createObjective',spawnType,x,y,z)
	end
end

lSecession.cDefaults['Team'] = 'Red'
lSecession.cDefaults['Obj Type'] = 'Marker'
lSecession.cDefaults['Obj ID'] = 1

local objectiveList = {'Marker','Warp In','Warp Out','Flag Spawn','Flag Capture'}

functions.prepCustomization['Objective'] = function ()
	table.insert(menus.right.items['Customize'],{'Option','Team',{'Red','Green','Blue','Yellow','Neutral'}})
		local Team = functions.findSetting('data','Team') or lSecession.cDefaults['Team']
		lSecession.variables['Team'] = {Team,functions.findTable({'Red','Green','Blue','Yellow','Neutral'},Team)}
		
	table.insert(menus.right.items['Customize'],{'Option','Obj Type',objectiveList})
		local oType = functions.findSetting('data','Obj Type') or lSecession.cDefaults['Obj Type']
		lSecession.variables['Obj Type'] = {oType,functions.findTable(objectiveList,Team)}
		
	table.insert(menus.right.items['Customize'],{'Number Box','Obj ID'})
		lSecession.variables['Obj ID'] = {functions.findSetting('data','Obj ID') or lSecession.cDefaults['Obj ID']}
end



