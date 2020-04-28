
function cameramatrix()
	local x,y,z,xa,ya,za = getCameraMatrix()
	outputChatBox(x..','..y..','..z..','..xa..','..ya..','..za)
	setClipboard(x..','..y..','..z..','..xa..','..ya..','..za)
end 

addCommandHandler('cameramatrix',cameramatrix)

for i=0,44 do
	setWorldSoundEnabled(i,-1,false,true)
end

setAmbientSoundEnabled('general',false)

setPedsLODDistance (500)
setVehiclesLODDistance(500)