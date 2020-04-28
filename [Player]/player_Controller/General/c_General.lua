screenWidth, screenHeight = guiGetScreenSize() 
soundTable = {}

-- #Math# --
function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end

--[[
addEventHandler("onClientPedStep", root,
	function()
		print('foot')
		local x,y,z = getElementPosition(source)
		local sound = playSound3D('Sounds/Foot Step/grass'..math.random(1,2)..'.wav', x,y,z, true) 
		setSoundMaxDistance (sound,25)
		setSoundVolume (sound,1)
		soundTable[sound] = {getTickCount(),getSoundLength(sound)}
	end
)
]]--

stepCount = 0

onGround = {}

--[[
    <file src="Sounds/Foot Step/concrete1.wav"/> 
    <file src="Sounds/Foot Step/concrete2.wav"/> 
    <file src="Sounds/Foot Step/grass1.wav"/> 
    <file src="Sounds/Foot Step/grass2.wav"/> 
    <file src="Sounds/Foot Step/ice1.wav"/> 
    <file src="Sounds/Foot Step/ice2.wav"/> 
    <file src="Sounds/Foot Step/snow1.wav"/> 
    <file src="Sounds/Foot Step/snow2.wav"/> 
	]]--
	
	
materialList = {}
materialList[9] = 'grass'
materialList[10] = 'grass'
materialList[11] = 'grass'
materialList[12] = 'grass'
materialList[13] = 'grass'
materialList[14] = 'grass'
materialList[15] = 'grass'


function step(x,y,z,material)
	local sound = playSound3D('Sounds/Foot Step/concrete'..math.random(1,2)..'.wav', x,y,z) 
	setSoundMaxDistance (sound,25)
	setSoundVolume (sound,0.4)
	soundTable[sound] = {getTickCount(),getSoundLength(sound)}
	
	if materialList[material] then
		if (math.random(1,5) > 2) then
			local sound = playSound3D('Sounds/Foot Step/'..materialList[material]..math.random(1,2)..'.wav', x,y,z) 
			setSoundMaxDistance (sound,25)
			setSoundVolume (sound,0.3)
			soundTable[sound] = {getTickCount(),getSoundLength(sound)}
		end
	end
end

function playSound(sound)
	local x,y,z = getElementPosition(localPlayer)
	local sound = playSound3D(sound, x,y,z) 
	setSoundMaxDistance (sound,5)
	soundTable[sound] = {getTickCount(),getSoundLength(sound)}
end


function proccessFeet ( )
	local px,py,pz = getElementPosition(localPlayer)
	
	for i,v in pairs(getElementsByType('player',true)) do
		if not getPedOccupiedVehicle(v) then
			onGround[v] = onGround[v] or {}
			local x,y,z = getElementPosition(v)
			if (getDistanceBetweenPoints2D(px,py,x,y) < 50) then
				local bx,by,bz = getPedBonePosition (v,43)
				local hit, _, _, _, elementHit,_,_,_,material = processLineOfSight (bx,by,bz,bx,by,bz-0.35,true,true,false )
				if hit then
					if not onGround[v]['L'] then
						onGround[v]['L'] = 3
						step(x,y,z,material)
					end
				else
					if tonumber(onGround[v]['L']) then
						onGround[v]['L'] = onGround[v]['L'] - 1
						if (onGround[v]['L'] < 0) then
							onGround[v]['L'] = nil
						end
					end
				end
			end
		end
	end
end
addEventHandler ( "onClientRender", root, proccessFeet )



-- Interpolate --
function blend (input,output,percent,cutoff,forceOutput,increase)	
	local input = tonumber(input)
	
	if not input then
		return output
	end
	
	local output = tonumber(output) or 0
	

	local change = (math.max(output-input,input-output))*(percent/100)
	
	if forceOutput then
		if (change > (forceOutput)) then
			return output
		end
	end
	
	local mult = (change>((tonumber(increase)) or (change+1))) and 1.2 or 1
	
	local multiplier = math.min((60/tonumber(getElementData(localPlayer,'FPS')) or 60),1)*mult

	local change = math.max(math.min(change,(cutoff or 0.5)*multiplier),0)

	if input > output then
		return input - change
	elseif input < output then
		return input + change
	else
		return input
	end
end

function blendRot (input,output,percent,cutoff,forceOutput,increase)
	local input = tonumber(input)
	
	if not input then
		return output
	end
	
	local output = tonumber(output) or 0
	
	local output = output
	
	local input = (output>360) and output-360 or ((output<0) and output+360 or (output))

	local change = (math.max(output-input,output-input))*(percent/100)

	if forceOutput then
		if (change > (forceOutput)) then
			return output
		end
	end
	
	local mult = (change>((tonumber(increase)) or (change+1))) and 1.2 or 1
	
	local multiplier = math.min((60/tonumber(getElementData(localPlayer,'FPS')) or 60),1)*mult

	local change = math.max(math.min(change,(cutoff or 0.5)*multiplier),0)

	if input > output then
		return input - change
	elseif input < output then
		return input + change
	else
		return input
	end
end

-- #Shaders# --
nullShader = dxCreateShader ( "Camera/null.fx",1000,0,false,'ped' )

function null(texture,element)
	if isElement(element) then
		engineApplyShaderToWorldTexture(nullShader, texture, element )
	end
end

function unnull(texture,element)
	if isElement(element) then
		engineRemoveShaderFromWorldTexture(nullShader, texture, element )
	end
end

function soundGarbageCollect ( )
	for i,v in pairs(soundTable) do
		local length = v[2]*1000
		local playLength = (getTickCount()-(v[1]))
		if (playLength > length) then
			clearSound(i)
			soundTable[i] = nil
		end
	end
end
setTimer ( soundGarbageCollect, 500, 0)


function clearSound(sound)
	if isElement(sound) then
		stopSound(sound)
		if isElement(sound) then
			destroyElement(sound)
		end
	end
end