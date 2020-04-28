--
-- c_main.lua
--

scx, scy = guiGetScreenSize ()
local bAllValid = nil

----------------------------------------------------------------
-- onClientResourceStart
----------------------------------------------------------------


strengthSettings = {}
strengthSettings['Low'] = {}
strengthSettings['Low']['iMXAOSampleCount'] = 12
strengthSettings['Low']['fMXAOAmbientOcclusionAmount'] = 0.1
strengthSettings['Low']['fMXAOFadeoutStart'] = 0.5
strengthSettings['Low']['fMXAOFadeoutEnd'] = 0.6

strengthSettings['Medium'] = {}
strengthSettings['Medium']['iMXAOSampleCount'] = 13
strengthSettings['Medium']['fMXAOAmbientOcclusionAmount'] = 0.25
strengthSettings['Medium']['fMXAOFadeoutStart'] = 0.7
strengthSettings['Medium']['fMXAOFadeoutEnd'] = 0.8

strengthSettings['High'] = {}
strengthSettings['High']['iMXAOSampleCount'] = 14
strengthSettings['High']['fMXAOAmbientOcclusionAmount'] = 0.5
strengthSettings['High']['fMXAOFadeoutStart'] = 0.8
strengthSettings['High']['fMXAOFadeoutEnd'] = 0.9

function enableShader(strength)
	if not enabled then
		enabled = true
		normalShader = dxCreateShader( "Shaders/getNormal.fx" )
	
		ssaoShader = dxCreateShader( "Shaders/ssao.fx" )
		dxSetShaderValue(ssaoShader,'iMXAOSampleCount',strengthSettings[strength]['iMXAOSampleCount'] or 24)
		
		
		blur1Shader = dxCreateShader( "Shaders/blur1.fx" )
		blur2Shader = dxCreateShader( "Shaders/blur2.fx" )
		dxSetShaderValue(blur2Shader,'fMXAOAmbientOcclusionAmount',strengthSettings[strength]['fMXAOAmbientOcclusionAmount'] or 1.2)
		dxSetShaderValue(blur2Shader,'fMXAOFadeoutStart',strengthSettings[strength]['fMXAOFadeoutStart'] or 1.2)
		dxSetShaderValue(blur2Shader,'fMXAOFadeoutEnd',strengthSettings[strength]['fMXAOFadeoutEnd'] or 1.2)
		
		blendShader = dxCreateShader( "Shaders/blend.fx" )
		
		myScreenSource = dxCreateScreenSource( scx , scy )
		
		bAllValid = normalShader and ssaoShader and blur1Shader and blur2Shader and blendShader and myScreenSource

		if not bAllValid then
			dxSetShaderValue( ssaoShader, "sBayerTex", bayerTexture )
		end
	end
end

function disableShader()
	if enabled and bAllValid then
		bAllValid = nil
		if isElement(normalShader) then
			destroyElement(normalShader)
			destroyElement(ssaoShader)
			destroyElement(blur1Shader)
			destroyElement(blur2Shader)
			destroyElement(blendShader)
			destroyElement(myScreenSource)
			RTPool.clear()
		end
		enabled = nil
	end
end

----------------------------------------------------------------------------------------------------------------------------
-- render active boxes
----------------------------------------------------------------------------------------------------------------------------
addEventHandler("onClientHUDRender", root, function()
	if not bAllValid then
		return 
	end 
	RTPool.frameStart()	
	dxUpdateScreenSource( myScreenSource, true )
	local current = myScreenSource
	local sceneNormal = applyGetNormal( current, 1 )
	current = applySSAO( myScreenSource, sceneNormal )
	
	current = applyBlur1( myScreenSource, current, sceneNormal )
	current = applyBlur2( myScreenSource, current, sceneNormal )
	
	dxSetRenderTarget()
	
	dxSetShaderValue( blendShader, "sTex0", current )

	dxDrawImage ( 0, 0, scx, scy, blendShader, 0, 0, 0, tocolor(255, 255, 255, 255), false )
end
,true ,"high+1")


