setElementData(root,'Team_Count',0)

local refresh = {}

function getObjective(oType,ID,Team)
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'eType') == 'Objective') then
			if (getElementData(v,'Obj Type') == oType) and (getElementData(v,'Team') == Team) and (tonumber(getElementData(v,'Obj ID')) == ID) then
				local x,y,z = getElementPosition(v)
				return x,y,z,v
			end
		end
	end
end


function pointChecker ( )
	for i,v in pairs(refresh) do
		v = v - 1
		if v < 0 then
			refresh[i] = nil
			return
		end
		refresh[i] = v
	end
	for i,v in pairs(getElementsByType('player')) do
		local x,y,z = getElementPosition(v)
		for ia = 1,4 do
			local xa,ya,za,teleport = getObjective('Warp In',ia,'Neutral')
			local distance = getDistanceBetweenPoints3D (x,y,z,xa,ya,za)
			if distance < 2 then
				if not refresh[v] then
					refresh[v] = 10
					local xb,yb,zb,target = getObjective('Warp Out',ia,'Neutral')
					setElementPosition(v,xb,yb,zb+1)
					setElementData(v,'Blur',100)
					setElementData(v,'Blur Color',{0,255,0})
				end
			end
		end
	end
end
setTimer ( pointChecker, 50, 0)
