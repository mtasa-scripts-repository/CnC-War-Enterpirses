--
-- c_exports.lua
--

function createPointLight(posX,posY,posZ,colorR,colorG,colorB,colorA,attenuation,...)
	local reqParam = {posX,posY,posZ,colorR,colorG,colorB,colorA,attenuation}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param~=nil and (type(param) == "number")
	end
	local optParam = {...}
	if not isThisValid or (#optParam > 2 or #reqParam ~= 8 ) or (countParam ~= 8) then 
		return false 
	end
	if (type(optParam[1]) ~= "number") then
		optParam[1] = -1
	end
	if (type(optParam[2]) ~= "number") then
		optParam[2] = -1
	end
	local lightDimension = optParam[1]
	local lightInterior = optParam[2]
	local lightElementID = funcTable.create(1,posX,posY,posZ,colorR,colorG,colorB,colorA,0,0,-1,0,0,0,attenuation
		,lightDimension,lightInterior)
	local lightElement = createElement("LightSource", tostring(lightElementID))
	return lightElement
end

function createSpotLight(posX,posY,posZ,colorR,colorG,colorB,colorA,dirX,dirY,dirZ,falloff,theta,phi,attenuation,...)
	local reqParam = {posX,posY,posZ,colorR,colorG,colorB,colorA,dirX,dirY,dirZ,falloff,theta,phi,attenuation}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param~=nil and (type(param) == "number")
	end
	local optParam = {...}
	if not isThisValid or (#optParam > 3 or #reqParam ~= 14 ) or (countParam ~= 14) then
		return false 
	end
	if (type(optParam[1]) ~= "number") then
		optParam[1] = -1
	end
	if (type(optParam[2]) ~= "number") then
		optParam[2] = -1
	end
	local lightDimension = optParam[2]
	local lightInterior = optParam[3]
	local lightElementID = funcTable.create(2,posX,posY,posZ,colorR,colorG,colorB,colorA,dirX,dirY,dirZ,falloff,theta,phi,attenuation
			,lightDimension,lightInterior)
	local lightElement = createElement("LightSource", tostring(lightElementID))
	return lightElement
end

function destroyLight(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if type(lightElementID) == "number" then
		return destroyElement(w) and funcTable.destroy(lightElementID)
	else
		return false
	end
end

function setLightDimension(w,dimension)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(dimension) == "number") then 
		lightTable.inputLights[lightElementID].dimension = dimension
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightDimension(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return lightTable.inputLights[lightElementID].dimension
		else
			return false
		end
	else
		return false
	end
end

function setLightInterior(w,interior)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(interior) == "number") then 
		lightTable.inputLights[lightElementID].interior = interior
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightInterior(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return lightTable.inputLights[lightElementID].interior
		else
			return false
		end
	else
		return false
	end
end

function setLightDirection(w,dirX,dirY,dirZ)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	local reqParam = {lightElementID,dirX,dirY,dirZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if lightTable.inputLights[lightElementID] and isThisValid then
		if (lightTable.inputLights[lightElementID].lType == 2) and (countParam == 4) then
			lightTable.inputLights[lightElementID].dir = {dirX,dirY,dirZ}
			lightTable.entity[lightElementID]:setDirection(Vector3(dirX,dirY,dirZ))
			lightTable.isInValChanged = true
			return true
		else
			return false
		end
	else
		return false
	end
end

function getLightDirection(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].lType == 2) and (lightTable.inputLights[lightElementID].enabled == true) then
			return unpack(lightTable.inputLights[lightElementID].dir)
		else
			return false
		end
	else
		return false
	end
end

function setLightRotation(w,rotX,rotY,rotZ)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	local reqParam = {lightElementID,rotX,rotY,rotZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if lightTable.inputLights[lightElementID] and isThisValid then
		if (lightTable.inputLights[lightElementID].lType == 2) and (countParam == 4) then
			local rx, rz = math.rad(rotX), math.rad(rotZ)
			local dirX, dirY, dirZ = -math.cos(rx) * math.sin(rz), math.cos(rz) * math.cos(rx), math.sin(rx)
			lightTable.inputLights[lightElementID].dir = {dirX, dirY, dirZ}
			lightTable.entity[lightElementID]:setDirection(Vector3(dirX,dirY,dirZ))
			lightTable.isInValChanged = true
			return true
		else
			return false
		end
	else
		return false
	end
end

function getLightRotation(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].lType == 2) and (lightTable.inputLights[lightElementID].enabled == true) then
			local vx, vy, vz = unpack(inputLights[lightElementID].dir)
			local len = math.sqrt(vx * vx + vy * vy + vz * vz)
			return math.deg(math.asin(vz / len)), 0, -math.deg(math.atan2(vx, vy))
		else
			return false
		end
	else
		return false
	end
end

function setLightPosition(w,posX,posY,posZ)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	local reqParam = {lightElementID,posX,posY,posZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if lightTable.inputLights[lightElementID] and isThisValid  and (countParam == 4) then
		lightTable.inputLights[lightElementID].pos = {posX,posY,posZ}
		lightTable.entity[lightElementID]:setPosition(Vector3(posX,posY,posZ))
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightPosition(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return unpack(lightTable.inputLights[lightElementID].pos)
		else
			return false
		end
	else
		return false
	end
end

function setLightColor(w,colorR,colorG,colorB,colorA)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	local reqParam = {lightElementID,colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if lightTable.inputLights[lightElementID] and isThisValid  and (countParam == 5)  then
		lightTable.inputLights[lightElementID].color = {colorR,colorG,colorB,colorA}
		lightTable.entity[lightElementID]:setColor(Vector4(colorR,colorG,colorB,colorA))		
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightColor(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return unpack(lightTable.inputLights[lightElementID].color)
		else
			return false
		end
	else
		return false
	end
end

function setLightAttenuation(w,attenuation)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(attenuation) == "number") then 
		lightTable.inputLights[lightElementID].attenuation = attenuation
		lightTable.entity[lightElementID]:setAttenuation(attenuation)
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightAttenuation(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return lightTable.inputLights[lightElementID].attenuation
		else
			return false
		end
	else
		return false
	end
end

function setLightAttenuationPower(w,attenuationPower)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(attenuationPower) == "number") then 
		lightTable.inputLights[lightElementID].attenuationPower = attenuationPower
		lightTable.entity[lightElementID]:setAttenuationPower(attenuationPower)
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightAttenuationPower(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return lightTable.inputLights[lightElementID].attenuationPower
		else
			return false
		end
	else
		return false
	end
end	
		
function setLightFalloff(w,falloff)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and type(falloff) == "number" then	
		if (lightTable.inputLights[lightElementID].lType == 2) then	
			lightTable.inputLights[lightElementID].falloff = falloff
			lightTable.entity[lightElementID]:setFalloff( falloff )
			lightTable.isInValChanged = true
			return true
		else
			return false
		end
	else
		return false
	end
end

function getLightFalloff(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) and (lightTable.inputLights[lightElementID].lType == 2) then
			return lightTable.inputLights[lightElementID].falloff
		else
			return false
		end
	else
		return false
	end
end

function setLightTheta(w,theta)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(theta) == "number") then 
		if (lightTable.inputLights[lightElementID].lType == 2) then 
			lightTable.inputLights[lightElementID].theta = theta
			lightTable.entity[lightElementID]:setTheta( theta )
			lightTable.isInValChanged = true
			return true
		else
			return false
		end
	else
		return false
	end
end

function getLightTheta(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) and (lightTable.inputLights[lightElementID].lType == 2) then
			return lightTable.inputLights[lightElementID].theta
		else
			return false
		end
	else
		return false
	end
end

function setLightPhi(w,phi)
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(phi) == "number") then 
		if (lightTable.inputLights[lightElementID].lType == 2) then 
			lightTable.inputLights[lightElementID].phi = phi
			lightTable.entity[lightElementID]:setPhi( phi )
			lightTable.isInValChanged = true
			return true
		else
			return false
		end
	else
		return false
	end
end	

function getLightPhi(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) and (lightTable.inputLights[lightElementID].lType == 2) then
			return lightTable.inputLights[lightElementID].phi
		else
			return false
		end
	else
		return false
	end
end
