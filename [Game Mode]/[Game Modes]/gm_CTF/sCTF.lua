function start()
	-- Tables --
	tabl = {}
	List = {}
	Teams = {}
	Timer = {}

	coolDown = {}
	flagBarrer = {}
	flag = {}

	setElementData(root,'Game Type','Capture The Flag')

	function getOtherTeam(player)
		local team = getElementData(player,'Team')
		if (team == 'Blue') then
			return 'Red'
		else
			return 'Blue'
		end
	end
		
	-- Values --
	function quitPlayer ( )
		if (flagBarrer[getOtherTeam(source)] == source) then
			dropFlag (source)
		end
		triggerClientEvent ( root, "addNotification", root, getPlayerName(source)..' Quit',getElementData(source,'Team'))
	end
	addEventHandler ( "onPlayerQuit", root, quitPlayer )


	function prepVehicle ( thePlayer, seat, jacked )
		setVehicleHandling(source,'collisionDamageMultiplier',200)
	end
	addEventHandler ( "onVehicleEnter", getRootElement(), prepVehicle )

	function died(_,killer)
		if getElementData(source,'Deaths') then
			fadeCamera (source,false,2)
			setTimer ( fadeCameraDelayed, 2000, 1, source )
			triggerClientEvent ( root, "addNotification", root, getPlayerName(source)..' died',getElementData(source,'Team'))
		end
		
		setElementData(source,'weapon_Slot',false)
		setElementData(source,'wep.Size',false)
				
		
		if (flagBarrer[getOtherTeam(source)] == source) then
			dropFlag (source)
		end
			
		if isElement(killer) then
			if (getElementType(killer) == 'player') then
				setElementData(killer,'Kills',getElementData(killer,'Kills')+1)
			elseif (getElementType(killer) == 'vehicle') then
				local occupant = getVehicleOccupant(killer)
				if occupant then
					setElementData(occupant,'Kills',getElementData(occupant,'Kills')+1)
				end
			end
		end
	end
	addEventHandler("onPlayerWasted", root, died) 

	function fadeCameraDelayed(player)
		fadeCamera (player,true,2)
		setElementData(player,'Deaths',getElementData(player,'Deaths')+1)
		setElementData(player,'Fade',700)
	end

	function onPlayerLoad(player)
		fadeCamera (player,false,2)
		setTimer ( onPlayerLoadDelayed, 2000, 1, player )
	end

	function getObjective(oType,ID,Team)
		for i,v in pairs(getElementsByType('object')) do
			if (getElementData(v,'eType') == 'Objective') then
				if (getElementData(v,'Obj Type') == oType) and (getElementData(v,'Team') == Team) and (getElementData(v,'Obj ID') == ID) then
					local x,y,z = getElementPosition(v)
					return x,y,z,v
				end
			end
		end
	end


	OnBase = {}
	Home = {}
	local _,_,_,obj = getObjective('Flag Spawn',1,'Blue')
	setElementData(obj,'Holder',nil) 
	flag['Blue'] = obj

	local _,_,_,obj = getObjective('Flag Spawn',1,'Red')
	setElementData(obj,'Holder',nil) 
	flag['Red'] = obj
	Home['Red'] = true
	Home['Blue'] = true

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


	function pointChecker ( )
		
		
		for i,v in pairs(getElementsByType('player')) do
			if coolDown[v] then
				coolDown[v] = coolDown[v] - 1
				if coolDown[v] < 0 then
					coolDown[v] = nil
				end
			end
			
			local x,y,z = getElementPosition(v)

			local xa,ya,za,element = getObjective('Flag Spawn',1,(getElementData(v,'Team') == 'Blue') and 'Red' or 'Blue')
			if xa then
				if (getDistanceBetweenPoints3D(x,y,z,xa,ya,za) < 2) then
					if not flagBarrer[getOtherTeam(v)] then
						if (getElementHealth ( v ) > 5) and (not coolDown[v]) then 
							setElementData(v,'Flag',true)
							if getElementData(v,'pickup') then
								flagBarrer[getOtherTeam(v)] = v
								setElementData(element,'Holder',v)
								triggerClientEvent ( root, "addNotification", root, ((getElementData(v,'Team') == 'Blue') and 'Red' or 'Blue')..' Flag Picked up by '..getPlayerName(v)..'.',getElementData(v,'Team'))
								if isElement(Timer[getElementData(v,'Team')]) then
									killTimer(Timer[getElementData(v,'Team')])
								end
								Home[((getElementData(v,'Team') == 'Blue') and 'Red' or 'Blue')] = false
							end
						else
							setElementData(v,'Flag',nil)
						 end
					else
						setElementData(v,'Flag',nil)
					end
				else
					setElementData(v,'Flag',nil)
				end
			end
			
			local xa,ya,za,elementb = getObjective('Flag Capture',1,getElementData(v,'Team'))
			if xa then
				if (getDistanceBetweenPoints3D(x,y,z,xa,ya,za) < 3) then
					if (flagBarrer[getOtherTeam(v)] == v) then
						if not Home[getElementData(v,'Team')] then
							if not OnBase[v] then
								OnBase[v] = true
								triggerClientEvent ( root, "addNotification", root, 'Your flag must be at home to score!',getElementData(v,'Team'))
							end
						else
							setElementData(v,'Score',getElementData(v,'Score')+10)
							setElementData(v,'Captures',(getElementData(v,'Captures') or 0)+1)
							triggerClientEvent ( root, "addNotification", root, getPlayerName(v)..' scored for '..getElementData(v,'Team')..' Team.',getElementData(v,'Team'))
							flagBarrer[(getElementData(v,'Team') == 'Blue') and 'Red' or 'Blue'] = nil
							resetFlag((getElementData(v,'Team') == 'Blue') and 'Red' or 'Blue')	
							
							if getScore(getElementData(v,'Team')) > 50 then
								triggerEvent ( "gameEnd", root )
								triggerClientEvent ( root, "addNotification", root, getElementData(v,'Team')..' has won!','Red')
								triggerClientEvent ( root, "addNotification", root, getElementData(v,'Team')..' has won!','Blue')
							end
						end
					end
				else
					OnBase[v] = nil
				end
			end
		end
	end
	setTimer ( pointChecker, 50, 0)

	function resetFlag (Team)
		if (not isElement(flagBarrer[Team])) then
			local _,_,_,element = getObjective('Flag Spawn',1,Team)
			local x = getElementData(element,'x')
			local y = getElementData(element,'y')
			local z = getElementData(element,'z')
			
			setElementData(element,'Holder',nil) 
			flagBarrer[Team] = nil
			setElementPosition(element,x,y,z)
			triggerClientEvent ( root, "addNotification", root, Team..' Flag Respawned',Team)
			Home[Team] = true
			if not isTimer(Timer[((Team == 'Blue') and 'Red' or 'Blue')]) then
				Timer[((Team == 'Blue') and 'Red' or 'Blue')] = setTimer ( resetFlag2, 120000, 1,Team)
			end
		end
	end

	function resetFlag2 (Team)
		if (not isElement(flagBarrer[Team])) then
			local _,_,_,element = getObjective('Flag Spawn',1,Team)
			local x = getElementData(element,'x')
			local y = getElementData(element,'y')
			local z = getElementData(element,'z')
			
			setElementData(element,'Holder',nil) 
			flagBarrer[Team] = nil
			setElementPosition(element,x,y,z)
			Home[Team] = true
			if not isTimer(Timer[((Team == 'Blue') and 'Red' or 'Blue')]) then
				Timer[((Team == 'Blue') and 'Red' or 'Blue')] = setTimer ( resetFlag2, 120000, 1,Team)
			end
		end
	end

	function resetFlag3 (player)
		resetFlag ('Blue')
		resetFlag ('Red')
	end
	addCommandHandler ( "resetFlag", resetFlag3 )

	function dropFlag (v)
		local _,_,_,element = getObjective('Flag Spawn',1,((getElementData(v,'Team') == 'Blue') and 'Red' or 'Blue'))
		
		local x,y,z = getElementPosition(v)
		setElementPosition(element,x,y,z)
		
		setElementData(element,'Holder',nil) 
		flagBarrer[getOtherTeam(v)] = nil

		triggerClientEvent ( root, "addNotification", root, ((getElementData(v,'Team') == 'Blue') and 'Red' or 'Blue')..' Flag Dropped',(getElementData(v,'Team')))
		
		if isTimer(Timer[getElementData(v,'Team')]) then
			killTimer(Timer[getElementData(v,'Team')])
		end
		
		Timer[getElementData(v,'Team')] = setTimer ( resetFlag, 55000, 1, ((getElementData(v,'Team') == 'Blue') and 'Red' or 'Blue'))
	end
	addCommandHandler ( "dropFlag", dropFlag )

	function shuffleTeams()
		triggerClientEvent ( root, "addNotification", root, 'Shuffling Teams')
		Teams = {}
		Teams['Red'] = 0
		Teams['Blue'] = 0
		
		for i,v in pairs(getElementsByType('player')) do
			if Teams['Red'] < Teams['Blue'] then
				Teams['Red'] = Teams['Red'] + 1
				setElementData(v,'Team','Red')
			else
				Teams['Blue'] = Teams['Blue'] + 1
				setElementData(v,'Team','Blue')
			end
			killPed(v)
			setElementData(v,'Deaths',getElementData(v,'Deaths')-1)
		end	
	end
	addCommandHandler ( "shuffleTeams_C", shuffleTeams )


	function swapTeams ( playerSource, commandName )
		triggerClientEvent ( root, "addNotification", root, 'Swapping Teams')
		for i,v in pairs(getElementsByType('player')) do
			local team = getElementData(v,'Team')
			if team == 'Red' then
				setElementData(v,'Team','Blue')
			else
				setElementData(v,'Team','Red')
			end
			killPed(v)
			setElementData(v,'Deaths',getElementData(v,'Deaths')-1)
		end
	end
	addCommandHandler ( "swapTeams_C", swapTeams )
	
setTimer ( resetFlag, 2000, 1,'Red')
setTimer ( resetFlag, 2000, 1,'Blue')
end
setTimer ( start, 2000, 1)
