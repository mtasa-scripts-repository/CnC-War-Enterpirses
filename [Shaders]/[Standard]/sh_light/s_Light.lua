local function getDistanceBetween3DPoints(x1,y1,z1,x2,y2,z2,height)
	return (((x2 - x1)^2) + ((y2 - y1)^2) + (((z2 - z1)/height)^2))^(1/2)
end

closestLight = {}

local function refreshVehicles()
	local eTable = {}
	for _,object in pairs(getElementsByType('object')) do
		if (getElementData(object,'eType') == 'Light Zone') then
			local x,y,z = getElementPosition(object)
			local size = tonumber(getElementData(object,'Size')) or 5
			local height = tonumber(getElementData(object,'Height M')) or 1
			local LightSource = getElementData(object,'LightSource') or 'Sun'
			for _,vehicle in pairs(getElementsByType('vehicle')) do
				closestLight[vehicle] = nil
				local xa,ya,za = getElementPosition(vehicle)
				local za = (za - 1)
				local distance = getDistanceBetween3DPoints(x,y,z,xa,ya,za,height)
				local minimal = tonumber(closestLight[vehicle]) or 100
				if ((distance) <= (size/2)) and (distance<=minimal) then
					closestLight[vehicle] = (distance+3)
					setElementData(vehicle,'lightColor_N',getElementData(object,'lightColor_N'))
					setElementData(vehicle,'lightColor_D',getElementData(object,'lightColor_D'))
					setElementData(vehicle,'Darkness M',getElementData(object,'Darkness M'))
					setElementData(vehicle,'Day Enabled',getElementData(object,'Day Enabled'))
					setElementData(vehicle,'Night Enabled',getElementData(object,'Night Enabled'))
					if LightSource == 'Sun' then
						setElementData(vehicle,'lightPos',nil)
					elseif LightSource == 'Top' then
						setElementData(vehicle,'lightPos',{x,y,z+50})
					elseif LightSource == 'Bottom' then
						setElementData(vehicle,'lightPos',{x,y,z-50})
					elseif LightSource == 'Source' then
						setElementData(vehicle,'lightPos',{x,y,z})
					end
					eTable[vehicle] = 1
				else
					eTable[vehicle] = eTable[vehicle] or 2				
				end
			end
			for _,player in pairs(getElementsByType('player')) do
				closestLight[player] = 100
				local xa,ya,za = getElementPosition(player)
				local distance = getDistanceBetween3DPoints(x,y,z,xa,ya,za,height)
				local minimal = tonumber(closestLight[player]) or 100
				if ((distance) <= (size/2)) and (distance<=minimal) then
					closestLight[player] = (distance+3)
					setElementData(player,'lightColor_N',getElementData(object,'lightColor_N'))
					setElementData(player,'lightColor_D',getElementData(object,'lightColor_D'))
					setElementData(player,'Darkness M',getElementData(object,'Darkness M'))
					setElementData(player,'Day Enabled',getElementData(object,'Day Enabled'))
					setElementData(player,'Night Enabled',getElementData(object,'Night Enabled'))
					if LightSource == 'Sun' then
						setElementData(player,'lightPos',nil)
					elseif LightSource == 'Top' then
						setElementData(player,'lightPos',{x,y,z+50})
					elseif LightSource == 'Bottom' then
						setElementData(player,'lightPos',{x,y,z-50})
					elseif LightSource == 'Source' then
						setElementData(player,'lightPos',{x,y,z})
					end
					eTable[player] = 1
				else
					eTable[player] = eTable[player] or 2				
				end
			end
			
			for _,player in pairs(getElementsByType('ped')) do
				if (not getElementData(player,'Legs')) then
					closestLight[player] = 100
					local xa,ya,za = getElementPosition(player)
					local distance = getDistanceBetween3DPoints(x,y,z,xa,ya,za,height)
					local minimal = tonumber(closestLight[player]) or 100
					if ((distance) <= (size/2)) and (distance<=minimal) then
						closestLight[player] = (distance+3)
						setElementData(player,'lightColor_N',getElementData(object,'lightColor_N'))
						setElementData(player,'lightColor_D',getElementData(object,'lightColor_D'))
						setElementData(player,'Darkness M',getElementData(object,'Darkness M'))
						setElementData(player,'Day Enabled',getElementData(object,'Day Enabled'))
						setElementData(player,'Night Enabled',getElementData(object,'Night Enabled'))
						if LightSource == 'Sun' then
							setElementData(player,'lightPos',nil)
						elseif LightSource == 'Top' then
							setElementData(player,'lightPos',{x,y,z+50})
						elseif LightSource == 'Bottom' then
							setElementData(player,'lightPos',{x,y,z-50})
						elseif LightSource == 'Source' then
							setElementData(player,'lightPos',{x,y,z})
						end
						eTable[player] = 1
					else
						eTable[player] = eTable[player] or 2				
					end
				else
					local playerE = getElementData(player,'Legs')
					if isElement(playerE) then
						setElementData(player,'lightColor_N',getElementData(playerE,'lightColor_N'))
						setElementData(player,'lightColor_D',getElementData(playerE,'lightColor_D'))
						setElementData(player,'Darkness M',getElementData(playerE,'Darkness M'))
						setElementData(player,'Day Enabled',getElementData(playerE,'Day Enabled'))
						setElementData(player,'Night Enabled',getElementData(playerE,'Night Enabled'))
						setElementData(player,'lightPos',getElementData(playerE,'lightPos'))
					end
				end
			end
		end
	end
	for i,v in pairs(eTable) do
		if v == 2 then
			removeElementData(i,'lightPos')	
			removeElementData(i,'lightColor_D')	
			removeElementData(i,'lightColor_N')	
			removeElementData(i,'Darkness M')
			removeElementData(i,'Day Enabled')		
			removeElementData(i,'Night Enabled')
			closestLight[i] = nil
		end
	end
end

setTimer ( refreshVehicles, 250, 0 )
