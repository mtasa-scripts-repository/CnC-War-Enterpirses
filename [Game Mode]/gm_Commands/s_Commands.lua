

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

votedYes = {}

function removeVote ( text )
	Vote = nil
	triggerClientEvent ( root, "addNotification", root, 'Active vote removed.')
	votedYes = {}
end

Vote = nil

function getPercentage()
	local number = math.floor((#getElementsByType("player"))*0.65)
	return number
end

function isPlayerInACL(player, acl)
	if isElement(player) and getElementType(player) == "player" and aclGetGroup(acl or "") and not isGuestAccount(getPlayerAccount(player)) then
		local account = getPlayerAccount(player)
		
		return isObjectInACLGroup( "user.".. getAccountName(account), aclGetGroup(acl) )
	end
	return false
end

function shuffle()
	triggerClientEvent ( root, "addNotification", root, 'Shuffling Teams')
	Teams = {}
	Teams['Red'] = 0
	Teams['Blue'] = 0
	
	for i,v in pairs(getElementsByType('player')) do
		local deaths = getElementData(v,'Deaths')
		setElementData(v,'Weapon_Slot',false)
		setElementData(v,'wep.Size',false)
		if Teams['Red'] < Teams['Blue'] then
			Teams['Red'] = Teams['Red'] + 1
			setElementData(v,'Team','Red')
		else
			Teams['Blue'] = Teams['Blue'] + 1
			setElementData(v,'Team','Blue')
		end
		killPed(v)
		setElementData(v,'Deaths',deaths)
		setElementData(v,'Weapon_Slot',false)
		setElementData(v,'wep.Size',false)
	end	
end

function removeHex (s)
    if type (s) == "string" then
        while (s ~= s:gsub ("#%x%x%x%x%x%x", "")) do
            s = s:gsub ("#%x%x%x%x%x%x", "")
        end
    end
    return s or false
end

function passVote(vtype,player)
	Vote = nil
	if (vtype == 'Vote Kick') then
		if isElement(player) then
			if isPlayerInACL (player,'Admin') then
				triggerClientEvent ( root, "addNotification", root, removeHex(getPlayerName(player))..' Is staff. No votekicking...')
			else
				triggerClientEvent ( root, "addNotification", root, removeHex(getPlayerName(player)).. ' has been vote kicked.',getElementData(player,'Team'))
				kickPlayer (player,'Vote Kicked')
			end
		end
	elseif (vtype == 'Shuffle Teams') then
		shuffle()
	elseif (vtype == 'End Game') then
		triggerClientEvent ( root, "addNotification", root, 'Game Ended.')
		triggerEvent ( "gameEnd", root)
	end
end


function voteKick ( playerSource, commandName,arg )
	local player = getPlayerFromPartialName(arg)
	if player then
		if Vote then
			triggerClientEvent ( playerSource, "addNotification", playerSource, 'There is already a vote going on!')
		else
			local numberOfPlayers = getPercentage()
			Vote = {'Vote Kick',player,numberOfPlayers}
			triggerClientEvent ( root, "addNotification", root,removeHex(getPlayerName(playerSource))..' Started a votekick for '..removeHex(getPlayerName(player)).. ' '..numberOfPlayers..' player(s) need to vote yes.')
			triggerEvent ( "broadcast", root, nil,nil,removeHex(getPlayerName(playerSource))..' Started a votekick for '..removeHex(getPlayerName(player)).. ' '..numberOfPlayers..', player(s) need to vote yes for vote to pass.' )
			triggerEvent ( "broadcast", root, nil,nil,'Use /yes to vote' )
			setTimer ( removeVote, 30000, 1 )
		end
	end
end
addCommandHandler ( "votekick", voteKick,false )

function shuffleTeams ( playerSource, commandName,arg )
	if Vote then
		triggerClientEvent ( playerSource, "addNotification", playerSource, 'There is already a vote going on!')
	else
		local numberOfPlayers = getPercentage()
		Vote = {'Shuffle Teams',nil,numberOfPlayers}
		triggerClientEvent ( root, "addNotification", root,removeHex(getPlayerName(playerSource))..' started a vote to shuffle teams')
		triggerEvent ( "broadcast", root, nil,nil,removeHex(getPlayerName(playerSource))..' started a vote to shuffle teams, '..numberOfPlayers..' player(s) need to vote yes for vote to pass.' )
		triggerEvent ( "broadcast", root, nil,nil,'Use /yes to vote' )
		setTimer ( removeVote, 30000, 1 )
	end
end
addCommandHandler ( "shuffleteams", shuffleTeams,false )

function endgame ( playerSource, commandName,arg )
	if Vote then
		triggerClientEvent ( playerSource, "addNotification", playerSource, 'There is already a vote going on!')
	else
		local numberOfPlayers = getPercentage()
		Vote = {'End Game',nil,numberOfPlayers}
		triggerClientEvent ( root, "addNotification", root,getPlayerName(playerSource)..' started a vote to end the game.')
		triggerEvent ( "broadcast", root, nil,nil,removeHex(getPlayerName(playerSource))..' started a vote to end the game, '..numberOfPlayers..' player(s) need to vote yes for vote to pass.' )
		triggerEvent ( "broadcast", root, nil,nil,'Use /yes to vote' )
		setTimer ( removeVote, 30000, 1 )
	end
end
addCommandHandler ( "endgame", endgame,false )
addCommandHandler ( "endmap", endgame,false )

function checkVote()
	if Vote then
		local needed = Vote[3]
		count = 0
		for i,v in pairs(votedYes) do
			count = count + 1
		end
		triggerClientEvent ( root, "addNotification", root, count..' out of '..needed..' players needed have voted yes.')
		if count >= needed then
			local vtype,player = unpack(Vote)
			setTimer ( passVote, 1000, 1,vtype,player)
			triggerClientEvent ( root, "addNotification", root, 'Vote passed!')
		end
	end
end

function voteYes ( playerSource, commandName,arg )
	if Vote then
		if not votedYes[playerSource] then
			votedYes[playerSource] = true
			triggerClientEvent ( root, "addNotification", root, removeHex(getPlayerName(playerSource))..' voted yes.')
			checkVote()
		else
			triggerClientEvent ( playerSource, "addNotification", playerSource, 'You cannon vote twice!')
		end
	end
end
addCommandHandler ( "yes", voteYes )

function voteNo ( playerSource, commandName,arg )
	if Vote then
		if votedYes[playerSource] then
			votedYes[playerSource] = nil
			triggerClientEvent ( root, "addNotification", root, removeHex(getPlayerName(playerSource))..' revoked their vote.')
			checkVote()
		else
			triggerClientEvent ( playerSource, "addNotification", playerSource, "You haven't voted!")
		end
	end
end
addCommandHandler ( "no", voteNo )