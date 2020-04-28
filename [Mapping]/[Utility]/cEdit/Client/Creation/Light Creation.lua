-- Tables --
table.insert(menus.right.items['New Element'],{'list','Lighting'})
menus.right['New Element'].lists['Lighting'] = {}

-- Functions --
functions.populateLighting = function (list)
	menus.right['New Element'].lists['Lighting'] = {}
	table.insert(menus.right['New Element'].lists['Lighting'],{'Lighting','Light Zone'})
end
functions.populateLighting()

mRender.lightingMarkers = function()

	local hour, minute = getTime ()
			
	if hour >= 19 then
		Skyalpha = math.min(((27-hour)-(minute/60))/7.4,1)
	elseif hour <= 6 then
		Skyalpha = math.max(((hour-1)+(minute/60))/7,0.1)
	else
		Skyalpha = 1
	end
			
	local Skyalpha = (Skyalpha < 1) and Skyalpha^7 or Skyalpha

	local b = math.min(math.max(Skyalpha,0),1)
		
		
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'eType') == 'Light Zone') then
			if isElementOnScreen ( v ) then
				local x,y,z = getElementPosition(v)
				local xa,ya,za = getCameraMatrix()
				local distance = getDistanceBetweenPoints3D(x,y,z,xa,ya,za)
				if distance < 100 then
					local fade = 100-distance
					
					local dEnable = getElementData(v,'Day Enabled')
					local r_D,g_D,b_D = unpack(getElementData(v,'lightColor_D') or {255,255,255})
								
					local nEnable = getElementData(v,'Night Enabled')
					local r_N,g_N,b_N = unpack(getElementData(v,'lightColor_N') or {255,255,255})
					
					local rT,gT,bT = (r_D*b)+(r_N*(1-b)),(g_D*b)+(g_N*(1-b)),(b_D*b)+(b_N*(1-b)) -- Blends day time and night values
								
					local aAlpha = (dEnable and 1 or (1-b))*(nEnable and 1 or b)
					
					local selected = getElementData(v,'Selected') and -20 or 0
					local hover = (element == lSecession.highLightedElement) and -20 or 0
					
					
					dxDrawMaterialLine3D(x,y,z+1.5,x,y,z+0.5,functions.prepImage('LightingT'),1,tocolor(rT,gT,bT,(2*fade)+selected+hover))
					dxDrawMaterialLine3D(x,y,z+1.5,x,y,z+0.5,functions.prepImage('LightingB'),1,tocolor(rT,gT,bT,(2*fade)+selected+hover))
					
					
					local size = tonumber(getElementData(v,'Size')) or 5
					local heightX = tonumber(getElementData(v,'Height M')) or 1
					functions.drawLightGimbal(v,size,tocolor(rT,gT,bT,aAlpha*(2*fade)),heightX)
				end
			end
		end
	end
end

functions.getLightOffset = function(light,x,y,z)
	local newMatrix = (light.matrix:transformPosition(Vector3(x,y,z)))
	return newMatrix.x,newMatrix.y,newMatrix.z
end

functions.drawLightGimbal = function (light,size,color,heightX)			
	local xA,yA,zA = functions.getLightOffset(light,0,size/2,0)
	local xB,yB,zB = functions.getLightOffset(light,0,-size/2,0)
	local xC,yC,zC = functions.getLightOffset(light,size,0,0)
	dxDrawMaterialLine3D(xB,yB,zB,xA,yA,zA,functions.prepImage('CircleSelected'), size*heightX,color,false,xC,yC,zC)			

	local xA,yA,zA = functions.getLightOffset(light,size/2,0,0)
	local xB,yB,zB = functions.getLightOffset(light,-size/2,0,0)
	local xC,yC,zC = functions.getLightOffset(light,0,size,0)
	dxDrawMaterialLine3D(xB,yB,zB,xA,yA,zA,functions.prepImage('CircleSelected'), size*heightX,color,false,xC,yC,zC)			

	local xC,yC,zC = functions.getLightOffset(light,0,0,size)
	dxDrawMaterialLine3D(xB,yB,zB,xA,yA,zA,functions.prepImage('CircleSelected'), size,color,false,xC,yC,zC)
end

