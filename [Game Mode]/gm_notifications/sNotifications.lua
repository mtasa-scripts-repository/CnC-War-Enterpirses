
function addNotificationS(text,index)
	print(text)
	outputConsole(index..'| '..text)
	outputServerLog(index..'| '..text)
	triggerClientEvent ( resourceRoot, "addNotification", resourceRoot, text,index)
end
