rShader = {Paint = {},Window = {},Skin = {}}

local scx,scy = guiGetScreenSize ()

function rShader.Int()
	rShader.scXY = {800,600} -- reflection screensource resolution
	rShader.normal = 1 -- deformation strength
	rShader.bumpSize = 0.7 -- for car paint
	rShader.bumpIntensity = 0.7 -- intensity of the bump effect (vehicle)
	rShader.envIntensity = {0.003, 1, 15} -- intensity of the reflection effect
	rShader.brightnessMul = {0.4, 0.4, 5} -- multiply after brightpass
	rShader.brightpassPower = {2, 2, 2} -- 1-5
	rShader.brightnessAdd = {0.1, 0.1 , 0.1} -- before bright pass
	rShader.uvMul = {1.5,1.5} -- uv multiply
	rShader.uvMov = {0,0} -- uv move
	addEventHandler ( "onClientRender", getRootElement (), rShader.updateScreen )
	rShader.createShaders()
end

rShader.Paint.Textures = {'*rocket*','*warthog*','reflective','00838488'}
rShader.Skin.Textures = {'marine_helmet','*reflective*'}
rShader.Window.Textures = {'*window*','*marine_helmet_hud*','*glass*'}

function rShader.createShaders()

		rShader.Paint.Shader = dxCreateShader ( "Shaders/car_paint.fx",1 ,300 ,true, "all" )
		rShader.Window.Shader = dxCreateShader ( "Shaders/car_window.fx",1 ,300 ,true, "all" )	
		rShader.Skin.Shader = dxCreateShader ( "Shaders/car_paint.fx",1 ,300 ,true, "all" )	
		
		if rShader.Paint.Shader and rShader.Window.Shader and rShader.Skin.Shader then
			rShader.screen = dxCreateScreenSource( scx,scy )

			rShader.texture = dxCreateTexture ( "Media/smallnoise3d.dds" )
			
			dxSetShaderValue ( rShader.Paint.Shader, "sRandomTexture", rShader.texture )
			dxSetShaderValue ( rShader.Paint.Shader, "sReflectionTexture", rShader.screen )
			dxSetShaderValue ( rShader.Paint.Shader, "sNorFac", rShader.normal)
			dxSetShaderValue ( rShader.Paint.Shader, "uvMul", rShader.uvMul[1],rShader.uvMul[2])
			dxSetShaderValue ( rShader.Paint.Shader, "uvMov", rShader.uvMov[1],rShader.uvMov[2])
			dxSetShaderValue ( rShader.Paint.Shader, "bumpSize", rShader.bumpSize)
			dxSetShaderValue ( rShader.Paint.Shader, "bumpIntensity", rShader.bumpIntensity)
			dxSetShaderValue ( rShader.Paint.Shader, "envIntensity", rShader.envIntensity[1])
			dxSetShaderValue ( rShader.Paint.Shader, "sPower", rShader.brightpassPower[1])			
			dxSetShaderValue ( rShader.Paint.Shader, "sAdd", rShader.brightnessAdd[1])
			dxSetShaderValue ( rShader.Paint.Shader, "sMul", rShader.brightnessMul[1])

			dxSetShaderValue ( rShader.Skin.Shader, "sRandomTexture", rShader.texture )
			dxSetShaderValue ( rShader.Skin.Shader, "sReflectionTexture", rShader.screen )
			dxSetShaderValue ( rShader.Skin.Shader, "sNorFac", rShader.normal)
			dxSetShaderValue ( rShader.Skin.Shader, "uvMul", rShader.uvMul[1],rShader.uvMul[2])
			dxSetShaderValue ( rShader.Skin.Shader, "uvMov", rShader.uvMov[1],rShader.uvMov[2])
			dxSetShaderValue ( rShader.Skin.Shader, "bumpSize", rShader.bumpSize)
			dxSetShaderValue ( rShader.Skin.Shader, "bumpIntensity", rShader.bumpIntensity)
			
			dxSetShaderValue ( rShader.Skin.Shader, "envIntensity", rShader.envIntensity[3])
			dxSetShaderValue ( rShader.Skin.Shader, "sPower", rShader.brightpassPower[3])			
			dxSetShaderValue ( rShader.Skin.Shader, "sAdd", rShader.brightnessAdd[3])
			dxSetShaderValue ( rShader.Skin.Shader, "sMul", rShader.brightnessMul[3])
			
			dxSetShaderValue ( rShader.Window.Shader, "sRandomTexture", rShader.texture )
			dxSetShaderValue ( rShader.Window.Shader, "sReflectionTexture", rShader.screen )
			dxSetShaderValue ( rShader.Window.Shader, "isShatter", true)
			dxSetShaderValue ( rShader.Window.Shader, "sNorFac", rShader.normal)
			dxSetShaderValue ( rShader.Window.Shader, "uvMul", rShader.uvMul[1],rShader.uvMul[2])
			dxSetShaderValue ( rShader.Window.Shader, "uvMov", rShader.uvMov[1],rShader.uvMov[2])
			dxSetShaderValue ( rShader.Window.Shader, "bumpSize", rShader.bumpSize )
			dxSetShaderValue ( rShader.Window.Shader, "envIntensity", rShader.envIntensity[2])
			dxSetShaderValue ( rShader.Window.Shader, "sPower", rShader.brightpassPower[2])			
			dxSetShaderValue ( rShader.Window.Shader, "sAdd", rShader.brightnessAdd[2])
			dxSetShaderValue ( rShader.Window.Shader, "sMul", rShader.brightnessMul[2])

			-- Apply to world texture
			
			for _,addList in pairs(rShader.Paint.Textures) do
				engineApplyShaderToWorldTexture (rShader.Paint.Shader, addList )
		    end
			
			for _,addList in pairs(rShader.Window.Textures) do
				engineApplyShaderToWorldTexture (rShader.Window.Shader, addList )
		    end

			for _,addList in pairs(rShader.Skin.Textures) do
				engineApplyShaderToWorldTexture (rShader.Skin.Shader, addList )
		    end
			
		else	
			outputChatBox( "Reflection Shader : Failed",255,0,0 )	
		end
end

function rShader.updateScreen()
	if rShader.screen then
		dxUpdateScreenSource(rShader.screen)
	end
end
rShader.Int()