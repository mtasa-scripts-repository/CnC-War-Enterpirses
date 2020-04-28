
vehicleStuff = {
{'Allow Respawn',1},
{'Team',1},
{'Respawn Time',1},
}

altFunt.Vehicles = function(resourceName)
	if fileExists(':'..resourceName..'/CSP/vehicle.CSP') then
		local File = fileOpen(':'..resourceName..'/CSP/vehicle.CSP')
		local Data = fileRead(File, fileGetSize(File))
		local Proccessed = split(Data,10)
		fileClose (File)

		ItemList[resourceName] = ItemList[resourceName] or {}

		XA,YA,ZA = 0

		for iA,vA in pairs(Proccessed) do
			if iA == 1 then
				local x,y,z = split(vA,",")[1],split(vA,",")[2],split(vA,",")[3]
				XA,YA,ZA = tonumber(x),tonumber(y),tonumber(z)
			else
				local SplitA = split(vA,",")
				if not (SplitA[1] == '!') then
					for i=1,10 do
						if not SplitA[i] then
							print(SplitA[1],'| CSP Error')
							return
						end
					end
						
					local vehicle = createVehicle(SplitA[3],tonumber(SplitA[4])+XA,tonumber(SplitA[5])+YA,tonumber(SplitA[6])+ZA,tonumber(SplitA[7]),tonumber(SplitA[8]),tonumber(SplitA[9]),resourceName)
					
					count = 9
					for i,v in pairs(vehicleStuff) do
						if v[2] == 3 then
							count = count + 1
							local r = SplitA[count]
							count = count + 1
							local g = SplitA[count]
							count = count + 1
							local b = SplitA[count]
							setElementData(vehicle,v[1],{r,g,b})
						else
							count = count + 1
							local data = SplitA[count]
							setElementData(vehicle,v[1],data)
						end
					end
					setElementData(vehicle,'eType','vehicle')
					setElementData(vehicle,'mID',SplitA[1])
					setElementData(vehicle,'vVarient',SplitA[2])
					
					toggleVehicleRespawn (vehicle, toBoolen(getElementData(vehicle,'Allow Respawn')))
					setVehicleRespawnDelay(vehicle, tonumber(getElementData(vehicle,'Respawn Time')))
	
					if vehicle then
						table.insert(ItemList[resourceName],vehicle)
						table.insert(Items,vehicle)
					end
				end
			end
		end
	end
end

