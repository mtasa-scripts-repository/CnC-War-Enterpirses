spawnA = {{0,0,325,0}}

function indexSpawnZones(team)
	local tabl = {}
	for i,v in pairs(getElementsByType('object')) do
		if getElementData(v,'eType') == 'Spawn Point' then
			if ((getElementData(v,'Team') == team) or (getElementData(v,'Team') == 'Neutral') or (not team)) and getElementData(v,'Allow Spawn') then
				local x,y,z = getElementPosition(v)
				local _,_,zr = getElementRotation(v)
				table.insert(tabl,{x+math.random(-2,2),y+math.random(-2,2),z+1.5,zr+90})
			end
		end
	end
	if #tabl > 0 then
		return tabl
	else
		return spawnA
	end
end

presets = {'Kills','Deaths','Score','Captures'}
teams = {'Red','Blue','Green','Yellow'}
teamCount = 2

function getTeam()
	local minimal = {100,'Blue'}
	local counts = {}
	for i,v in pairs(teams) do
		if (i <= (getElementData(root,'Team_Count') or teamCount)) then
			counts[v] = 0
			for ia,va in pairs(getElementsByType('player')) do
				if getElementData(va,'Team') == v then
					counts[v] = counts[v] + 1
				end
			end
			if counts[v] < minimal[1] then
				minimal = {counts[v],v}
			end
		end
	end
	return minimal[2]
end

iprint(getTeam())


setTimer(function()
for i,v in pairs(getElementsByType('player')) do
	local x,y,z = getElementPosition(v)
	if z < 0 then
		if not getElementData(root,'mapEditor') then
			killPed(v)
		end
		if not getElementData(root,'mapEditor') then

		end
	end
end

for i,v in pairs(getElementsByType('vehicle')) do
	local x,y,z = getElementPosition(v)
	if z < 0 then
		blowVehicle(v)
	end
end

end, 1000, 0)

setTimer(function()

for i,v in pairs(getElementsByType('player')) do
	setElementData(v,'Ping',getPlayerPing(v))
end

end, 500, 0)
	
function fade()
	triggerClientEvent ( root, "addNotification", root, getPlayerName(source)..' Connected')
	if not getElementData(root,'mapEditor') then
		fadeCamera(source,false,0)
	end
end

proccessed = {}

function spawnB ( )
	if not getElementData(client,'Team') then
		setElementData(client,'Team',getTeam())
	end
	
	triggerEvent ( "onPlayerLoadS", root, client )
	setTimer(function(player)
		if not getElementData(root,'mapEditor') then
			--fadeCamera(player,false,1)
		end
		setTimer(function(player)
			proccessed[player] = true
				setPlayerHudComponentVisible(player,'all',false)

			setCameraTarget(player,player)
			
			
			local spawns = indexSpawnZones(getElementData(player,'Team'))
			local spawn = spawns[math.random(1,#spawns)]
			spawnPlayer(player,unpack(spawn))
			setElementRotation(player,0,0,spawn[4])
			
			for i,v in pairs(presets) do
				setElementData(player,v,0)
			end
			
			setElementModel(player,math.random(22,29))
			if not getElementData(root,'mapEditor') then
				fadeCamera(player,true,1)
			end
			setElementData(player,'Fade',nil)
			triggerClientEvent ( root, "addNotification", root, getPlayerName(player)..' Spawned.')
		end, 1000, 1,player)
	end, 8000, 1,client)
end

addEvent ( "onPlayerLoadS", true )


addEvent( "clientDownloaded", true )
addEventHandler( "clientDownloaded", resourceRoot, spawnB ) 


function indexRespawnZones(team)
	local tabl = {}
	for i,v in pairs(getElementsByType('object')) do
		if getElementData(v,'eType') == 'Spawn Point' then
			if ((getElementData(v,'Team') == team) or (getElementData(v,'Team') == 'Neutral') or (not team)) and getElementData(v,'Allow Respawn') then
				local x,y,z = getElementPosition(v)
				local _,_,zr = getElementRotation(v)
				table.insert(tabl,{x+math.random(-2,2),y+math.random(-2,2),z+1.5,zr+90})
			end
		end
	end
	if #tabl > 0 then
		return tabl
	else
		return spawnA
	end
end


function death ( )
	if proccessed[source] then
	setTimer(function(player)
		if not getElementData(root,'mapEditor') then
			if isElement(player) then
				fadeCamera(player,false,1)
			end
		end
		setTimer(function(player)
			if isElement(player) then
				setPlayerHudComponentVisible(player,'all',false)
				local model = getElementModel(player)
				setCameraTarget(player,player)
				local spawns = indexRespawnZones(getElementData(player,'Team'))
				local spawn = spawns[math.random(1,#spawns)]
				spawnPlayer(player,unpack(spawn))
				setElementRotation(player,0,0,spawn[4])
				setElementModel(player,model)
				if not getElementData(root,'mapEditor') then
					fadeCamera(player,true,1)
				end
				setElementData(player,'Fade',false)
			end
		end, 1000, 1,player)
	end, 10000, 1,source)
	end
end

addEventHandler ( "onPlayerJoin", getRootElement(), fade )
addEventHandler ( "onPlayerWasted", getRootElement(), death )