function blend (input,output,percent,cutoff,forceOutput,increase)
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

function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end

function getOffset(element,x,y,z)
	if isElement(element) then
		local desiredRelativePosition = Vector3(x,y,z)
		local matrix = element.matrix
		local newPosition = matrix:transformPosition(desiredRelativePosition)
		return newPosition
	end
	return Vector3(0,0,0)
end