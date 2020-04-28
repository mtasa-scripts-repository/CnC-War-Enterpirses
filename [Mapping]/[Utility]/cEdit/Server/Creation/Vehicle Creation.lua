
lSecession.cDefaults.vehicle = {}


lSecession.cDefaults.vehicle['Allow Respawn'] = true
lSecession.cDefaults.vehicle['Team'] = 'Red'
lSecession.cDefaults.vehicle['Respawn Time'] = 10000 -- // 10 secounds

-- Functions --
functions.createVehicle = function (name,id,x,y,z,varient)
	local vehicle = createVehicle(id,x,y,z)
	setElementFrozen(vehicle,true)
	local id = functions.generateElementID('vehicle')
	setElementData(vehicle,'mID',id)
	setElementData(vehicle,'vVarient',varient)
	setElementData(vehicle,'eType','vehicle')
	sSecession.Elements[id] = vehicle
	functions.client(client,'setSelected',vehicle,_,true)
	functions.sendTableChanges('Elements')
	functions.sendTableChanges('Selected')
	
	for i,v in pairs(lSecession.cDefaults.vehicle) do
		setElementData(vehicle,i,v)
	end
end