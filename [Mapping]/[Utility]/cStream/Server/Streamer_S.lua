-- Events --
events = {'onPlayerLoad','onElementBreak','FailedInLoading','fetchID','prepOriginals'}
for i = 1,#events do
	addEvent( events[i], true )
end

-- Tables --
data = {assigned = {},id = {},objects = {},broken = {},alpha = {}}

-- Functions --
function PrepID(name,reload)
	if name then
		if reload then
			data.id[name] = nil
			data.id[name] = data.id[name] or getFreeID(name,data.alpha[name] and 'Alpha')
			for i,v in pairs(data.assigned[name]) do
				if isElement(i) then
					CsetElementModel(i,name)
				end
			end
		end
		data.id[name] = data.id[name] or getFreeID(name,data.alpha[name] and 'Alpha')
		idused[data.id[name]] = name
		data.assigned[name] = data.assigned[name] or {}
			
		for i,v in pairs(data.assigned[name]) do
			if isElement(i) then
				setElementModel(i,data.id[name])
			end
		end
			
		triggerClientEvent ( root, "sendID", root,name,data.id[name] )
		return data.id[name]
	end
end

function LoadingFailed(name)
	local pname = getPlayerName(client)
	--print('JStreaprintmer : '..name..' Failed For - '..pname)
end
addEventHandler( "FailedInLoading", resourceRoot, LoadingFailed) 
	
function loadObject(object,name)
	if isElement(object) then
		if data.id[name] then
			setElementModel(object,data.id[name])
			setElementData(object,'id',name)
			setElementID(object,name)	
		end
		setElementDoubleSided(object,true) 
		triggerClientEvent ( root, "LoadObject", root,object,name )
	end
end
addEventHandler( "fetchID", resourceRoot, PrepID) 
	
function loadOriginal(id)
	if idused[id] then
		if not idused[id] == 'Yes' then
			PrepID(idused[id],true)
			idused[id] = 'Yes'
		end
	end
end
addEventHandler( "prepOriginals", resourceRoot, loadOriginal)  

function CcreateObject(name,x,y,z,xr,yr,zr,resourceName,alphaA)		 
	if alphaA then
		data.alpha[name] = true
	end
	
	if tonumber(name) or getModelFromID(name) then
		loadOriginal(tonumber(name) or getModelFromID(name))
	end

	local objectid = tonumber(name) or getModelFromID(name) or PrepID(name)
			
	data.id[name] = objectid
			
	if not tonumber(objectid) then
		print('JStreamer:','Missing ID - ',name)
	end
	
	if tonumber(objectid) then
			local object = createObject(objectid,x or 0,y or 0,z or 0,xr or 0,yr or 0,zr or 0)
			
		if object then 
			loadObject(object,name)
			data.assigned[name] = data.assigned[name] or {}
			data.assigned[name][object] = true
			data.objects[resourceName or sourceResource] = data.objects[resourceName or sourceResource] or {} 
			data.objects[resourceName or sourceResource][object] = true
			return object
		end
	end
end

function CsetElementModel(element,name)	
	if tonumber(name) or getModelFromID(name) then
		loadOriginal(tonumber(name) or getModelFromID(name))
	end
			
	local currentID = getElementID(element) or getElementData(element,'data.id')
			
	if data.assigned[currentID] then
		data.assigned[currentID][element] = nil
	end
			
	data.id[name] = tonumber(name) or getModelFromID(name) or PrepID(name)	
	setElementModel(element,data.id[name])	
	data.assigned[name] = data.assigned[name] or {}
	data.assigned[name][element] = true	
	loadObject(element,name)
	return element
end

function loadOrUnloadMap()
	local dimenision = allowinteriors and 0 or nil
	if unloadMap then
		for i=550,20000 do
			removeWorldModel(i,10000,0,0,0,dimenision)
			removeWorldModel(i,10000,0,0,0,13)
		end	
		setOcclusionsEnabled(false)
		setWaterLevel ( -100000,true,false )
	else
		for i=550,20000 do
			restoreWorldModel(i,10000,0,0,0,dimenision)
			restoreWorldModel(i,10000,0,0,0,13)
		end	
		setOcclusionsEnabled(true)
		resetWaterLevel()
	end
end
loadOrUnloadMap()

function unloadModel(name)
	triggerClientEvent ( root, "unLoadObject", root,name )
end

addEventHandler ( "onResourceStop", root,
function ( resource )
	local resourceb = getResourceName(resource)
	if data.objects[resourceb] then
		for i,v in pairs(data.objects[resourceb]) do
			if isElement(i) then
				local ida = getElementID(i)
				local model = getElementModel(i)
				idused[model] = nil
				destroyElement(i)
				unloadModel(ida)
				for i,v in pairs(data) do
					for ia,va in pairs(v) do
						if (ia == model) or (ia == ida) then
							data[i][ia] = nil
						end
					end
				end
			end
		end
		data.objects[resourceb] = nil
	end
end 
)

function onElementBreak(Object)
	data.broken[Object] = true
end
addEventHandler( "onElementBreak", resourceRoot, onElementBreak) 


function resetBrokenStatus()
	data.broken[source] = nil
end
addEventHandler( "onElementStopSync", resourceRoot, resetBrokenStatus ) 
	
function isElementBroken(object)
	return data.broken[object]
end

function getResourceElements(resource)
	if data.objects[resource] then
		return data.objects[resource]
	end
end

function playerLoaded ( loadTime )
	print(getPlayerName(client),math.floor(tonumber(loadTime)/600)/100,'Minutes')
end
addEventHandler( "onPlayerLoad", resourceRoot, playerLoaded )



