-- 
-- c_common.lua
--

---------------------------------------------------------------------------------------------------
-- dxGetStatus
---------------------------------------------------------------------------------------------------
isSM3DBSupported = (tonumber(dxGetStatus().VideoCardPSVersion) > 2) and (tostring(dxGetStatus().DepthBufferFormat) ~= "unknown")

isSm3MrtDBSupported = (tonumber(dxGetStatus().VideoCardPSVersion) > 2) and (tonumber(dxGetStatus().VideoCardNumRenderTargets) > 1) and 
		(tostring(dxGetStatus().DepthBufferFormat) ~= "unknown") 
		
---------------------------------------------------------------------------------------------------
-- global settings
---------------------------------------------------------------------------------------------------
tesselationSwitchDelta = 2500

---------------------------------------------------------------------------------------------------
-- getRenderTargets
---------------------------------------------------------------------------------------------------
renderTarget = {RTColor = nil, RTNormal = nil, isOn = false, distFade = {100, 80}}
local rtResource = exports.dr_renderTarget
local rtResourceName = "dr_renderTarget"
local scx, scy = guiGetScreenSize ()

---------------------------------------------------------------------------------------------------
-- onClientResourceStart/Stop
---------------------------------------------------------------------------------------------------
addEventHandler ( "onClientResourceStart", root, function(startedRes)
	if getResourceName(startedRes) == rtResourceName then
		renderTarget.isOn = getElementData ( localPlayer, "dr_renderTarget.on", false )
		if renderTarget.isOn then
			renderTarget.RTColor, _, renderTarget.RTNormal = rtResource:getRenderTargets()
			renderTarget.distFade[1], renderTarget.distFade[2] = rtResource:getShaderDistanceFade()
			return 
		end
		if renderTarget.RTColor and renderTarget.RTNormal then
			renderTarget.isOn = true
		end
	end
end
)

addEventHandler ( "onClientResourceStop", root, function(startedRes)
	if not renderTarget.isOn then return end
	if getResourceName(startedRes) == rtResourceName then
		if renderTarget.isOn then
			renderTarget.isOn = false
		end
	end
end
)

addEventHandler ( "onClientResourceStart", resourceRoot, function()
	renderTarget.isOn = getElementData ( localPlayer, "dr_renderTarget.on", false )
	if renderTarget.isOn then 
		renderTarget.RTColor, renderTarget.RTDepth, renderTarget.RTNormal = rtResource:getRenderTargets()
		renderTarget.distFade[1], renderTarget.distFade[2] = rtResource:getShaderDistanceFade()
		if renderTarget.RTColor and renderTarget.RTDepth and renderTarget.RTNormal then
			renderTarget.isOn = true
		end
	end
end
)

---------------------------------------------------------------------------------------------------
-- prevent memory leaks
---------------------------------------------------------------------------------------------------
addEventHandler( "onClientResourceStart", resourceRoot, function()
	collectgarbage( "setpause", 100 )
end
)

---------------------------------------------------------------------------------------------------
-- matrix helper functions
---------------------------------------------------------------------------------------------------
function Matrix:getRotationZXY()
	local nz1, nz2, nz3
	local matRt = self.right
	local matFw = self.forward
	local matUp = self.up
	nz3 = math.sqrt(matFw.x * matFw.x + matFw.y * matFw.y)
	nz1 = -matFw.x * matFw.z / nz3
	nz2 = -matFw.y * matFw.z / nz3
	local vx = nz1 * matRt.x + nz2 * matRt.y + nz3 * matRt.z
	local vz = nz1 * matUp.x + nz2 * matUp.y + nz3 * matUp.z
	return Vector3(math.deg(math.asin(matFw.z) ), -math.deg(math.atan2(vx, vz) ), -math.deg(math.atan2(matFw.x, matFw.y)))
end
		
