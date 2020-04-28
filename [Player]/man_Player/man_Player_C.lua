resourceRoot = getResourceRootElement(getThisResource())
function checkTransfer()
	if isTransferBoxActive() then
		setTimer(checkTransfer,2000,1)
	else 
		triggerServerEvent ( "clientDownloaded", resourceRoot)
	end
end
addEventHandler("onClientResourceStart",resourceRoot,checkTransfer)