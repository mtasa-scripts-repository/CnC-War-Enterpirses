
images = {}

function prepImage(path,mip)
	images[path] = images[path] or dxCreateTexture('AR/Textures/'..path..'.png','dxt5',mip)
	return images[path]
end

function createShader()
	return dxCreateShader( "fx/texture.fx",0,0,false )
end

refresh = 200

compass = {}
compass[0] = 7
compass[1] = 6
compass[2] = 5
compass[3] = 4
compass[4] = 3
compass[5] = 2
compass[6] = 1
compass[7] = 0

special.AR = function(weapon,player)
	refresh = refresh + 1
	if refresh > 50 then
		number = math.random(0,100)
		number2 = math.random(0,9)
		refresh = 0
	end
	
	if not shader[weapon]['Compass'] then
		shader[weapon]['Compass'] = createShader()
		engineApplyShaderToWorldTexture(shader[weapon]['Compass'], "compass_plate",weapon)
	else
		local _,_,zr = getElementRotation(weapon)
		local rotation = (zr /360)
		local rotation = (math.floor(rotation*8))
		local rotation = rotation > 7 and 0 or rotation
		
		local picture = prepImage('compass_plate['..compass[rotation]..']')
		dxSetShaderValue( shader[weapon]['Compass'], "tex0", picture )
	end
	
	local ammo = tostring(getElementData(player,'Ammo.AR') or number)
	
	local ammo1 = tonumber(ammo:sub( 1, 1 ))
	
	local ammo2a = tonumber(ammo:sub( 2, 2 ))
		
	local ammo2 = ammo2a or ammo1
	local ammo1 = ammo2a and ammo1 or 0

	
	if not shader[weapon]['Ammo1'] then
		shader[weapon]['Ammo1'] = createShader()
		engineApplyShaderToWorldTexture(shader[weapon]['Ammo1'], "numbers_plate [1]",weapon)
	else
		local picture = prepImage('numbers_plate['..(ammo1 or 0)..']')
		dxSetShaderValue( shader[weapon]['Ammo1'], "tex0", picture )
	end
	
	if not shader[weapon]['Ammo2'] then
		shader[weapon]['Ammo2'] = createShader()
		engineApplyShaderToWorldTexture(shader[weapon]['Ammo2'], "numbers_plate [2]",weapon)
	else
		local picture = prepImage('numbers_plate['..(ammo2 or 0)..']')
		dxSetShaderValue( shader[weapon]['Ammo2'], "tex0", picture )
	end
end
