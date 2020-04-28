

local votingList = {
{'Battle Creek','Death Match'},
{'Battle Creek','Capture the Flag'},
{'Blood Gulch','Capture the Flag'},
{'Blood Gulch','Death Match'},
}



function copyTable(tabl)
	local temp = {}
	for i,v in pairs(tabl) do
		temp[i] = v
	end
	return temp
end

function getRandom(tabl)
	local temp = {}
	local rand = math.random(1,#tabl)
	local temp = tabl[rand]
	table.remove(tabl,rand)
	return temp
end

mapList = {}
voteList = {}

function getMapList()
	mapList = {}
	voteList = {}
	local tabl = copyTable(votingList)
	local one = getRandom(tabl)
	local two = getRandom(tabl)
	local three = getRandom(tabl)
	mapList = {one,two,three,{'None',nil,0}}--
	triggerClientEvent ( root, "sendVoting", root, mapList)
	voteList = {}
	if updateVotes then
		updateVotes()
	end
	Count = 30
	triggerClientEvent ( root, "updateCountDown", root, Count)
end
getMapList()

addEvent( "gameEnd", true )
addEventHandler( "gameEnd", root, getMapList)


resourceList = {}
mapResources = {}
mapResources['Blood Gulch'] = {'BloodGulch','gm_BloodGulch','Halo_Sky'}
mapResources['Battle Creek'] = {'BattleCreek','gm_BattleCreek','sh_water','Halo_Sky'}
mapResources['Generic'] = {'man_Player','cSPLoader'}
mapSystems = {'cStream','man_Weapon','GenericObjects'}

gameModeResources = {}
gameModeResources['Death Match'] = {'gm_Deathmatch'}
gameModeResources['Capture the Flag'] = {'gm_CTF'}

for i,v in pairs(mapResources) do
	for ia,va in pairs(v) do
		table.insert(resourceList,va)
	end
end

for i,v in pairs(gameModeResources) do
	for ia,va in pairs(v) do
		table.insert(resourceList,va)
	end
end

function getVotes()
	local total = {}
	maxVote = 0
	maxium = 4
	for i,v in pairs(voteList) do
		if isElement(i) then
			total[v] = (total[v] or 0) + 1
			if total[v] > maxVote then
				maxVote = math.max(maxVote,total[v])
				maxium = v
			end
		end
	end
	return total,maxium
end


function delayStart ( maximum )
	local mapName = mapList[maximum][1]
	triggerClientEvent ( root, "addNotification", root, 'Loading Map : '..mapName)
	
	if mapResources[mapName] then
		for i,v in pairs(mapResources[mapName]) do
			local resource = getResourceFromName (v)
			startResource(resource,true)
		end
	end
	local gameModeName = mapList[maximum][2]
	triggerClientEvent ( root, "addNotification", root, 'On : '..gameModeName)
	if gameModeResources[gameModeName] then
		for i,v in pairs(gameModeResources[gameModeName]) do
			local resource = getResourceFromName (v)
			startResource(resource,true)
		end
	end
	for i,v in pairs(mapResources['Generic']) do
		local resource = getResourceFromName (v)
		startResource(resource,true)
	end
	voteList = nil
	mapList = nil
end


function indexVoting()
	local list,maximum = getVotes()
	if (maximum == 4) then
		getMapList()
	else
		Count = nil
		for i,v in pairs(getElementsByType('player')) do
			fadeCamera(v,false,0)
			killPed(v)
			setElementData(v,'weapon_Slot',false)
		end
		
		triggerClientEvent ( root, "sendVoting", root, nil)
		
		for i,v in ipairs(mapSystems) do
			local resource = getResourceFromName (v)
			restartResource(resource,true)
		end
	
		for i,v in pairs(resourceList) do
			local resource = getResourceFromName (v)
			if ( getResourceState(resource) == "running" ) and ( resource ~= getThisResource() ) then
				stopResource(resource)
			end
		end
		setTimer ( delayStart, 1000, 1,maximum)
	end
end


function updateCount()
	if mapList and voteList and Count then
		Count = Count - 1
		triggerClientEvent ( root, "updateCountDown", root, Count)
		if (Count < 1) then
			indexVoting()
		end
	end
end
setTimer ( updateCount, 1000, 0)

function receiveVote(vote)
	voteList[client] = vote
	updateVotes()
end

addEvent( "sendVote", true )
addEventHandler( "sendVote", resourceRoot, receiveVote)

function updateVotes()
	if mapList and voteList then
		triggerClientEvent ( root, "updateVotes", root, voteList)
	end
end

function fetchMapList()
	if mapList then
		triggerClientEvent ( client, "sendVoting", client, mapList)
	end
	updateVotes()
end

addEvent( "fetchMaps", true )
addEventHandler( "fetchMaps", resourceRoot, fetchMapList)
