--
-- c_exports.lua
--

----------------------------------------------------------------------------------------------------
-- exports
----------------------------------------------------------------------------------------------------
function getRenderTargets()
	if renderTarget.RTColor and renderTarget.RTDepth and renderTarget.RTNormal then
		return renderTarget.RTColor, renderTarget.RTDepth, renderTarget.RTNormal
	else
		return false, false
	end
end

function getShaderDistanceFade()
	if shaderSettings.distFade[1] and shaderSettings.distFade[2] then
		return shaderSettings.distFade[1], shaderSettings.distFade[2]
	else
		return false, false
	end
end

function applyNormalMappingToTextureList(texList)
	if not isRTMaValid then return false end
	if not shaderTexture.SHWorldNor then
		functionTable.createTextureWorldNormalShader() 
	end
	functionTable.removeShaderFromList(shaderTexture.SHWorld, texList)
	
	functionTable.applyShaderToList(shaderTexture.SHWorldNor, texList)
end

function applyNormalMappingToTexture(texName)
	if not isRTMaValid then return false end
	if not shaderTexture.SHWorldNor then
		functionTable.createTextureWorldNormalShader() 
	end
	shaderTexture.SHWorld:removeFromWorldTexture(texName)
	shaderTexture.SHWorldNor:applyToWorldTexture(texName)
end

function applyNormalMappingToObject(myObject)
	if not isRTMaValid then return false end
	if not shaderTexture.SHWorldNor then
		functionTable.createTextureWorldNormalShader() 
	end
	shaderTexture.SHWorld:removeFromWorldTexture("*", myObject)
	shaderTexture.SHWorldNor:applyToWorldTexture("*", myObject)
end
