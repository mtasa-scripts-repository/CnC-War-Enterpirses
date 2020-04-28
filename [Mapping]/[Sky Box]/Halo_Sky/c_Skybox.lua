An = {}
An['Basis'] = -0.003
An['Threshold'] = 0.004
An['Space'] = -0.002
An['Clouds'] = -0.005
An['Atmosphere'] = 0

Big = {}
Big['Clouds'] = 1.9
Big['Atmosphere'] = 1.9
Big['Halo Ring'] = true
Big['SeaBed'] = true
Big['Fog_Band'] = true
Big['Water'] = 1
Big['Basis'] = 1
Big['Threshold'] = 1
Big['Space'] = 1


function run()
	for i,v in pairs(getElementsByType('object')) do
		if Big[getElementID(v)] then
			local lod = getElementData(v,'LOWLOD')
			setObjectScale(v,(tonumber(Big[getElementID(v)]) or 1.8)*6)
			
			if getElementID(v) == 'Halo Ring' then
				setObjectScale(v,(tonumber(Big[getElementID(v)]) or 1.8)*8,(tonumber(Big[getElementID(v)]) or 1.8)*6,(tonumber(Big[getElementID(v)]) or 1.8)*6)
			end
			
			if lod then
				setObjectScale(lod,(tonumber(Big[getElementID(v)]) or 1.8)*6)
				if getElementID(v) == 'Halo Ring' then
					setObjectScale(lod,(tonumber(Big[getElementID(v)]) or 1.8)*8,(tonumber(Big[getElementID(v)]) or 1.8)*6,(tonumber(Big[getElementID(v)]) or 1.8)*6)
				end
			end
		end
	end



	Animation = {}

	Clouds = -1
	for i,v in pairs(getElementsByType('object')) do
		if An[getElementID(v)] then
			table.insert(Animation,{v,An[getElementID(v)]})
			local xr,yr,zr = getElementRotation(v)
			setElementRotation(v,xr,yr,zr+math.random(1,10))
			local xra,yra,zra = getElementRotation(v)
		end
	end


	setHeatHaze(0)

	local weather = nil

	function updateCamera ()
		local hour,minute = getTime ()
		
		if hour >= 20 then
			Skyalpha = math.min(((25-hour)-(minute/60))/4,1)
		elseif hour <= 7 then
			Skyalpha = math.max(((hour-1)+(minute/60))/7,0)
		else
			Skyalpha = 1
		end
		setWeatherBlended ( 11 )
		
		local Skyalpha = math.max(Skyalpha,0.43)
		--[[
		if (hour > 18) or (hour < 6) then
			if not (weather == 17) then
			weather = 17
			setWeatherBlended ( 17 )
			end
		else 
			if not (weather == 11) then
			weather = 11
			setWeatherBlended ( 11 )
			end
		end
		]]--
		
		for i,v in pairs(Animation) do
			if isElement(v[1]) then
				local xr,yr,zr = getElementRotation(v[1])
				setElementRotation(v[1],xr,yr,zr+v[2])
				
				if getElementID(v[1]) == 'Atmosphere' then
					setElementAlpha(v[1],Skyalpha*255)
					if lod then
						setElementAlpha(lod,Skyalpha*255)
					end
				end
				
				if lod then
					setElementRotation(lod,xr,yr,zr+v[2] )
				end
			end
		end
	end
	addEventHandler ( "onClientRender", root, updateCamera )
end

setTimer ( run, 2000, 1 )