function Matrix:setRotationZXY( rotDeg )
	local rot = Vector3(math.rad(rotDeg.x), math.rad(rotDeg.y), math.rad(rotDeg.z))
	self.right = Vector3(math.cos(rot.z) * math.cos(rot.y) - math.sin(rot.z) * math.sin(rot.x) * math.sin(rot.y), 
                math.cos(rot.y) * math.sin(rot.z) + math.cos(rot.z) * math.sin(rot.x) * math.sin(rot.y), -math.cos(rot.x) * math.sin(rot.y))
	self.forward =Vector3(-math.cos(rot.x) * math.sin(rot.z), math.cos(rot.z) * math.cos(rot.x), math.sin(rot.x))
	self.up = Vector3(math.cos(rot.z) * math.sin(rot.y) + math.cos(rot.y) * math.sin(rot.z) * math.sin(rot.x), math.sin(rot.z) * math.sin(rot.y) - 
                math.cos(rot.z) * math.cos(rot.y) * math.sin(rot.x), math.cos(rot.x) * math.cos(rot.y))
	return true
end

function Matrix:transformRotationZXY( rotDeg, offset )
	local rot = Vector3(math.rad(rotDeg.x), math.rad(rotDeg.y), math.rad(rotDeg.z))
	local mat1 = {}
	mat1[1] = {math.cos(rot.z) * math.cos(rot.y) - math.sin(rot.z) * math.sin(rot.x) * math.sin(rot.y), 
                math.cos(rot.y) * math.sin(rot.z) + math.cos(rot.z) * math.sin(rot.x) * math.sin(rot.y), -math.cos(rot.x) * math.sin(rot.y)}
	mat1[2] = {-math.cos(rot.x) * math.sin(rot.z), math.cos(rot.z) * math.cos(rot.x), math.sin(rot.x)}
	mat1[3] = {math.cos(rot.z) * math.sin(rot.y) + math.cos(rot.y) * math.sin(rot.z) * math.sin(rot.x), math.sin(rot.z) * math.sin(rot.y) - 
                math.cos(rot.z) * math.cos(rot.y) * math.sin(rot.x), math.cos(rot.x) * math.cos(rot.y)}

	local mat2 = {}
	mat2[1] = {self.right.x, self.right.y, self.right.z}
	mat2[2] = {self.forward.x, self.forward.y, self.forward.z}
	mat2[3] = {self.up.x, self.up.y, self.up.z}
	
	-- multiply rotation matrices
	local matOut = {}
	for i = 1,#mat1 do
		matOut[i] = {}
		for j = 1,#mat2[1] do
			local num = mat1[i][1] * mat2[1][j]
			for n = 2,#mat1[1] do
				num = num + mat1[i][n] * mat2[n][j]
			end
			matOut[i][j] = num
		end
	end

	-- get ZXY rotation
	local nz1, nz2, nz3
	nz3 = math.sqrt(matOut[2][1] * matOut[2][1] + matOut[2][2] * matOut[2][2])
	nz1 = -matOut[2][1] * matOut[2][3] / nz3
	nz2 = -matOut[2][2] * matOut[2][3] / nz3
	local vx = nz1 * matOut[1][1] + nz2 * matOut[1][2] + nz3 * matOut[1][3]
	local vz = nz1 * matOut[3][1] + nz2 * matOut[3][2] + nz3 * matOut[3][3]	
	
	local rotationOut = Vector3(math.deg(math.asin(matOut[2][3]) ), -math.deg(math.atan2(vx, vz) ), 
			-math.deg(math.atan2(matOut[2][1], matOut[2][2])))
	
	-- get position
	local positionOut = Vector3(offset:dot(Vector3(matOut[1][1], matOut[2][1], matOut[3][1])),
			offset:dot(Vector3(matOut[1][2], matOut[2][2], matOut[3][2])),
			offset:dot(Vector3(matOut[1][3], matOut[2][3], matOut[3][3]))) + self.position
	
	return rotationOut, positionOut
end

function getForwardFromRotationZXY( rotDeg )
	local rot = Vector3(math.rad(rotDeg.x), math.rad(rotDeg.y), math.rad(rotDeg.z))
	return Vector3(-math.cos(rot.x) * math.sin(rot.z), math.cos(rot.z) * math.cos(rot.x), math.sin(rot.x))
end

function getRotationZXFromForward( fwVec )
	return Vector3(math.deg(math.asin(fwVec.z / fwVec:getLength())), 0, -math.deg(math.atan2(fwVec.x, fwVec.y)))
