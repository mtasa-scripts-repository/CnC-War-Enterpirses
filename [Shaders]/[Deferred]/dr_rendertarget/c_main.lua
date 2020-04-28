-- 
-- c_main.lua
--				

shaderSettings = {distFade = {100, 80}}
isPrep4Primitives = true -- prepares the render targets for primitiveMaterial3D entities
local scx, scy = guiGetScreenSize()
isFXSupported = (tonumber(dxGetStatus().VideoCardNumRenderTargets) > 1 and tonumber(dxGetStatus().VideoCardPSVersion) > 2 
	and tostring(dxGetStatus().DepthBufferFormat) ~= "unknown")

isRTShValid = false isRTRtValid = false isRTMaValid = false isDREnabled = false
functionTable = {} shaderTexture = {} renderTarget = {} shaderMaterial = {}

---------------------------------------------------------------------------------------------------
-- getRenderTargets
---------------------------------------------------------------------------------------------------	
function startDR()
	if isDREnabled then return end
	if isPrep4Primitives then
		shaderMaterial.SHPrepRTs = DxShader( "fx/primitive3D_prepRTs.fx" )
		shaderMaterial.trianglestrip = createPrimitiveQuadUV( Vector2(1, 1) )
	else
		shaderMaterial.SHPrepRTs = DxShader( "fx/material3D_prepRTs.fx" )
	end
	isRTMaValid = shaderMaterial.SHPrepRTs and true
	isRTRtValid = functionTable.createRenderTargets()
	isRTShValid = functionTable.createTextureShaders()
	if isRTShValid and isRTRtValid and isRTMaValid then
		shaderMaterial.SHPrepRTs:setValue( "gDistFade", shaderSettings.distFade[1], shaderSettings.distFade[2] )
		shaderMaterial.SHPrepRTs:setValue( "fViewportSize", scx, scy )
		shaderMaterial.SHPrepRTs:setValue( "sPixelSize", 1 / scx, 1 / scy )
		shaderMaterial.SHPrepRTs:setValue( "sHalfPixel", 1/(scx * 2), 1/(scy * 2) )
		local camPos = getCamera().position + getCamera().matrix.forward * getFarClipDistance() * 0.95
		shaderMaterial.SHPrepRTs:setValue( "sLightPosition", camPos.x, camPos.y, camPos.z )
		shaderMaterial.SHPrepRTs:setValue( "ColorRT", renderTarget.RTColor )
		shaderMaterial.SHPrepRTs:setValue( "NormalRT", renderTarget.RTNormal )
		shaderMaterial.SHPrepRTs:setValue( "DepthRT", renderTarget.RTDepth )
		
		switchDROn()
		
		isDREnabled = true
		localPlayer:setData( "dr_renderTarget.on", true, false )
	else
		outputChatBox(isRTShValid..' '..isRTRtValid..' '..isRTMaValid)
		outputChatBox( "dr_renderTarget: Shaders/Render targets not created.", 255, 0, 0 )
	end
end

function stopDR()
	if isRTShValid then
		functionTable.destroyTextureShaders()
		isRTShValid = false
	end
	if isRTRtValid then 
		functionTable.destroyRenderTargets()
		isRTRtValid = false
	end
	if isRTMaValid then
		shaderMaterial.SHPrepRTs:destroy()
		shaderMaterial.SHPrepRTs = nil
		isRTMaValid = false
	end
	if shaderTexture.SHWorldNor then
		functionTable.destroyTextureWorldNormalShader()
	end
	isDREnabled = false
	localPlayer:setData( "dr_renderTarget.on", false, false )
end

function switchDROn()
	if isDREnabled then return end
	if not isRTShValid then
		isRTShValid = functionTable.createTextureShaders()
	end
	if isRTShValid then
		-- world
		shaderTexture.SHWorld:applyToWorldTexture("*")
		functionTable.removeShaderFromList(shaderTexture.SHWorld, textureListTable.RemoveList)	
		functionTable.removeShaderFromList(shaderTexture.SHWorld, textureListTable.ZDisable)		
		functionTable.applyShaderToList(shaderTexture.SHWorld, textureListTable.ApplyList)
		functionTable.applyShaderToList(shaderTexture.SHWorldNoZWrite, textureListTable.ZDisableApply)
		-- grass
		shaderTexture.SHGrass:applyToWorldTexture("tx*")
		-- water
		shaderTexture.SHWater:applyToWorldTexture("water*")
		-- ped
		shaderTexture.SHPed:applyToWorldTexture("*")
		shaderTexture.SHPed:removeFromWorldTexture("unnamed")
		functionTable.removeShaderFromList(shaderTexture.SHPed, textureListTable.ZDisable)
		-- vehicle
		--functionTable.applyShaderToList(shaderTexture.SHVehPaint, textureListTable.TextureGrun)
		shaderTexture.SHVehPaint:applyToWorldTexture("*")
		--shaderTexture.SHVehPaint:applyToWorldTexture("vehiclegeneric256")	
		shaderTexture.SHVehPaint:removeFromWorldTexture("unnamed")		
	end
	isDREnabled = true
	localPlayer:setData( "dr_renderTarget.on", true, false )
end

function switchDROff()
	if not isDREnabled then return end
	if isRTShValid then
		isRTShValid = not functionTable.destroyTextureShaders()
	end
	isDREnabled = false
	localPlayer:setData( "dr_renderTarget.on", false, false )
end

