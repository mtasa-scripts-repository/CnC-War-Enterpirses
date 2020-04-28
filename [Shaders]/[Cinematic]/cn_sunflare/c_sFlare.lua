sunShader = {}

function enableShader()
	if not enabled then
		enabled = true
		sunShader.screenWidth, sunShader.screenHeight = guiGetScreenSize()
			
		sunShader.lensFlareDirt = dxCreateTexture("Textures/lensflare_dirt.png", "dxt5")
		sunShader.lensFlareChroma = dxCreateTexture("Textures/lensflare_chroma.png", "dxt5")
		sunShader.viewDistance = 0.00003
		sunShader.sunColorInner = {0.8, 0.8, 0.8, 0.8}

		sunShader.screenSource = dxCreateScreenSource(sunShader.screenWidth, sunShader.screenHeight)
			
		sunShader.renderTargetBW = dxCreateRenderTarget(sunShader.screenWidth, sunShader.screenHeight)
		sunShader.renderTargetGodRaysBase = dxCreateRenderTarget(sunShader.screenWidth, sunShader.screenHeight)
		sunShader.renderTargetGodRays = dxCreateRenderTarget(sunShader.screenWidth, sunShader.screenHeight)
			
		sunShader.bwShader = dxCreateShader("Shaders/bw.fx")
		sunShader.godRayBaseShader = dxCreateShader("Shaders/godRayBase.fx")
		sunShader.godRayShader = dxCreateShader("Shaders/godrays.fx")
		sunShader.lensFlareShader = dxCreateShader("Shaders/lensflares.fx")
				
		dxSetShaderValue(sunShader.lensFlareShader, "screenSource", sunShader.screenSource)
		dxSetShaderValue(sunShader.lensFlareShader, "sunLight", sunShader.renderTargetGodRays)
		dxSetShaderValue(sunShader.lensFlareShader, "lensDirt", sunShader.lensFlareDirt)
		dxSetShaderValue(sunShader.lensFlareShader, "lensChroma", sunShader.lensFlareChroma)
		dxSetShaderValue(sunShader.lensFlareShader, "screenSize", {sunShader.screenWidth, sunShader.screenHeight})
			
		dxSetShaderValue(sunShader.godRayShader, "sunLight", sunShader.renderTargetGodRaysBase)
		dxSetShaderValue(sunShader.godRayShader, "lensDirt", sunShader.lensFlareDirt)
			
		dxSetShaderValue(sunShader.godRayBaseShader, "screenSource", sunShader.screenSource)
		dxSetShaderValue(sunShader.godRayBaseShader, "renderTargetBW", sunShader.renderTargetBW)
		dxSetShaderValue(sunShader.godRayBaseShader, "screenSize", {sunShader.screenWidth, sunShader.screenHeight})
			
		dxSetShaderValue(sunShader.bwShader, "screenSource", sunShader.screenSource)
		dxSetShaderValue(sunShader.bwShader, "viewDistance", sunShader.viewDistance)
	end
end

function disableShader()
	if enabled then
		enabled = nil
		for i,v in pairs(sunShader) do
			if isElement(v) then
				destroyElement(v)
			end
		end
	end
	sunShader = {}
end

function changeSetting(setting)
	if setting == 'Off' then
		disableShader()
	else
		enableShader()
	end
end

addEvent ( "Sun Flare", true )
addEventHandler ( "Sun Flare", root, changeSetting )

	
function sunShader.update()
	if enabled then
		sunShader.sunX, sunShader.sunY, sunShader.sunZ = exports.base_env:getSunPosition ()

		sunShader.sunScreenX, sunShader.sunScreenZ = getScreenFromWorldPosition(sunShader.sunX, sunShader.sunY, sunShader.sunZ, 5, true)
				
		if sunShader.sunScreenX and sunShader.sunScreenZ then
		
			local sunO,sunI = exports.sh_light:getSunColor()
			local r,g,b,a = unpack(sunI)
			sunShader.sunColorInner = {r/255,g/255,b/255,a/255}
		
		
			dxUpdateScreenSource(sunShader.screenSource)	
			
			--scenario bw
			dxSetRenderTarget(sunShader.renderTargetBW, true)
			dxDrawImage(0, 0, sunShader.screenWidth, sunShader.screenHeight, sunShader.bwShader)
			dxSetRenderTarget()

			-- godray base
			dxSetRenderTarget(sunShader.renderTargetGodRaysBase, true)
			dxDrawImage(0, 0, sunShader.screenWidth, sunShader.screenHeight, sunShader.godRayBaseShader)
			dxSetRenderTarget()
			
			-- godrays
			dxSetShaderValue(sunShader.godRayShader, "sunPos", {(1 / sunShader.screenWidth) * sunShader.sunScreenX, (1 / sunShader.screenHeight) * sunShader.sunScreenZ})
			
			dxSetRenderTarget(sunShader.renderTargetGodRays, true)
			dxDrawImage(0, 0, sunShader.screenWidth, sunShader.screenHeight, sunShader.godRayShader)
			dxSetRenderTarget()
			
			
			-- lensflares
			dxSetShaderValue(sunShader.lensFlareShader, "sunPos", {(1 / sunShader.screenWidth) * sunShader.sunScreenX, (1 / sunShader.screenHeight) * sunShader.sunScreenZ})
			dxSetShaderValue(sunShader.lensFlareShader, "sunColor", sunShader.sunColorInner)
					
			dxDrawImage(0, 0, sunShader.screenWidth, sunShader.screenHeight, sunShader.lensFlareShader)
		end
	end
end


addEventHandler("onClientHUDRender", root, sunShader.update)
