--
-- c_main.lua
--

local isDynamicSkyStarted = false

---------------------------------
-- shader model version
---------------------------------
function vCardPSVer()
	local smVersion = tostring(dxGetStatus().VideoCardPSVersion)
	outputDebugString("VideoCardPSVersion: "..smVersion)
	return smVersion
end

---------------------------------
-- DepthBuffer access
---------------------------------
function isDepthBufferAccessible()
	local depthStatus = tostring(dxGetStatus().DepthBufferFormat)
	outputDebugString("DepthBufferFormat: "..depthStatus)
	if depthStatus=='unknown' then depthStatus=false end
	return depthStatus
end

----------------------------------------------------------------
-- enableWaterShine
----------------------------------------------------------------
function enableWaterShine()
	if wsEffectEnabled then return end
	-- Create things
	texWaterShader,tecName = dxCreateShader( "fx/tex_water.fx" , 1, 700)	
	textureVol = dxCreateTexture ( "images/wavemap.png" )
	textureCube = dxCreateTexture ( "images/cube_env256.dds" )
	-- Get list of all elements used
	effectParts = {
						texWaterShader,
						textureVol,
						textureCube
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end
	if not bAllValid then return end
	dxSetShaderValue ( texWaterShader, "sRandomTexture", textureVol );
	dxSetShaderValue ( texWaterShader, "sReflectionTexture", textureCube );
	--engineApplyShaderToWorldTexture( texWaterShader, "*beavercreek_flow*",nil,false )
	wsEffectEnabled = true

	-- Update water color incase it gets changed by persons unknown
	watTimer = setTimer( function()
					if texWaterShader and wsEffectEnabled then
						local r, g, b, a = getWaterColor()
						r, g, b, a = r/255, g/255, b/255, a/255
						dxSetShaderValue ( texWaterShader, "sWaterColor", r, g, b, a )
					end
				end
				,100,0 )	
end

--dxDrawMaterialLine3D( x, y, z, x + width, y + height, z + tonumber( rotation or 0 ), material, height, color or 0xFFFFFFFF, ... )

function returnWaterMarkers(id)
	Start = nil
	End = nil
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'ID') == id) then
			if getElementData(v,'Water Start') then
				Start = v
			end
			if getElementData(v,'Water End') then
				End = v
			end
		end
	end
	return Start,End
end

Water = {}

function getWater()
	Water = {}
		for i = 1,10 do
		local waterStart,waterEnd = returnWaterMarkers(i)
		if waterStart and waterEnd then
			local x,y,z = getElementPosition(waterStart)
			local xa,ya,za = getElementPosition(waterEnd)
			local width = getElementData(waterStart,'Width') or 20
			Water[i] = {x,y,z,xa,ya,za,width}
		end
	end
end

setTimer ( getWater, 5000, 0)
getWater()

addEventHandler( "onClientRender", root,
	function ()
		if not wsEffectEnabled then return end

		--dxDrawText( string.format("%02d:%02d:%02d",h,m,s), 200, 200 )
		
		
		local hour, minute = getTime ()
			
		if hour >= 19 then
			Skyalpha = math.min(((27-hour)-(minute/60))/7.4,1)
		elseif hour <= 6 then
			Skyalpha = math.max(((hour-1)+(minute/60))/7,0.1)
		else
			Skyalpha = 1
		end
			
		local Skyalpha = (Skyalpha < 1) and Skyalpha^7 or Skyalpha

		local sunColorOuter = {Skyalpha*255,Skyalpha*255,Skyalpha*255, 1}
		local sunColorInner = {Skyalpha*0.8*255,Skyalpha*0.8*255,Skyalpha*0.8*255, 1}
		
		
		
		dxSetShaderValue( texWaterShader, "scroll", getTickCount()/7 )
		
		dxSetShaderValue ( texWaterShader, "sWaterColor", 0.3*Skyalpha, 0.6*Skyalpha, 0.75*Skyalpha, 0.2 )
		dxSetShaderValue( texWaterShader, "sSunColorTop", sunColorOuter[1]/255, sunColorOuter[2]/255, sunColorOuter[3]/255)
		dxSetShaderValue( texWaterShader, "sSunColorBott", sunColorInner[1]/255, sunColorInner[2]/255, sunColorInner[3]/255)
		
		local x,y,z = exports.base_env:getSunPosition ()
		dxSetShaderValue( texWaterShader, "sLightDir", x, y, z )
		dxSetShaderValue( texWaterShader, "sSpecularPower", 0.5*Skyalpha )
		dxSetShaderValue( texWaterShader, "sSpecularBrightness", Skyalpha/2 )
		
		for i = 1,1 do
			if Water[i] then
				local x,y,z,xa,ya,za,width = unpack(Water[i])
				dxDrawMaterialLine3D( x,y,z,xa,ya,za, texWaterShader,width,tocolor(50,50,50,5),false,x,y,z+100 )
			end
		end
	end
)

----------------------------------------------------------------
-- Math helper functions
----------------------------------------------------------------
function math.lerp(from,alpha,to)
    return from + (to-from) * alpha
end

function math.unlerp(from,pos,to)
	if ( to == from ) then
		return 1
	end
	return ( pos - from ) / ( to - from )
end


function math.clamp(low,value,high)
    return math.max(low,math.min(value,high))
end

function math.unlerpclamped(from,pos,to)
	return math.clamp(0,math.unlerp(from,pos,to),1)
end
enableWaterShine()