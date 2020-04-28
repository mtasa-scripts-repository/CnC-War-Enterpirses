-- Tables --
tabl = {}
List = {}
Teams = {}

-- Values --
setElementData(root,'Game Type','Death Match')
function getScore(Team)
	Score[Team] = 0 
	for i,v in pairs(getElementsByType('player')) do
		if getElementData(v,'Team') == Team then
			Score[Team] = Score[Team] + getElementData(v,'Score')
		end
	end
end


function died(_,killer)
	if getElementData(source,'Deaths') then
		fadeCamera (source,false,2)
		setTimer ( fadeCameraDelayed, 2000, 1, source )
		triggerClientEvent ( root, "addNotification", root, getPlayerName(source)..' died',getElementData(source,'Team'))
	end
	
	setElementData(source,'weapon_Slot',false)
	setElementData(source,'wep.Size',false)
	
	if isElement(killer) then
		if (getElementType(killer) == 'player') then
			if (not (getElementData(killer,'Team') == getElementData(source,'Team'))) then
				setElementData(killer,'Score',getElementData(killer,'Score')+1)
				if getScore(getElementData(killer,'Team')) > 50 then
					triggerEvent ( "gameEnd", root )
					triggerClientEvent ( root, "addNotification", root, getElementData(killer,'Team')..' has won!','Red')
					triggerClientEvent ( root, "addNotification", root, getElementData(killer,'Team')..' has won!','Blue')
				end
			end
			setElementData(killer,'Kills',getElementData(killer,'Kills')+1)
		elseif (getElementType(killer) == 'vehicle') then
			local occupant = getVehicleOccupant(killer)
			if occupant then
				if (not (getElementData(occupant,'Team') == getElementData(source,'Team'))) then
					setElementData(occupant,'Score',getElementData(occupant,'Score')+1)
					if getScore(getElementData(occupant,'Team')) > 50 then
						triggerEvent ( "gameEnd", root )
						triggerClientEvent ( root, "addNotification", root, getElementData(occupant,'Team')..' has won!','Red')
						triggerClientEvent ( root, "addNotification", root, getElementData(occupant,'Team')..' has won!','Blue')
					end
				end
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

function getTeamCount(Team)
	CountC = 0 
	for i,v in pairs(getElementsByType('player')) do
		if getElementData(v,'Team') == Team then
			CountC = CountC + 1
			if (Team == 'Red') then
				if (not (getAccountName(getPlayerAccount(v)) == 'CodyJ')) then
					toggleControl (v,'enter_exit',false)
					toggleControl (v,'enter_passenger',false)
				else
					toggleControl (v,'enter_exit',true)
					toggleControl (v,'enter_passenger',true)
				end
			else
				toggleControl (v,'enter_exit',true)
				toggleControl (v,'enter_passenger',true)
			end
		end
	end
	return CountC
end