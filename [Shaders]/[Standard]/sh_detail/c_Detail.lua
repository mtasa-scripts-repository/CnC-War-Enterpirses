
local renderTarget = {RTColor = nil, RTDepth = nil, RTNormal = nil, isOn = false, distFade = {100000, 100000}}
local scx, scy = guiGetScreenSize ()
local enableNormal = false

local details = {}
local shaders = {}

-- Texture,{Apply list},scale,strength,anisotropy

details.grass = {{'detail grass.png','detail ground.png'},{'*ground*'},{60,25},{2.1,0.5,0.4},0.4}



details.cliff = {{'detail grass.png','detail cliff rock smooth.png'},{'cliff rock','*rock*'},{15,1.4},{1,0.5,1},1}

details.cliff2 = {{'detail grass.png','detail cliff rock smooth.png'},{'cliff rock tiled','infinity cliff'},{15,1.5},{1,0.7,1},0.8}



details.metal = {{'detail tech panels.png','detail brushed metal.png'},{'*metal*','*decal fore*','*steel*','*tech*','*tubes*','*fixtures*','*flag_base*','detail strips','*panel*'},{3,3},{0.5,0.6,1},0.8}

details.metal2 = {{'detail tech panels.png','detail brushed metal.png'},{'*ramp*'},{5,5},{0.3,0.3,1},0.8}


details.cliff3 = {'detail cliff rock smooth.png',{'*cliffs*','beavercreek bridge','*boulder*'},5,0.4,0.8}



details.lights = {'detail brushed metal.png',{'*lights*','*decal fore symb*'},1,0.001,0.8}

details.bark = {'bark.png',{'pine_bark','tree_pine_trunk'},1,0.5,0.8}



details.sky = {'detail brushed metal.png',{'*window*','marine_helmet_hud'},100,0.001,0,'object'}

details.metal3 = {'detail brushed metal.png',{'*alpha test*'},2,0.05,0,'object'}


details.bark = {'bark.png',{'Floor_Dark','*trunk*'},2,0.3,0.8}


----------------------------------------------------------------
-- enableDetail
----------------------------------------------------------------
function enableDetail()
	if bEffectEnabled then return end
	-- Load textures
	
	for i,v in pairs(details) do
		if type(v[1]) == 'string' then
			local shader = getMakeShader({texture = dxCreateTexture('media/'..v[1], "dxt5"),detailScale = v[3],sStrength = v[4],sAnisotropy =  v[5],sType =  v[6]})
			shaders[i] = shader
			for index,applyTo in pairs(v[2]) do
				engineApplyShaderToWorldTexture ( shader, applyTo,nil,true  )
			end
		else
			local shader = getMakeShaderSplat({texture1 = dxCreateTexture('media/'..v[1][1], "dxt5"),texture2 = dxCreateTexture('media/'..v[1][2], "dxt5"),detailScale1 = v[3][1],detailScale2 = v[3][2],sStrength1 = v[4][1],sStrength2 = v[4][2],sStrength3 = v[4][2],sAnisotropy =  v[5],sType =  v[6]})
			shaders[i] = shader
			for index,applyTo in pairs(v[2]) do
				engineApplyShaderToWorldTexture ( shader, applyTo,nil,true  )
			end
		end
	end
end

function getMakeShaderSplat(v)
	--  Create shader with a draw range of 300 units
	local shader, tec = nil, nil

	shader,tec = dxCreateShader ( "fx/detail_splat.fx", 1, 600,false,v.sType )	

	if shader then
		dxSetShaderValue( shader, "sDetailTexture1", v.texture1 )
		dxSetShaderValue( shader, "sDetailTexture2", v.texture2 )
		
		dxSetShaderValue( shader, "sDetailScale1", v.detailScale1 )
		dxSetShaderValue( shader, "sDetailScale2", v.detailScale2 )
		
		dxSetShaderValue( shader, "sFadeStart", 1 )
		dxSetShaderValue( shader, "sFadeEnd", 600 )
		dxSetShaderValue( shader, "sStrength", v.sStrength3 )
		dxSetShaderValue( shader, "sDetailMult1", v.sStrength1 )
		dxSetShaderValue( shader, "sDetailMult2", v.sStrength2 )
		dxSetShaderValue( shader, "sAnisotropy", v.sAnisotropy )
	end
	return shader,tec
end

function getMakeShader(v)
	--  Create shader with a draw range of 100 units
	local shader, tec = nil, nil

	if v.sType == 'vehicle' then
		shader,tec = dxCreateShader ( "fx/detail.fx", 5, 300,true,v.sType )	
	else
		shader,tec = dxCreateShader ( "fx/detail.fx", 5, 600,false,v.sType )		
	end

	if shader then
		dxSetShaderValue( shader, "sDetailTexture", v.texture )
		dxSetShaderValue( shader, "sDetailScale", v.detailScale )
		dxSetShaderValue( shader, "sFadeStart", 1 )
		dxSetShaderValue( shader, "sFadeEnd", v.sType == 'vehicle' and 300 or 600 )
		dxSetShaderValue( shader, "sStrength", v.sStrength )
		dxSetShaderValue( shader, "sAnisotropy", v.sAnisotropy )
	end
	return shader,tec
end
enableDetail()

