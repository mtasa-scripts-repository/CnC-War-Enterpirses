

addEventHandler( "onClientResourceStart",resourceRoot,
    function (  )
		alphaShader1 = dxCreateShader ( "shaders/shader_Alpha.fx",0,0,false,'object,ped,vehicle' )
		
		
		applyList = {'*clouds*','*Atmosphere*','*galaxy*','*marine_helmet_hud*','LightBeam','*glass*','*volumetric dust*','teleporter_shield_mask'}

		for i,v in pairs(applyList) do
			engineApplyShaderToWorldTexture(alphaShader1,v,nil,false)
		end
    end
);