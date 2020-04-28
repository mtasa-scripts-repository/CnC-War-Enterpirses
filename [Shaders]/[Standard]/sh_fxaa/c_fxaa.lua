--
-- c_fxaa.lua
--
-- converted from Master Effects Standard Edition 1.3

local orderPriority = "-2.5"	-- The lower this number, the later the effect is applied

local maxAntialiasing = 5		-- The maximum number of antialiaisng passes.

Settings = {}
Settings.var = {}

---------------------------------
-- sm version
---------------------------------
function vCardPSVer()
 local info=dxGetStatus()
    for k,v in pairs(info) do
		if string.find(k, "VideoCardPSVersion") then
		smVersion=tostring(v)
		end
    end
	return smVersion
end

----------------------------------------------------------------
-- enablefxAA
----------------------------------------------------------------
function enablefxAA(aaVal)
	aaValue = tonumber(aaVal)
	if ( aaValue > maxAntialiasing or aaValue<1 ) then 
		aaValue=0 
		disablefxAA()
	end

	if aEffectEnabled then return end
	-- Create things
    myScreenSource = dxCreateScreenSource( scx, scy )
	fXAAShader,tecName = dxCreateShader( "fx/FXAA.fx" )

	-- Get list of all elements used
	effectParts = {
						myScreenSource,
						fXAAShader,
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end

	setEffectVariables ()
	aEffectEnabled = true
	
end

----------------------------------------------------------------
-- disablefxAA
----------------------------------------------------------------
function disablefxAA()
	if not aEffectEnabled then return end

	-- Destroy all shaders
	for _,part in ipairs(effectParts) do
		if part then
			destroyElement( part )
		end
	end
	effectParts = {}
	bAllValid = false
	RTPool.clear()

	-- Flag effect as stopped
	aEffectEnabled = false
end

---------------------------------
-- Settings for effect
---------------------------------
function setEffectVariables()
    local v = Settings.var
    -- fxAA
	v.FXAA_LINEAR=0
	v.FXAA_QUALITY__EDGE_THRESHOLD=(1.0/32.0)
	v.FXAA_QUALITY__EDGE_THRESHOLD_MIN=(1.0/16.0)
	v.FXAA_QUALITY__SUBPIX_CAP=(7.0/8.0)
	v.FXAA_QUALITY__SUBPIX_TRIM=(1.0/12.0)
	v.FXAA_SEARCH_STEPS=16
	v.FXAA_SEARCH_THRESHOLD=(1.0/4.0)

	-- Debugging
    v.PreviewEnable=0
    v.PreviewPosY=0
    v.PreviewPosX=100
    v.PreviewSize=70
	
	applySettings(v)
end

function applySettings(v)
	if not fXAAShader then return end
	dxSetShaderValue(fXAAShader,"FXAA_LINEAR",v.FXAA_LINEAR)
	dxSetShaderValue(fXAAShader,"FXAA_QUALITY__EDGE_THRESHOLD",v.FXAA_QUALITY__EDGE_THRESHOLD)
	dxSetShaderValue(fXAAShader,"FXAA_QUALITY__EDGE_THRESHOLD_MIN",v.FXAA_QUALITY__EDGE_THRESHOLD_MIN)
	dxSetShaderValue(fXAAShader,"FXAA_QUALITY__SUBPIX_CAP",v.FXAA_QUALITY__SUBPIX_CAP)
	dxSetShaderValue(fXAAShader,"FXAA_QUALITY__SUBPIX_TRIM",v.FXAA_QUALITY__SUBPIX_TRIM)
	dxSetShaderValue(fXAAShader,"FXAA_SEARCH_STEPS",v.FXAA_SEARCH_STEPS)
	dxSetShaderValue(fXAAShader,"FXAA_SEARCH_THRESHOLD",v.FXAA_SEARCH_THRESHOLD)
end
-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
addEventHandler( "onClientHUDRender", root,
    function()
		if not bAllValid or not Settings.var then return end
		local v = Settings.var
		
		-- Reset render target pool
		RTPool.frameStart()
		DebugResults.frameStart()

		-- Update screen
		dxUpdateScreenSource( myScreenSource, true )

		-- Start with screen
		local current = myScreenSource
			
		for i=1,tonumber(aaValue) do current = applyFXAA( current,i )  end			

		-- When we're done, turn the render target back to default
		dxSetRenderTarget()

		if current then dxDrawImage( 0, 0, scx, scy, current, 0, 0, 0, tocolor(255,255,255,255) ) end
			
		-- Debug stuff
		if v.PreviewEnable > 0.5 then
			DebugResults.drawItems ( v.PreviewSize, v.PreviewPosX, v.PreviewPosY )
		end
    end
,true ,"low" .. orderPriority )


-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------

function applyFXAA( Src, pass)
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local scrRes = {mx,my}
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( fXAAShader, "screenResolution", scrRes )
	dxSetShaderValue( fXAAShader, "TEX0", Src )
	dxDrawImage( 0, 0, mx,my, fXAAShader )
	local passId='fxAA: pass '..pass
	DebugResults.addItem( newRT, passId )
	return newRT
end

----------------------------------------------------------------
-- Avoid errors messages when memory is low
----------------------------------------------------------------
_dxDrawImage = dxDrawImage
function xdxDrawImage(posX, posY, width, height, image, ... )
	if not image then return false end
	return _dxDrawImage( posX, posY, width, height, image, ... )
end