function changeSetting(setting)
	disableShader()
	if setting == 'Off' then
		disableShader()
	else
		enableShader(setting)
	end
end

addEvent ( "SSAO", true )
addEventHandler ( "SSAO", root, changeSetting )






----------------------------------------------------------------------------------------------------------------------------
-- Apply the different stages
----------------------------------------------------------------------------------------------------------------------------
function applyGetNormal( Src, amount )
	if not Src then return nil end
	local mx, my = dxGetMaterialSize( Src )
	mx = mx / amount
	my = my / amount
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	
	dxSetShaderValue( normalShader, "sTexSize", scx, scy )	
	dxSetShaderValue( normalShader, "sPixelSize", 1 / scx, 1 / scy )	
	dxSetShaderValue( normalShader, "sAspectRatio", scx / scy )
			
	dxDrawImage( 0, 0, mx, my, normalShader )
	return newRT
end

function applyDownsample( Src, amount )
	if not Src then return nil end
	amount = amount or 2
	local mx,my = dxGetMaterialSize( Src )
	mx = mx / amount
	my = my / amount
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, Src )
	DebugResults.addItem( newRT, "applyDownsample" )
	return newRT
end

function applySSAO( Src, Normal )
	if not Src then return nil end
	local mx, my = dxGetMaterialSize( Src )
	mx = mx
	my = my
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	
	dxSetShaderValue( ssaoShader, "sNormalTex", Normal )
	dxSetShaderValue( ssaoShader, "sTexSize", scx, scy )	
	dxSetShaderValue( ssaoShader, "sPixelSize", 1 / scx, 1 / scy )	
	dxSetShaderValue( ssaoShader, "sAspectRatio", scx / scy )
			
	dxDrawImage( 0, 0, mx, my, ssaoShader )
	return newRT
end

function applyBlur1( Src, SrcAO, Normal )
	if not Src then return nil end
	local mx, my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	
	dxSetShaderValue( blur1Shader, "sNormalTex", Normal )
	dxSetShaderValue( blur1Shader, "sAOTex", SrcAO )
	dxSetShaderValue( blur1Shader, "sTexSize", scx, scy )	
	dxSetShaderValue( blur1Shader, "sPixelSize", 1 / scx, 1 / scy )	
	dxSetShaderValue( blur1Shader, "sAspectRatio", scx / scy )
			
	dxDrawImage( 0, 0, mx, my, blur1Shader )
	return newRT
end

function applyBlur2( Src, SrcAO, Normal )
	if not Src then return nil end
	local mx, my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	
	dxSetShaderValue( blur2Shader, "sColorTex", Src )
	dxSetShaderValue( blur2Shader, "sNormalTex", Normal )
	dxSetShaderValue( blur2Shader, "sAOTex", SrcAO )
	dxSetShaderValue( blur2Shader, "sTexSize", scx, scy )	
	dxSetShaderValue( blur2Shader, "sPixelSize", 1 / scx, 1 / scy )	
	dxSetShaderValue( blur2Shader, "sAspectRatio", scx / scy )
			
	dxDrawImage( 0, 0, mx, my, blur2Shader )
	return newRT
end

----------------------------------------------------------------------------------------------------------------------------
-- Pool of render targets
----------------------------------------------------------------------------------------------------------------------------
RTPool = {}
RTPool.list = {}

function RTPool.frameStart()
	for rt,info in pairs(RTPool.list) do
		info.bInUse = false
	end
end

function RTPool.GetUnused( sx, sy )
	-- Find unused existing
	for rt,info in pairs(RTPool.list) do
		if not info.bInUse and info.sx == sx and info.sy == sy then
			info.bInUse = true
			return rt
		end
	end
	-- Add new
	local rt = dxCreateRenderTarget( sx, sy )
	if rt then
		RTPool.list[rt] = { bInUse = true, sx = sx, sy = sy }
	end
	return rt
end

function RTPool.clear()
	for rt,info in pairs(RTPool.list) do
		destroyElement(rt)
	end
	RTPool.list = {}
end