functions['Lighting'] = function(arguments,x,y,w,h,side,_,_,fadePercent)
	local fadePercent = tonumber(fadePercent) or 1
	local width = h/2
	
	local image = functions.prepImage(arguments[1])
	
	local hover = functions.isCursorOnElement(x,y,w,h,arguments[2],arguments[2],arguments[2] )
	
	if image then
		dxDrawImage(x+(h/5),y,h,h,image, 0, 0, 0, tocolor(255,255,255, (200-(hover*50))*fadePercent),true)	
	end
	
	dxDrawText(arguments[2], x+(10*s)+(h*1.2),y,x+w,y+h, tocolor(255, 255, 255, 220*fadePercent), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
end

functions['Light Zone'] = function ()
	local x,y,z = getWorldFromScreenPosition ( xSize/2, ySize/2, lSecession.variables['Depth'][1] )
	local px,py,pz = getCameraMatrix()
	local _,xa,ya,za = processLineOfSight ( px, py, pz,  x,y,z)
	if _ then
		functions.server('Create Light Zone',xa,ya,za)
	else
		functions.server('Create Light Zone',x,y,z)
	end
end

for i,v in pairs(getElementsByType('object')) do
	if (getElementData(v,'eType') == 'Light Zone') then
		setElementAlpha(v,255)
		setElementCollisionsEnabled(v,true)
	end
end

setElementData(root,'mapEditor',true)


lSecession.cDefaults['lightColor_D'] = {255,255,255} -- Day
lSecession.cDefaults['Day Enabled'] = true
lSecession.cDefaults['lightColor_N'] = {255,255,255} -- Night
lSecession.cDefaults['Night Enabled'] = true
lSecession.cDefaults['Shape'] = 'Sphere'
lSecession.cDefaults['LightSource'] = 'Sun'
lSecession.cDefaults['Size'] = 5
lSecession.cDefaults['Height M'] = 1
lSecession.cDefaults['Darkness M'] = 1

functions.prepCustomization['Light Zone'] = function ()
	table.insert(menus.right.items['Customize'],{'list','Day'})
	menus.right['Customize'].lists['Day'] = {}
	
	table.insert(menus.right['Customize'].lists['Day'],{'Color Picker','lightColor_D'})
		local lightColor_D = (functions.findSetting('data','lightColor_D') == ' ') and {} or (functions.findSetting('data','lightColor_D') or lSecession.cDefaults['lightColor_D'])
		lSecession.variables['lightColor_D'] = lightColor_D
		
	table.insert(menus.right['Customize'].lists['Day'],{'Check Box','Day Enabled'})
		lSecession.variables['Day Enabled'] = {functions.findSetting('data','Day Enabled')}

	table.insert(menus.right.items['Customize'],{'list','Night'})
		menus.right['Customize'].lists['Night'] = {}
	
	table.insert(menus.right['Customize'].lists['Night'],{'Color Picker','lightColor_N'})
		local lightColor_N = (functions.findSetting('data','lightColor_N') == ' ') and {} or (functions.findSetting('data','lightColor_N') or lSecession.cDefaults['lightColor_N'])
		lSecession.variables['lightColor_N'] = lightColor_N
		
	table.insert(menus.right['Customize'].lists['Night'],{'Check Box','Night Enabled'})
		lSecession.variables['Night Enabled'] = {functions.findSetting('data','Night Enabled')}
		
	table.insert(menus.right.items['Customize'],{'Option','LightSource',{'Sun','Top','Bottom','Source'}})
		local LightSource = functions.findSetting('data','LightSource') or lSecession.cDefaults['LightSource']
		lSecession.variables['LightSource'] = {LightSource,functions.findTable({'Sun','Top','Bottom','Source'},LightSource)}
		
	table.insert(menus.right.items['Customize'],{'Number Box','Size'})
		lSecession.variables['Size'] = {functions.findSetting('data','Size') or lSecession.cDefaults['Size']}
		
	table.insert(menus.right.items['Customize'],{'Number Box','Height M'})
		lSecession.variables['Height M'] = {functions.findSetting('data','Height M') or lSecession.cDefaults['Height M']}
		
	table.insert(menus.right.items['Customize'],{'Number Box','Darkness M'})
		lSecession.variables['Darkness M'] = {functions.findSetting('data','Darkness M') or lSecession.cDefaults['Darkness M']}

end