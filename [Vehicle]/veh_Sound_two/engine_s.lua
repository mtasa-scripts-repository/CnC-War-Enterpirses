ENGINE_DATA = {
	["UNSC"] = {
		["Mongoose"] = {
			idleRPM=2000,
			maxRPM=7500,
			soundPack="Mongoose",
		},
		
		["Warthog"] = {
			idleRPM=1000,
			maxRPM=7500,
			soundPack="Warthog",
		},
	}
}

-- override default engines
VEHICLE_ENGINES = {
	[573] = {"UNSC","Warthog"},
	[471] = {"UNSC","Mongoose"},
}



function addVehicleEngine(vehicle)
	if VEHICLE_ENGINES[getElementModel(vehicle)] then
		local type,data = unpack(VEHICLE_ENGINES[getElementModel(vehicle)])
		local model = getElementModel(vehicle)
		if data then 
			local engine = ENGINE_DATA[type][data]
			engine.name = data 
			engine.volMult = 1
			
			setElementData(vehicle, "vehicle:engine", engine)
			setElementData(vehicle, "vehicle:fuel_type", engine.fuel)
			
			-- refresh for players nearby
			local x, y, z = getElementPosition(vehicle)
			local col = createColSphere(x, y, z, 20)
			for k, v in ipairs(getElementsWithinColShape(col, "player")) do 
				triggerClientEvent(v, "onClientRefreshEngineSounds", v)
			end 
			destroyElement(col)
		end
	end
end 

function onResourceStart()
	for k, v in ipairs(getElementsByType("vehicle")) do 
		local type = getElementData(v, "vehicle:type")
		if not type then
			type = VEHICLE_ENGINES[getElementModel(v)]
			setElementData(v, "vehicle:type", type)
		end 
		
		addVehicleEngine(v)
	end
end 
addEventHandler("onResourceStart", resourceRoot, onResourceStart)

function onVehicleEnter(player, seat, jacked)
	if seat == 0 then 
		local type = getElementData(source, "vehicle:type")
		if not type then
			type = VEHICLE_ENGINES[getElementModel(source)]
			setElementData(source, "vehicle:type", type)
		end 
		
		addVehicleEngine(source)
	end
end
addEventHandler("onVehicleEnter", root, onVehicleEnter)
