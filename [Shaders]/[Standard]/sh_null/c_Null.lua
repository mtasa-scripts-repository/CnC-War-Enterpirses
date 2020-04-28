
nullShader = dxCreateShader ( "Shaders/shader_null.fx",500,0,false )

engineApplyShaderToWorldTexture(nullShader, "seabd32" )
engineApplyShaderToWorldTexture(nullShader, "waterclear256" )
engineApplyShaderToWorldTexture(nullShader, "*corona*" )

function delayedShader ( )
	engineApplyShaderToWorldTexture(nullShader, "seabd32" )
	engineApplyShaderToWorldTexture(nullShader, "waterclear256" )
	engineApplyShaderToWorldTexture(nullShader, "*corona*" )
end


setTimer ( delayedShader, 5000, 0)