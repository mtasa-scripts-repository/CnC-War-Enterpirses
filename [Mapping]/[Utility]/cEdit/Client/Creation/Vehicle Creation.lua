-- Tables --
lSecession.VehicleLists = 
{
'UNSC',
}

lSecession.VehicleNames = {}

table.insert(menus.right.items['New Element'],{'list','Vehicles'})
menus.right['New Element'].lists['Vehicles'] = {}

-- Functions --
for i,v in pairs(lSecession.VehicleLists) do
	local File =  fileOpen('lists/Vehicle Lists/'..v..'.list')   
	local Data =  fileRead(File, fileGetSize(File))
	local Proccessed = split(Data,10)
	fileClose (File)

	table.insert(menus.right['New Element'].lists['Vehicles'],{'list',v})
	menus.right['New Element'].lists[v] = {}
	
	for iA,vA in pairs(Proccessed) do
		local Ssplit = split(vA,',')
		lSecession.VehicleNames[Ssplit[1]] = lSecession.VehicleNames[Ssplit[1]] or {}
		if not Ssplit[3] then
			table.insert(menus.right['New Element'].lists[v],{'Create Vehicle',Ssplit[1],Ssplit[2]})
			lSecession.VehicleNames[Split[1]]['Default'] = Ssplit[2]
		else
			table.insert(menus.right['New Element'].lists[v],{'Create Vehicle',Ssplit[1],Ssplit[3]..' '..Ssplit[2],Ssplit[3]})
			lSecession.VehicleNames[Ssplit[1]]['Default'] = Ssplit[2]
			lSecession.VehicleNames[Ssplit[1]][Ssplit[3]] = Ssplit[3]..' '..Ssplit[2]
		end
	end
end


mRender.VehicleMarkers = function()
	for i,v in pairs(getElementsByType('vehicle')) do
		if (getElementData(v,'eType') == 'vehicle') then
			local x,y,z = getElementPosition(v)
			local team = getElementData(v,'Team')
			local r,g,b = unpack(lSecession.Teams[team] or {255,255,255})
			dxDrawMaterialLine3D(x,y,z+3.5,x,y,z+2.5,functions.prepImage('Create Vehicle'),1,tocolor(r,g,b,200))
		end
	end
end

--#Vehicle Creation
functions['Create Vehicle'] = function(arguments,x,y,w,h,side,_,_,fadePercent)
	local fadePercent = tonumber(fadePercent) or 1
	local width = h/2
	
	local image = functions.prepImage('Create Vehicle')
	
	local hover = functions.isCursorOnElement(x,y,w,h,'Place Vehicle',arguments[3],arguments[2],arguments[3],arguments[4] )
	
	if image then
		dxDrawImage(x+(h/5),y,h,h,image, 0, 0, 0, tocolor(255, 255, 255, (200-(hover*50))*fadePercent),true)	
	end
	
	dxDrawText(arguments[3], x+(10*s)+(h*1.2),y,x+w,y+h, tocolor(255, 255, 255, 220*fadePercent), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
end

for i,v in pairs(getElementsByType('vehicle')) do
	setElementData(v,'eType','vehicle')
end

functions['Place Vehicle'] = function (id,name,varient)
	local x,y,z = getWorldFromScreenPosition ( xSize/2, ySize/2, lSecession.variables['Depth'][1] )
	local px,py,pz = getCameraMatrix()
	local _,xa,ya,za = processLineOfSight ( px, py, pz,  x,y,z)
	if _ then
		functions.server('createVehicle',name,id,xa,ya,za,varient)
	else
		functions.server('createVehicle',name,id,x,y,z,varient)
	end
end

lSecession.cDefaults['Allow Respawn'] = true
lSecession.cDefaults['Team'] = 'Red'
lSecession.cDefaults['Respawn Time'] = 10000 -- // 10 secounds

functions.prepCustomization['vehicle'] = function ()
	table.insert(menus.right.items['Customize'],{'Option','Team',{'Red','Green','Blue','Yellow','Neutral'}})
		local Team = functions.findSetting('data','Team') or lSecession.cDefaults['Team']
		lSecession.variables['Team'] = {Team,functions.findTable({'Red','Green','Blue','Yellow','Neutral'},Team)}
		
	table.insert(menus.right.items['Customize'],{'Check Box','Allow Respawn'})
		lSecession.variables['Allow Respawn'] = {functions.findSetting('data','Allow Respawn')}
		
	table.insert(menus.right.items['Customize'],{'Number Box','Respawn Time'})
		lSecession.variables['Respawn Time'] = {functions.findSetting('data','Respawn Time') or lSecession.cDefaults['Respawn Time']}

end


