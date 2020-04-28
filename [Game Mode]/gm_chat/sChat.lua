
function addChat(name,text,index,tag,team)
	 triggerClientEvent ( root, "addChat", root, name,text,index,tag,team)
end


defaultCommands = {}
commands = {
'help',
'exit',
'quit',
'ver',
'time',
'showhud',
'binds',
'serial',
'connect',
'reconnect',
'bind',
'unbind',
'copygtacontrols',
'screenshot',
'saveconfig',
'cleardebug',
'chatscrollup',
'chatscrolldown',
'debugscrollup',
'debugscrolldown',
'test',
'showmemstat',
'showframegraph',
'jinglebells',
'fakelag',
'reloadnews',
'disconnect',
'shownametags',
'showchat',
'shownetstat',
'darks1d3 ',
'chatbox',
'voiceptt',
'enter_passenger',
'radio_next',
'radio_previous',
'radar',
'radar_zoom_in',
'radar_zoom_out',
'radar_move_north',
'radar_move_south',
'radar_move_east',
'radar_move_west',
'radar_attach',
'radar_opacity_down',
'radar_opacity_up',
'radar_help',
'msg_target',
'vehicle_next_weapon',
'vehicle_previous_weapon',
'sinfo ',
'textscale',
'showcol',
'showsound',
}

for i,v in pairs(commands) do
	defaultCommands[v] = true
end

function onChatMessageHandler(message, thePlayer)
	if isElement(thePlayer) then
		if getElementType(thePlayer) == 'player' then
			addChat(getPlayerName(thePlayer),message,getElementData(thePlayer,'Team'))
		end
	end
end
addEventHandler("onChatMessage", root, onChatMessageHandler)

function announce ( playerSource, commandName,...)
	local message = table.concat({...}, " ")
	
	outputServerLog('Server: '..message)
	outputConsole('Server: '..message)
			
			
	addChat(nil,message,nil)
end

addCommandHandler ( "announce", announce )
addCommandHandler ( "broadcast", announce )


addEvent ( "broadcast", true )
addEventHandler ( "broadcast", root, announce )

function string.split(str)

   if not str or type(str) ~= "string" then return false end

   local splitStr = {}
   for i=1,string.len(str) do
      local char = str:sub( i, i )
      table.insert( splitStr , char )
   end

   return splitStr 
end

function outputChat ( message,teamToggle )
	local splitup = string.split(message)
	if isElement(client) then
		if (splitup[1] == '/') then
			table.remove(splitup,1)
			local command = split ( table.concat(splitup, ""),32)
			if defaultCommands[command[1]] then
				triggerClientEvent ( client, "addNotification", client, 'You can only use MTA default commands in the "~" console!')
				return
			else
				local strin = split ( table.concat(splitup, ""),32)
				local command = strin[1]
				table.remove(strin,1)
				executeCommandHandler ( command, client, table.concat(strin, "") )
				return
			end
		else
			if (splitup[1] == '@') then
				local name = table.remove(splitup,1)
				local name = split(table.concat(splitup, ""),32)[1]
				if name then
					addChat(getPlayerName(client),message,getElementData(client,'Team'),name,teamToggle and getElementData(client,'Team'))
				end
			else
				addChat(getPlayerName(client),message,getElementData(client,'Team'),nil,teamToggle and getElementData(client,'Team'))
			end
			if teamToggle then
				outputServerLog(getElementData(client,'Team')..': '..getPlayerName(client)..': '..message)
			else
				outputServerLog('CHAT: '..getPlayerName(client)..': '..message)
			end
			if teamToggle then
				for i,v in pairs(getElementsByType('player')) do
					if getElementData(v,'Team') == getElementData(client,'Team') then
						outputConsole(getPlayerName(client)..' [Team]: '..message,v)
					end
				end
			else
				outputConsole(getPlayerName(client)..': '..message)
			end
		end
	else
		addChat(nil,message)
	end
end
addEvent( "outputChat", true )
addEventHandler( "outputChat", root, outputChat )