end

---------------------------------------------------------------------------------------------------
-- material primitive functions
---------------------------------------------------------------------------------------------------
function createPrimitiveQuadDetailsUV(position, size, color, tes)
	local currentTable = {}
	col = tocolor(color.x * 0.6, color.y * 0.6, color.z * 0.6, color.w)
	local pos = Vector3(position.x - 0.5 * size.x, position.y - 0.5 * size.y, position.z)
	for tY = 1, tes.y do
		for tX = 0, tes.x do
			if (tX == 0) then
				table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, ((tY - 1) / tes.y) * size.y + pos.y, pos.z, col, tX / tes.x, (tY - 1) / tes.y})
			end
			table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, ((tY - 1) / tes.y) * size.y + pos.y, pos.z, col, tX / tes.x, (tY - 1) / tes.y})
			table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, (tY / tes.y) * size.y + pos.y, pos.z, col, tX / tes.x, tY / tes.y})
			if (tX == tes.x) then
				table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, (tY / tes.y) * size.y + pos.y, pos.z, col, tX / tes.x, tY / tes.y})
			end
		end
	end
	return currentTable
end

tesList = {}
local colorMultiplier = 1
function createPrimitiveQuadUV(tes)
local thisMat = tostring(tes.x)..'_'..tostring(tes.y)
if tesList[thisMat] then return tesList[thisMat] end
	local currentTable = {}
	local color = tocolor(255 * colorMultiplier, 255 * colorMultiplier, 255 * colorMultiplier, 255)
	local position = Vector3(0, 0, 0)
	local size = Vector2(1, 1)
	local pos = Vector3(position.x - 0.5 * size.x, position.y - 0.5 * size.y, position.z)
	for tY = 1, tes.y do
		for tX = 0, tes.x do
			if (tX == 0) then
				table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, ((tY - 1) / tes.y) * size.y + pos.y, pos.z, color, tX / tes.x, (tY - 1) / tes.y})
			end
			table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, ((tY - 1) / tes.y) * size.y + pos.y, pos.z, color, tX / tes.x, (tY - 1) / tes.y})
			table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, (tY / tes.y) * size.y + pos.y, pos.z, color, tX / tes.x, tY / tes.y})
			if (tX == tes.x) then
				table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, (tY / tes.y) * size.y + pos.y, pos.z, color, tX / tes.x, tY / tes.y})
			end
		end
	end
	tesList[thisMat] = currentTable
	return tesList[thisMat]
end

---------------------------------------------------------------------------------------------------
-- check if element is drawn in front of cam plane
---------------------------------------------------------------------------------------------------
function isEntityVisible(pos, rads)
	if (getCamera().matrix:getForward()):dot(pos - getCamera().matrix:getPosition()) > - (rads / 2) then
		return true
	else
		return false
	end
end	

---------------------------------------------------------------------------------------------------
-- manage after effect zBuffer recovery
---------------------------------------------------------------------------------------------------
CPrmFixZ = { }
function CPrmFixZ.create()
	if CPrmFixZ.shader then return true end
	CPrmFixZ.shader = DxShader( "fx/primitive2D_fixZBuffer.fx" )
	if CPrmFixZ.shader then
		CPrmFixZ.shader:setValue( "fViewportSize", guiGetScreenSize() )
		CPrmFixZ.trianglestrip = createPrimitiveQuadUV( Vector2(1, 1) )
		return true
	end
	return false
end

function CPrmFixZ.draw()
	if CPrmFixZ.shader then
		-- draw the outcome
		dxDrawMaterialPrimitive3D( "trianglestrip", CPrmFixZ.shader, false, unpack( CPrmFixZ.trianglestrip ) )
	end
end

function CPrmFixZ.destroy()
	if CPrmFixZ.shader then
		CPrmFixZ.shader:destroy()
		CPrmFixZ.trianglestrip = nil
	end
end

---------------------------------------------------------------------------------------------------
-- the interval between this frame and the previous one in milliseconds (delta time).
---------------------------------------------------------------------------------------------------
addEventHandler("onClientPreRender", root, function(msSinceLastFrame)
    lastFrameTickCount = msSinceLastFrame
end
)
