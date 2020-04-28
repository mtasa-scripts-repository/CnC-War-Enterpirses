
special.BR = function(weapon,player)
	if (player == localPlayer) and screen then

		dxUpdateScreenSource( screen )
		
		dxSetRenderTarget( render,true )
			dxDrawImage( -32, -12,  128, 64, screen )
			dxDrawImage( 0, 0,  64, 32, prepImage2('Lens'),0,0,0,tocolor(255,255,255,160) )
		dxSetRenderTarget() 

		if not shader[weapon]['Lens'] then
			shader[weapon]['Lens'] = createShader()
			engineApplyShaderToWorldTexture(shader[weapon]['Lens'], "Lens",weapon)
		else
			dxSetShaderValue( shader[weapon]['Lens'], "tex0", render )
		end
	end
	
	local ammo = tostring(getElementData(player,'Ammo.BR') or number)
	
	local ammo1 = tonumber(ammo:sub( 1, 1 ))
	
	local ammo2a = tonumber(ammo:sub( 2, 2 ))
		
	local ammo2 = ammo2a or ammo1
	local ammo1 = ammo2a and ammo1 or 0

	
	if not shader[weapon]['Ammo1'] then
		shader[weapon]['Ammo1'] = createShader()
		engineApplyShaderToWorldTexture(shader[weapon]['Ammo1'], "numbers_plate [2]",weapon)
	else
		local picture = prepImage('numbers_plate['..(ammo1 or 0)..']')
		dxSetShaderValue( shader[weapon]['Ammo1'], "tex0", picture )
	end
	
	if not shader[weapon]['Ammo2'] then
		shader[weapon]['Ammo2'] = createShader()
		engineApplyShaderToWorldTexture(shader[weapon]['Ammo2'], "numbers_plate [1]",weapon)
	else
		local picture = prepImage('numbers_plate['..(ammo2 or 0)..']')
		dxSetShaderValue( shader[weapon]['Ammo2'], "tex0", picture )
	end
end
