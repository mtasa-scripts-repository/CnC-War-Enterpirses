-- Tables --
functions = {}
functions.save = {}
save = {}
save.Count = {}
save.settings = {}

-- Functions --

-- # .CSP VEHICLE
save.settings.vehicle = {
'Allow Respawn',
'Team',
'Respawn Time',
}

functions.round = function(input)
	return math.floor(input*100)/100
end

functions.save['vehicle'] = function (saveFolder)
	save.Count['vehicle'] = 0
	for i,v in pairs(getElementsByType('vehicle')) do
		if getElementData(v,'mID') then
			save.Count['vehicle'] = save.Count['vehicle'] + 1 
		end
	end
	if save.Count['vehicle'] > 0 then -- Only write if the vehicle count is higher then 1
		local pFile = fileCreate(':'..saveFolder..'/CSP/vehicle.CSP')
		fileWrite(pFile, '0,0,0\n')
		for i,v in pairs(getElementsByType('vehicle')) do
			if getElementData(v,'mID') then
				local name = getElementData(v,'mID')
				local id = getElementModel(v)
				local x,y,z = getElementPosition(v)
				local xr,yr,zr = getElementRotation(v)
				
				sString = ''
				for ia,va in pairs(save.settings.vehicle) do
					local value = getElementData(v,va)
					if type(value) == 'table' then
						local r,g,b = unpack(value)
						sString = sString..','..math.floor(r)..','..math.floor(g)..','..math.floor(b)
					else
						sString = sString..','..tostring(value)
					end
				end
				
				local mId = getElementData(v,'mID')
				fileWrite(pFile,mId..','..(getElementData(v,'vVarient') or ((vehicleNames[id] or {})['Default']) or name)..','..id..','..functions.round(x)..','..functions.round(y)..','..functions.round(z)..','..functions.round(xr)..','..functions.round(yr)..','..functions.round(zr)..sString..'\n')
			end
		end
		fileClose(pFile)
	else
		if fileExists(':'..saveFolder..'/CSP/vehicle.CSP') then
			fileDelete(':'..saveFolder..'/CSP/vehicle.CSP')
		end
	end 
end
-- # .CSP Light Zone
save.settings.lightZone = {
'lightColor_D',
'Day Enabled',
'lightColor_N',
'Night Enabled',
'LightSource',
'Size',
'Height M',
'Darkness M'
}


functions.save['lightZone'] = function (saveFolder)
	save.Count['lightZone'] = 0
	for i,v in pairs(getElementsByType('object')) do
		if getElementData(v,'mID') and (getElementData(v,'eType') == 'Light Zone') then
			save.Count['lightZone'] = save.Count['lightZone'] + 1 
		end
	end
	if save.Count['lightZone'] > 0 then -- Only write if the light zone count is higher then 1
		local pFile = fileCreate(':'..saveFolder..'/CSP/lightZone.CSP')
		fileWrite(pFile, '0,0,0\n')
		for i,v in pairs(getElementsByType('object')) do
			if getElementData(v,'mID') and (getElementData(v,'eType') == 'Light Zone') then
				local id = getElementData(v,'mID')
				local x,y,z = getElementPosition(v)
				
				sString = ''
				for ia,va in pairs(save.settings.lightZone) do
					local value = getElementData(v,va)
					if type(value) == 'table' then
						local r,g,b = unpack(value)
						sString = sString..','..math.floor(r)..','..math.floor(g)..','..math.floor(b)
					else
						sString = sString..','..tostring(value)
					end
				end

				fileWrite(pFile,id..','..functions.round(x)..','..functions.round(y)..','..functions.round(z)..sString..'\n')
			end
		end
		fileClose(pFile)
	else
		if fileExists(':'..saveFolder..'/CSP/lightZone.CSP') then
			fileDelete(':'..saveFolder..'/CSP/lightZone.CSP')
		end
	end 
end


-- # .CSP Light Zone
save.settings.spawnZone = {
'Allow Respawn',
'Allow Spawn',
'Team'
}

functions.save['Spawn Zones'] = function (saveFolder)
	save.Count['Spawn Zones'] = 0
	for i,v in pairs(getElementsByType('object')) do
		if getElementData(v,'mID') and (getElementData(v,'eType') == 'Spawn Point') then
			save.Count['Spawn Zones'] = save.Count['Spawn Zones'] + 1 
		end
	end
	if save.Count['Spawn Zones'] > 0 then -- Only write if the spawn count is higher then 1
		local pFile = fileCreate(':'..saveFolder..'/CSP/spawnPoints.CSP')
		fileWrite(pFile, '0,0,0\n')
		for i,v in pairs(getElementsByType('object')) do
			if getElementData(v,'mID') and (getElementData(v,'eType') == 'Spawn Point') then
				local id = getElementData(v,'mID')
				local x,y,z = getElementPosition(v)
				local _,_,zr = getElementRotation(v)
				
				sString = ''
				for ia,va in pairs(save.settings.spawnZone) do
					local value = getElementData(v,va)
					if type(value) == 'table' then
						local r,g,b = unpack(value)
						sString = sString..','..math.floor(r)..','..math.floor(g)..','..math.floor(b)
					else
						sString = sString..','..tostring(value)
					end
				end

				fileWrite(pFile,id..','..functions.round(x)..','..functions.round(y)..','..functions.round(z)..','..functions.round(zr)..sString..'\n')
			end
		end
		fileClose(pFile)
	else
		if fileExists(':'..saveFolder..'/CSP/spawnPoints.CSP') then
			fileDelete(':'..saveFolder..'/CSP/spawnPoints.CSP')
		end
	end 
end


functions.saveMap = function(mapName)
	local map = getResourceFromName ( mapName ) or createResource ( mapName )
	if map then
		for i,v in pairs(functions.save) do
			v(mapName)
		end
	end
end

functions.saveMap('SplatterFlag')