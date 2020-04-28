
function syncBullet(tabl,add,id,wType)
	local ammo = tonumber(getElementData(client,'Ammo.'..wType)) or 100

	setElementData(client,'Ammo.'..wType,ammo-1)

	
	for i,v in pairs(getElementsByType('player')) do
		local x,y,z = getElementPosition(v)
		local xa,ya,za = getElementPosition(client)
		if (getDistanceBetweenPoints3D(x,y,z,xa,ya,za) < 500) then
			tabl[15] = client
			triggerClientEvent ( v, "createBulletC", v, tabl,add,client,id )
		end
	end
end


addEvent( "createBullet", true )
addEventHandler( "createBullet", resourceRoot, syncBullet )

coolDown = {}
function delayedChat ( text )
	for i,v in pairs(coolDown) do
		coolDown[i] = coolDown[i] - 0.5
		if coolDown[i] < 0 then
			coolDown[i] = nil
		end
	end
end

setTimer ( delayedChat, 1000, 0 )

Score = {}
function getScore(Team)
	Score[Team] = 0 
	for i,v in pairs(getElementsByType('player')) do
		if getElementData(v,'Team') == Team then
			Score[Team] = Score[Team] + getElementData(v,'Score')
		end
	end
	return Score[Team]
end

function addScore(player)
	if getElementData(root,'Game Type') == 'Death Match' then
		setElementData(player,'Score',getElementData(player,'Score')+1)
		if getScore(getElementData(player,'Team')) > 50 then
			triggerEvent ( "gameEnd", root )
			triggerClientEvent ( root, "addNotification", root, getElementData(player,'Team')..' has won!','Red')
			triggerClientEvent ( root, "addNotification", root, getElementData(player,'Team')..' has won!','Blue')
		end
	end
end

function triggerDamage(elementHit,id,bone,damage,creator,wType,x,y,z)
	local damage = damage + math.random(-100,100)/10
	if (not coolDown[id]) then
	
		if wType == 'Rocket' then
			for i,v in pairs(getElementsByType('vehicle')) do	
				local xa,ya,za = getElementPosition(v)
				local distance = getDistanceBetweenPoints3D (x,y,z,xa,ya,za)
				if distance < 10 then
					local damageMultiplier = (10-distance)*30
					setElementHealth (v,getElementHealth (v)-(damageMultiplier))
					if (getElementHealth (v) < 50) then
						blowVehicle(v)
					end
				end
			end
			for i,v in pairs(getElementsByType('player')) do	
				local xa,ya,za = getElementPosition(v)
				local distance = getDistanceBetweenPoints3D (x,y,z,xa,ya,za)
				if distance < 10 then
					local damageMultiplier = (10-distance)*10
					setElementHealth (v,getElementHealth (v)-(damageMultiplier))
					setElementData(v,'Blur',math.min(math.max(getElementData(v,'Blur'),0)+damageMultiplier*1.1,50))
					setElementData(v,'Show Marker',50)
					if (getElementHealth (v) < 5) then
						killPed(v)
						if not coolDown[v] then
							coolDown[v] = 10
							addScore(creator)
							setElementData(creator,'Kills',getElementData(creator,'Kills')+1)
							setElementData(v,'Blur',math.min(math.max(getElementData(v,'Blur'),0)+30,35))
							triggerClientEvent ( root, "addNotification", root, getPlayerName(creator)..' killed '..getPlayerName(v),getElementData(v,'Team'))
						end
					end
				end
			end
		end
		
		
		coolDown[id] = 2
		if isElement(elementHit) then
			if bone and (getElementType(elementHit) == 'player') then
				if (bone == 9) then
					setElementHealth (elementHit,getElementHealth (elementHit)-(damage*1.5))
					setElementData(elementHit,'Blur',math.min(math.max(getElementData(elementHit,'Blur'),0)+damage*1.1,25))
				else
					setElementHealth (elementHit,getElementHealth (elementHit)-(damage*0.5))
					setElementData(elementHit,'Blur',math.min(math.max(getElementData(elementHit,'Blur'),0)+damage*0.3,25))
					
				end
				setElementData(elementHit,'Show Marker',50)
				
				if (getElementHealth (elementHit) < 5) then
					killPed(elementHit)
					if not coolDown[elementHit] then
						coolDown[elementHit] = 10
						addScore(creator)
						setElementData(creator,'Kills',getElementData(creator,'Kills')+1)
						setElementData(elementHit,'Blur',math.min(math.max(getElementData(elementHit,'Blur'),0)+20,25))
						triggerClientEvent ( root, "addNotification", root, getPlayerName(creator)..' killed '..getPlayerName(elementHit),getElementData(elementHit,'Team'))
					end
				end
			else
				if (getElementType(elementHit) == 'vehicle') then
					setElementHealth (elementHit,getElementHealth (elementHit)-(damage*0.1))
					for i,v in pairs(getVehicleOccupants(elementHit)) do
						if not coolDown[elementHit] then
							coolDown[elementHit] = 10
							killPed(v)
							addScore(creator)
							setElementData(creator,'Kills',getElementData(creator,'Kills')+1)
							setElementData(v,'Blur',math.min(math.max(getElementData(v,'Blur'),0)+20,25))
							triggerClientEvent ( root, "addNotification", root, getPlayerName(creator)..' killed '..getPlayerName(v),getElementData(v,'Team'))
						end
					end
				end
			end
		end
	end
end


addEvent( "triggerDamage", true )
addEventHandler( "triggerDamage", resourceRoot, triggerDamage )


