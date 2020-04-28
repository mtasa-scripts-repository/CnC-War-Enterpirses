--
-- c_main.lua
--

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

function enableShader()
	if not enabled then
		enabled = true
		shader, tec = dxCreateShader ( "flag.fx" )
		dxSetShaderValue(shader, "sWaveFreq", 1 )
		dxSetShaderValue(shader, "sWaveSpeed", -0.75 )
		dxSetShaderValue(shader, "sWaveSize", 0.001 )
		dxSetShaderValue(shader, "sHighlightOffset", 0 )
		dxSetShaderValue(shader, "sHighlightAmount", 0.4 )

		-- Apply to world texture
			
		engineApplyShaderToWorldTexture ( shader, "*flag*" )
	end
end



function updateLight ()
	if shader then
		local hour, minute = getTime ()
					
		if hour >= 19 then
			Skyalpha = math.min(((27-hour)-(minute/60))/7.4,1)
		elseif hour <= 6 then
			Skyalpha = math.max(((hour-1)+(minute/60))/7,0.7)
		else
			Skyalpha = 1
		end
					
		local Skyalpha = (Skyalpha < 1) and Skyalpha^5 or Skyalpha
			
		dxSetShaderValue(shader, "brightness", Skyalpha )
	end
end
addEventHandler ( "onClientRender", root, updateLight )

function disableShader()
	if enabled then
		enabled = nil
		if isElement(shader) then
			destroyElement(shader)
			shader = nil
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

addEvent ( "Flag Effects", true )
addEventHandler ( "Flag Effects", root, changeSetting )