addEventHandler( "onClientPreRender", root,
    function()
		if not isRTMaValid or not isRTRtValid then return end
		renderTarget.RTColor:setAsTarget( false )
		dxDrawRectangle(0, 0, scx, scy, tocolor(128,128,128,255))
		renderTarget.RTNormal:setAsTarget( false )
		dxDrawRectangle(0, 0, scx, scy, tocolor(255,255,255,255))
		renderTarget.RTDepth:setAsTarget( false )
		dxDrawRectangle(0, 0, scx, scy, tocolor(255,255,255,255))

		dxSetRenderTarget()
		if isPrep4Primitives then
			-- fix for gtasa effects and line material after readable depth buffer is used 	
			if dxGetStatus().UsingDepthBuffer then
				if CPrmFixZ.create() then
					CPrmFixZ.draw()
				end
			end	
			dxDrawMaterialPrimitive3D( "trianglestrip", shaderMaterial.SHPrepRTs, false, unpack( shaderMaterial.trianglestrip ) )	
		else
			local camPos = getCamera().position + getCamera().matrix.forward * getFarClipDistance() * 0.97
			dxDrawMaterialLine3D( camPos.x + 0.5, camPos.y, camPos.z, camPos.x + 0.5, camPos.y + 1, camPos.z, 
				shaderMaterial.SHPrepRTs, 1, tocolor(255,255,255,255), camPos.x + 0.5,camPos.y + 0.5, camPos.z + 1 )
		end
    end
, true, "high+10" )

--[[
addEventHandler( "onClientRender", root,
    function()
		dxDrawImage(0,0,scx/2,scy/2,renderTarget.RTColor)
    end
, true, "high+10" )
]]--
---------------------------------------------------------------------------------------------------
-- manage render targets
---------------------------------------------------------------------------------------------------
function functionTable.createRenderTargets()
	if not isRTRtValid then
		renderTarget = {
			RTColor = DxRenderTarget( scx , scy, false ),
			RTNormal = DxRenderTarget( scx , scy, false ),
			RTDepth = DxRenderTarget( scx , scy, false )
		}
		
		isRTRtValid = true
		for _,thisPart in pairs(renderTarget) do
			isRTRtValid = thisPart and isRTRtValid
		end
	end
	return isRTRtValid
end

function functionTable.destroyRenderTargets()
	if isRTRtValid then
		for _,thisPart in pairs(renderTarget) do
			thisPart:destroy()
			thisPart = nil
		end
	isRTRtValid = false 
	end
end

---------------------------------------------------------------------------------------------------
-- manage world shaders
---------------------------------------------------------------------------------------------------
function functionTable.applyRTToTextureShader(myShader)
	if myShader then
		myShader:setValue( "ColorRT", renderTarget.RTColor )
		myShader:setValue( "DepthRT", renderTarget.RTDepth )
		myShader:setValue( "NormalRT", renderTarget.RTNormal )
	end
end

function functionTable.applyShaderToList(myShader, myList)
	for _,applyMatch in ipairs(myList) do
		myShader:applyToWorldTexture(applyMatch)	
	end
end

function functionTable.removeShaderFromList(myShader, myList)
	for _,removeMatch in ipairs(myList) do
		myShader:removeFromWorldTexture(removeMatch)	
	end
end

function functionTable.applyShaderToObjectList(myShader, myList, myObject)
	for _,applyMatch in ipairs(myList) do
		myShader:applyToWorldTexture(applyMatch, myObject)	
	end
end

function functionTable.removeShaderFromObjectList(myShader, myList, myObject)
	for _,removeMatch in ipairs(myList) do
		myShader:removeFromWorldTexture(removeMatch, myObject)	
	end
end

function functionTable.createTextureWorldNormalShader()
	if not shaderTexture.SHWorldNor then
		shaderTexture.SHWorldNor = DxShader(unpack(shaderParams.SHWorldNor))
		functionTable.applyRTToTextureShader(shaderTexture.SHWorldNor)
		shaderTexture.SHWorldNor:setValue( "sPixelSize", 1 / scx, 1 / scy )
		shaderTexture.SHWorldNor:setValue( "sHalfPixel", 1/(scx * 2), 1/(scy * 2) )
	end
	return shaderTexture.SHWorldNor and true
end

function functionTable.destroyTextureWorldNormalShader()
	if shaderTexture.SHWorldNor then
		shaderTexture.SHWorldNor:destroy()
		shaderTexture.SHWorldNor = nil
	end
end
		
function functionTable.createTextureShaders()
	shaderTexture.SHWorld = DxShader(unpack(shaderParams.SHWorld))
	shaderTexture.SHWorldNoZWrite = DxShader(unpack(shaderParams.SHWorldNoZWrite))
	shaderTexture.SHWater = DxShader(unpack(shaderParams.SHWater))
	shaderTexture.SHGrass = DxShader(unpack(shaderParams.SHGrass))
	shaderTexture.SHPed = DxShader(unpack(shaderParams.SHPed))
	shaderTexture.SHVehPaint = DxShader(unpack(shaderParams.SHVehPaint))

	isRTShValid = true
	for _,thisShader in pairs(shaderTexture) do
		isRTShValid = thisShader and isRTShValid
		if isRTShValid then
			functionTable.applyRTToTextureShader(thisShader)
			thisShader:setValue( "sPixelSize", 1 / scx, 1 / scy )
			thisShader:setValue( "sHalfPixel", 1/(scx * 2), 1/(scy * 2) )
		end
	end
	if not isRTShValid then
		outputChatBox('dr_renderTarget: Input effects not created', 255, 0, 0)
		return false
	end	
	return isRTShValid
end

function functionTable.destroySingleTextureShader(thisShader)
	if thisShader then 
		thisShader:removeFromWorldTexture("*")
		thisShader:destroy()
		thisShader = nil
	end
	return true
end

function functionTable.destroyTextureShaders()
	for _,thisPart in pairs(shaderTexture) do
		isRTShValid = functionTable.destroySingleTextureShader(thisPart) and isRTShValid
	end
	return isRTShValid
end
