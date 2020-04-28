debug.sethook(nil)

objectList = {}
resourceList = {}

addEventHandler ( "onResourceStart", root,
function ( resource )
	if getResourceInfo ( resource, 'cStream') then
		loadMap(resource)
	end
end 
)


function loadMap (resource)
	local resourceName = getResourceName(resource)
	local File = fileOpen(':'..resourceName..'/gta3.CSP')
	local Data = fileRead(File, fileGetSize(File))
	local Proccessed = split(Data,10)
	fileClose (File)

	objectList[resource] = {}

	XA,YA,ZA = 0

	for iA,vA in pairs(Proccessed) do
		if iA == 1 then
			local x,y,z = split(vA,",")[1],split(vA,",")[2],split(vA,",")[3]
			XA,YA,ZA = tonumber(x),tonumber(y),tonumber(z)
		else
			local SplitA = split(vA,",")
			if not (SplitA[1] == '!') then -- IF #1 == ! THEN IGNORE
				for i=1,9 do
					if not SplitA[i] then
						print(SplitA[1],'| CSP Error')
						return
					end
				end
					
				local object = CcreateObject(SplitA[1],tonumber(SplitA[4])+XA,tonumber(SplitA[5])+YA,tonumber(SplitA[6])+ZA,tonumber(SplitA[7]),tonumber(SplitA[8]),tonumber(SplitA[9]),resourceName,SplitA[10])
				if object then
					setElementInterior(object,tonumber(SplitA[2]))
					setElementDimension(object,tonumber(SplitA[3]))
					objectList[resource][#objectList[resource]+1] = object
				end
			end
		end
	end
	
	local File = fileOpen(':'..resourceName..'/gta3.CSD')
	local Data =  fileRead(File, fileGetSize(File))
	fileClose (File)

	triggerLatentClientEvent("CSDClientMap",5000,false,root, Data,resourceName )
	table.insert(resourceList,resourceName)
end


function getMaps()
	local list = {}
	for i,v in pairs(objectList) do
		table.insert(list,i)
	end
	return list
end


function fetchDefintions ( )
	for i,v in pairs(resourceList) do
		local File = fileOpen(':'..v..'/gta3.CSD')
		local Data =  fileRead(File, fileGetSize(File))
		fileClose (File)
	
		triggerLatentClientEvent("CSDClientMap",5000,false,client, Data,v )
	end
end

addEvent( "CSDServerMap", true )
addEventHandler( "CSDServerMap", resourceRoot, fetchDefintions )

addEventHandler ( "onResourceStop", root,
	function (resource)
		if objectList[resource] then
			for iA,vA in pairs(objectList[resource]) do
				if isElement(vA) then
					destroyElement(vA)
				end
			end
		end
		for i,v in pairs(resourceList) do
			if (v == getResourceName(resource)) then
				table.remove(resourceList,i)
			end
		end
	end
)
