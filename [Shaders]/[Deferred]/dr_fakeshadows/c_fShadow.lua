-- 
-- c_resource_test.lua
--

local lightMatrix = {}
local projTex = nil


special = {}
special[471] = 0.5


function isWithinDistance(element)
	local x1,y1,z1 = getElementPosition(element)
	local x2,y2,z2 = getElementPosition(localPlayer)
	
	if getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2) < 40 then
		return true
	end
end

Objects = {}

function getObject (eID)
	if Objects[eID] then
		return Objects[eID]
	else
		for i,v in pairs(getElementsByType('object')) do
			if (getElementID(v) == eID) then
				Objects[eID] = v
				return v
			end
		end
	end
end

local flag_Bottom = getObject ('Flag_Bottom')
local flag_Bottom_FP = getObject ('Flag_Bottom_FP')

addEventHandler('onClientRender', root, function()

	if dxGetStatus().UsingDepthBuffer then
		if CPrmFixZ.create() then
			CPrmFixZ.draw()
		end
	end
	
	if enabled then
		local sunX,sunY,sunZ = exports.base_env:getSunPosition ()
		
		
		for i,v in pairs(getElementsByType('vehicle',true)) do
			if isElementOnScreen(v) and isWithinDistance(v) then
				local scale = special[getElementModel(v)] or 1
				lightMatrix[v] = lightMatrix[v] or CPrmTextureProj: create(projTex, Vector3(0,0,0), 10*scale, Vector3(0,0,0), Vector2(4*scale,7*scale), Vector4(255,255,255,150), true )
				lightMatrix[v]:setAutoProjectionEnabled(true)
				lightMatrix[v]:setAutoProjectionSearchLength(10)
				local mat = v.matrix
				
				local sunX,SunY,SunZ = unpack(getElementData(v,'sunPos') or {sunX, sunY/1000, sunZ})
				local x,y,z = getElementPosition(v)
				
				local sunX,sunY,sunZ = (x-sunX)/1000,(y-sunY)/1000,(z-sunZ)/1000
				
				mat:setPosition(mat.position+Vector3(sunX,sunY,sunZ))
				lightMatrix[v]:setViewMatrix(mat)	
				lightMatrix[v]:draw()
			end
		end

		
		--CPrmTextureProj: create(projTex, Vector3(0,0,0), 15, Vector3(0,0,0), Vector2(5,5), Vector4(255,255,255,255), true )
		
		
		for i,v in pairs(getElementsByType('player',true)) do
			if isElementOnScreen(v) and isWithinDistance(v)  then
				lightMatrix[v] = lightMatrix[v] or CPrmTextureProj: create(projTex, Vector3(0,0,0), 3, Vector3(0,0,0), Vector2(5,5), Vector4(255,255,255,150), true )
				lightMatrix[v]:setAutoProjectionEnabled(true)
				lightMatrix[v]:setAutoProjectionSearchLength(5)
				local mat = v.matrix
				lightMatrix[v]:setPosition(mat.position)	
				lightMatrix[v]:setViewMatrix(mat)	
				if not getPedOccupiedVehicle(v) then
					lightMatrix[v]:draw()
				end
			end
		end
		
		
		for i,v in pairs(Objects) do
			if isElementOnScreen(v) and isWithinDistance(v)  then
				lightMatrix[v] = lightMatrix[v] or CPrmTextureProj: create(projTex, Vector3(0,0,0), 6, Vector3(0,0,0), Vector2(5,5), Vector4(255,255,255,255), true )
				lightMatrix[v]:setAutoProjectionEnabled(true)
				lightMatrix[v]:setAutoProjectionSearchLength(10)
				local mat = v.matrix
				mat:setPosition(mat.position)
				lightMatrix[v]:setViewMatrix(mat,0)	
				lightMatrix[v]:draw()
			end
		end
	end
end
)

addEventHandler("onClientElementDestroy", getRootElement(), function ()
	if enabled then
		if getElementType(source) == "vehicle" then
			if lightMatrix[source] then
				lightMatrix[source]:destroy()
			end
		end
	end
end)


function enableShader()
	if not enabled then
		enabled = true
		projTex = dxCreateTexture("test.png", "dxt3")
	end
end

function disableShader()
	if enabled then
		enabled = nil
		for i,v in pairs(lightMatrix) do
			v:destroy()
			lightMatrix[i] = nil
		end
	end
end

function changeSetting(setting)
	if setting == 'Off' then
		disableShader()
	else
		enableShader()
	end
end

addEvent ( "Shadows", true )
addEventHandler ( "Shadows", root, changeSetting )
