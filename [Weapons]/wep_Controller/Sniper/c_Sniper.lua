
aimShader = {}

screen = dxCreateScreenSource ( 128, 64 )
render = dxCreateRenderTarget ( 64,32 )

local screenWidth,screenHeight = guiGetScreenSize()

function prepImage2(path,mip)
	images[path] = images[path] or dxCreateTexture('Sniper/'..path..'.png','dxt5',mip)
	return images[path]
end

special.Sniper = function(weapon,player)
	if player == localPlayer then

		dxUpdateScreenSource( screen )
		
		dxSetRenderTarget( render,true )
			dxDrawImage( -32, 0,  128, 64, screen )
			dxDrawImage( 0, 0,  64, 32, prepImage2('sniper_rifle_scope_screen'),0,0,0,tocolor(255,255,255,80) )
		dxSetRenderTarget() 
				
				

		if getElementData(localPlayer,'Zoom') then
			dxDrawImage ( 0+100,0+100,screenWidth-200,screenHeight-200, prepImage2('sniper_rifle_scope_screen2'),0,0,0,tocolor(255,255,255,50))
		end
		
				
		if not shader[weapon]['Screen'] then
			shader[weapon]['Screen'] = createShader()
			engineApplyShaderToWorldTexture(shader[weapon]['Screen'], "sniper_rifle_scope_screen",weapon)
		else
			dxSetShaderValue( shader[weapon]['Screen'], "tex0", render )
		end
	end
end
